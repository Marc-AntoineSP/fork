import 'dart:async';

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
  late Future<void> _prevSnapshot;
  final List<ConversationPreview> _items = [];
  Timer? _pollingTimer;
  bool _reloadingEnCours = false;

  Future<void> _loadNewSnapshot() async {
    if (_reloadingEnCours) return;
    _reloadingEnCours = true;
    try {
      final previews = await widget.api.fetchConversationPreviews();
      if (!mounted) return;
      setState(() {
        _items.clear();
        _items.addAll(previews);
      });
    } catch (e) {
      print(e);
    } finally {
      _reloadingEnCours = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _prevSnapshot = widget.api.fetchConversationPreviews();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _loadNewSnapshot(),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  String getHourAndMinutes(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

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
      body: FutureBuilder<void>(
        future: _prevSnapshot,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }
          if (_items.isEmpty) {
            return const Center(child: Text('Aucune conversation'));
          }

          return ListView.separated(
            itemCount: _items.length,
            separatorBuilder: (_, __) =>
                Divider(color: Colors.white.withOpacity(.1), height: 1),
            itemBuilder: (_, i) {
              final preview = _items[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(preview.avatarUrl),
                ),
                title: Text(
                  preview.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  preview.lastText.isEmpty
                      ? 'Démarrer la conversation !'
                      : preview.lastText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: (preview.lastSentAt == null)
                    ? const SizedBox.shrink()
                    : Text(
                        getHourAndMinutes(preview.lastSentAt!),
                        style: TextStyle(
                          color: Colors.white.withOpacity(.6),
                          fontSize: 12,
                        ),
                      ),
                onTap: () {
                  final c = Contact(
                    id: preview.contactId,
                    name: preview.name,
                    phone: 'testPhone06',
                    avatarUrl: preview.avatarUrl,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        api: widget.api,
                        contact: c,
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
