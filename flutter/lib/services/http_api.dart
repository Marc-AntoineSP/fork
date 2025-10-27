import 'dart:async';
import '../models/contact.dart';
import '../models/message.dart';
import 'api.dart';
import 'package:dio/dio.dart';

// Future<bool> login(String username, String password);
//   Future<List<Contact>> fetchContacts();
//   Future<List<Message>> fetchConversation(String contactId);
//   Future<void> sendMessage(String contactId, String text);

class HttpApi implements ChatApi {
  final Dio dio = Dio();
  late String accessToken;
  final _me = 'me';

  final _contacts = <Contact>[
    Contact(
      id: 'amanda',
      name: 'Amanda',
      phone: '+33 6 00 00 00 01',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
    ),
    Contact(
      id: 'bruno',
      name: 'Bruno',
      phone: '+33 6 00 00 00 02',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
    ),
    Contact(
      id: 'coralie',
      name: 'Coralie',
      phone: '+33 6 00 00 00 03',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
    ),
    Contact(
      id: 'emeric',
      name: 'Emeric',
      phone: '+33 6 00 00 00 04',
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
    ),
    Contact(
      id: 'eric',
      name: 'Eric',
      phone: '+33 6 00 00 00 05',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
    ),
    Contact(
      id: 'fouzila',
      name: 'Fouzila',
      phone: '+33 6 00 00 00 06',
      avatarUrl: 'https://i.pravatar.cc/150?img=6',
    ),
    Contact(
      id: 'zack',
      name: 'Zack',
      phone: '+33 6 00 00 00 07',
      avatarUrl: 'https://i.pravatar.cc/150?img=7',
    ),
  ];

  final Map<String, List<Message>> _threads = {};

  @override
  Future<bool> login(String username, String password) async {
    final response = await dio.post(
      'http://127.0.0.1:8000/auth',
      data: {'username': username, 'password': password},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (_) => true,
      ),
    );

    return response.statusCode == 200;
  }

  @override
  Future<List<Contact>> fetchContacts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _contacts;
  }

  @override
  Future<List<Message>> fetchConversation(String contactId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _threads.putIfAbsent(
      contactId,
      () => [
        Message(
          id: 'm1',
          fromId: contactId,
          toId: _me,
          text: 'Hey! How’s it going?',
          sentAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        Message(
          id: 'm2',
          fromId: _me,
          toId: contactId,
          text: 'tg le troubadour',
          sentAt: DateTime.now().subtract(
            const Duration(hours: 5, minutes: 58),
          ),
        ),
      ],
    );
    final list = _threads[contactId]!;
    list.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return list;
  }

  @override
  Future<void> sendMessage(String contactId, String text) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final list = _threads.putIfAbsent(contactId, () => []);
    list.add(
      Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fromId: _me,
        toId: contactId,
        text: text,
        sentAt: DateTime.now(),
      ),
    );
  }
}
