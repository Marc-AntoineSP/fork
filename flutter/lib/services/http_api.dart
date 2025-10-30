import 'dart:async';
import 'package:flutter_application_1/models/conversation_preview.dart';

import '../models/contact.dart';
import '../models/message.dart';
import 'api.dart';
import 'package:dio/dio.dart';

// Future<bool> login(String username, String password);
//   Future<List<Contact>> fetchContacts();
//   Future<List<Message>> fetchConversation(String contactId);
//   Future<void> sendMessage(String contactId, String text);

class HttpApi implements ChatApi {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000'));
  late String? accessToken;
  late String? refreshToken;
  late String? userId;

  final Map<String, List<Message>> _threads = {};

  DateTime sqlDateParse(String raw) =>
      DateTime.parse(raw.contains('T') ? raw : raw.replaceFirst(' ', 'T'));

  @override
  Future<bool> login(String username, String password) async {
    final response = await dio.post(
      '/auth',
      data: {'username': username, 'password': password},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (_) => true,
      ),
    );
    if (response.statusCode != 200) {
      return false;
    }
    final data = response.data['data'] as Map;
    accessToken = data['at'] as String?;
    refreshToken = data['rt'] as String?;
    userId = data['conf']?['sub']?.toString();

    if (accessToken != null) {
      dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return true;
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
}
