import 'dart:async';
import 'package:flutter_application_1/models/conversation_preview.dart';
import 'package:flutter_application_1/services/token_storage.dart';

import '../models/contact.dart';
import '../models/message.dart';
import 'api.dart';
import 'package:dio/dio.dart';

// Future<bool> login(String username, String password);
//   Future<List<Contact>> fetchContacts();
//   Future<List<Message>> fetchConversation(String contactId);
//   Future<void> sendMessage(String contactId, String text);

class HttpApi implements ChatApi {
  final Dio dio;
  final TokenStorage tokenStorage = TokenStorage();
  String? accessToken;
  String? refreshToken;
  String? userId;

  Future<void>? _refreshingToken;

  final Map<String, List<Message>> _threads = {};

  DateTime sqlDateParse(String raw) =>
      DateTime.parse(raw.contains('T') ? raw : raw.replaceFirst(' ', 'T'));

  HttpApi({String baseUrl = 'http://127.0.0.1:8000'})
    : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path.startsWith('/auth')) {
            return handler.next(options);
          }
          final at = accessToken ?? await tokenStorage.at;
          if (at != null && at.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $at';
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final req = err.requestOptions;

          // Ne pas tenter de refresh si: pas 401, ou endpoint auth/refresh, ou déjà retenté
          final is401 = err.response?.statusCode == 401;
          final isAuth = req.path.contains('/auth');
          final retried = req.extra['retried'] == true;

          if (!is401 || isAuth || retried) {
            return handler.next(err);
          }

          try {
            // Single-flight: si refresh en cours, on attend
            _refreshingToken ??= _doRefresh();
            await _refreshingToken;
          } catch (e) {
            _refreshingToken = null;
            // Échec de refresh -> on purge et on renvoie l’erreur
            await _logoutLocal();
            return handler.next(err);
          }
          _refreshingToken = null;

          // Après refresh, on rejoue la requête d’origine
          final at = accessToken ?? await tokenStorage.at;

          // clone propre de la requête d’origine
          final headers = Map<String, dynamic>.from(req.headers);
          if (at != null) headers['Authorization'] = 'Bearer $at';

          final clone = await dio.request(
            req.path,
            data: req.data,
            queryParameters: req.queryParameters,
            options: Options(
              method: req.method,
              headers: headers,
              responseType: req.responseType,
              contentType: req.contentType,
              followRedirects: req.followRedirects,
              listFormat: req.listFormat,
              sendTimeout: req.sendTimeout,
              receiveTimeout: req.receiveTimeout,
              validateStatus: req.validateStatus,
              // 👇 pas de merge : on pose extra directement
              extra: {...req.extra, 'retried': true},
            ),
            cancelToken: req.cancelToken,
            onReceiveProgress: req.onReceiveProgress,
            onSendProgress: req.onSendProgress,
          );

          return handler.resolve(clone);
        },
      ),
    );
  }

  @override
  Future<bool> login(String username, String password) async {
    final res = await dio.post(
      '/auth',
      data: {'username': username, 'password': password},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (_) => true,
      ),
    );
    if (res.statusCode != 200) return false;

    // Attendu: { data: { at, rt, conf: { sub, ... } } }
    final data = res.data['data'] as Map;
    final at = data['at'] as String?;
    final rt = data['rt'] as String?;
    final sub = data['conf']?['sub']?.toString();

    if (at == null || rt == null || sub == null) return false;

    // Sync mémoire + stockage + header
    accessToken = at;
    refreshToken = rt;
    userId = sub;
    await tokenStorage.save(at, rt, sub);
    dio.options.headers['Authorization'] = 'Bearer $at';
    return true;
  }

  Future<void> _doRefresh() async {
    // Charge RT depuis mémoire ou storage
    final rt = refreshToken ?? await tokenStorage.rt;
    if (rt == null || rt.isEmpty) throw Exception('No refresh token');

    final res = await dio.post(
      '/auth/refresh',
      data: {'rt': rt},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (_) => true,
      ),
    );

    if (res.statusCode != 200) {
      throw Exception('Refresh failed: ${res.data}');
    }
    // Attendu: { data: { at, rt } }
    final data = res.data['data'] as Map;
    final newAt = data['at']?.toString();
    final newRt = data['rt']?.toString();
    if (newAt == null || newRt == null) {
      throw Exception('Invalid refresh payload');
    }

    accessToken = newAt;
    refreshToken = newRt;
    final uid = userId ?? await tokenStorage.uid ?? '';
    await tokenStorage.save(newAt, newRt, uid);
    dio.options.headers['Authorization'] = 'Bearer $newAt';
  }

  @override
  Future<List<ConversationPreview>> fetchConversationPreviews() async {
    final convResponse = await dio.get(
      '/users/$userId/conversations',
      options: Options(validateStatus: (_) => true),
    );
    if (convResponse.statusCode != 200) {
      throw Exception('Failed to load conversation previews');
    }
    final data = convResponse.data;
    final list = (data['data'] as List);
    final previews = list.map((preview) {
      final sentCheckNull = preview['message_sent_at'];
      final DateTime? sentSafe = (sentCheckNull != null)
          ? sqlDateParse((preview['message_sent_at']))
          : null;
      final otherId = preview['other_user_id'].toString();
      final name = preview['other_username'];
      final text = (preview['message_content'] ?? '').toString();
      final sent = sentSafe;
      final otherAvatarUrl = preview['other_avatar_url'];
      final convId = (preview['conversation_id'] ?? preview['id']).toString();

      return ConversationPreview(
        contactId: otherId,
        name: name,
        avatarUrl: otherAvatarUrl,
        lastText: text,
        lastSentAt: sent,
        conversationId: convId,
      );
    }).toList();
    previews.sort((a, b) {
      final aa = a.lastSentAt, bb = b.lastSentAt;
      if (aa == null && bb == null) return 0;
      if (aa == null) return 1;
      if (bb == null) return -1;
      return bb.compareTo(aa);
    });
    return previews;
  }

  Future<void> _logoutLocal() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    await tokenStorage.clear();
    dio.options.headers.remove('Authorization');
  }

  Future<void> logout() async {
    // Optionnel: prévenir le serveur pour révoquer le RT courant
    final rt = refreshToken ?? await tokenStorage.rt;
    if (rt != null && rt.isNotEmpty) {
      await dio.post(
        '/auth/logout',
        data: {'rt': rt},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (_) => true,
        ),
      );
    }
    await _logoutLocal();
  }

  @override
  Future<List<Contact>> fetchContacts() async {
    Response response = await dio.get(
      '/users',
      options: Options(validateStatus: (_) => true),
    );
    if (response.statusCode != 200) {
      final msg = (response.data is Map && response.data['error'] != null)
          ? response.data['error'].toString()
          : 'Status code: ${response.statusCode}';
      throw Exception('Failed to load contacts: $msg');
    }
    final data = response.data;
    final list = (data['data'] as List);

    print("contact bruts : $data['data']");
    final List<Contact> contacts = list
        .map(
          (u) => Contact(
            id: u['id'].toString(),
            name: u['username'],
            phone: u['phone'].toString(),
            avatarUrl: u['avatar_url'],
          ),
        )
        .toList();

    return contacts;
  }

  @override
  Future<List<Message>?> fetchConversation(String convId) async {
    final response = await dio.get(
      '/conversations/$convId/messages',
      options: Options(validateStatus: (_) => true),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final list = (data['data'] as List);
      print("conversation bruts : $list");

      final List<Message> messages = list
          .map(
            (m) => Message(
              id: m['id'].toString(),
              authorId: m['sender_id'].toString() == userId
                  ? 'me'
                  : m['sender_id'].toString(),
              text: m['content'],
              sentAt: sqlDateParse((m['sent_at']).toString()),
            ),
          )
          .toList();

      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      return messages;
    }
    if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load conversation');
    }
  }

  @override
  Future<void> sendMessage(String contactId, String text) async {
    if (userId == null) {
      throw Exception('User pas logged');
    }
    final response = await dio.post(
      '/conversations/$contactId/messages',
      data: {'user_id': userId, 'message': text},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (_) => true,
      ),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
    final newMessage = response.data['data'] as Map;
    final messageCreated = Message(
      id: newMessage['id'].toString(),
      authorId: newMessage['sender_id'].toString() == userId
          ? 'me'
          : newMessage['sender_id'].toString(),
      text: newMessage['content'],
      sentAt: sqlDateParse((newMessage['sent_at']).toString()),
    );
    final list = _threads.putIfAbsent(contactId, () => []);
    list.add(messageCreated);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final response = await dio.delete(
      '/messages/$messageId',
      options: Options(validateStatus: (_) => true),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete message');
    }
  }

  @override
  Future<int> ensureConversationWith(int contactId, {String? name}) async {
    if (userId == null) {
      throw Exception('User pas logged');
    }

    if (userId == contactId.toString()) {
      throw Exception("Touche à ton cul qui croyait prendre");
    }

    final response = await dio.post(
      '/conversations',
      data: {
        'user_id': userId,
        'recipient_id': contactId.toString(),
        'name': name ?? 'Conv entre $userId et $contactId',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (_) => true,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      //oui.
      final raw = response.data;
      if (raw is Map) {
        final maybeInner = raw['data'];
        final map = (maybeInner is Map) ? maybeInner : raw;
        final any = map['conversation_id'] ?? map['id'];
        //Forcage du type car jpp
        final convId = any != null ? int.tryParse(any.toString()) : null;
        if (convId != null) return convId;
      }
      throw Exception('Réponse invalide: ${response.data}');
    }

    final errMsg = (response.data is Map)
        ? (response.data['error'] ?? response.data)
        : response.statusMessage;
    throw Exception('Failed ${errMsg ?? ""}');
  }
}
