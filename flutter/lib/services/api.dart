import 'package:flutter_application_1/models/conversation_preview.dart';

import '../models/contact.dart';
import '../models/message.dart';

abstract class ChatApi {
  Future<bool> login(String username, String password);
  Future<List<Contact>> fetchContacts();
  Future<List<Message>?> fetchConversation(String contactId);
  Future<void> sendMessage(String contactId, String text);
  Future<List<ConversationPreview>> fetchConversationPreviews();
  Future<void> deleteMessage(String messageId);
  Future<int> ensureConversationWith(int contactId);
}
