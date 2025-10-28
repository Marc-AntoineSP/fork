import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/conversation_preview.dart';
import '../services/api.dart';
import '../models/contact.dart';
import 'contacts_screen.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  final ChatApi api;
  const ConversationsScreen({super.key, required this.api});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late Future<List<ConversationPreview>> _previewFuture;

  @override
  void initState() {
    super.initState();
    _previewFuture = widget.api.fetchConversationPreviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Messages'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ContactsScreen(api: widget.api),
                ),
              );
            },
            icon: const Icon(Icons.group_add_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<ConversationPreview>>(
        future: _previewFuture,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Divider(color: Colors.white.withOpacity(.1), height: 1),
            itemBuilder: (_, i) {
              final preview = items[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(preview.avatarUrl),
                ),
                title: Text(
                  preview.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  preview.lastText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  toCorrectDate(preview.lastSentAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(.6),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  final p = Contact(
                    id: preview.contactId,
                    name: preview.name,
                    phone: 'testPhone06',
                    avatarUrl: preview.avatarUrl,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        api: widget.api,
                        contact: p,
                        conversationId: preview.conversationId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

String toCorrectDate(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
