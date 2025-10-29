import 'dart:async';

import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/contact.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatApi api;
  final Contact contact;
  final String? conversationId;
  const ChatScreen({
    super.key,
    required this.api,
    required this.contact,
    this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final String _convId;
  // late Future<List<Message>> _messagesFut;
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  late Future<void> _prevSnapshot;
  final List<Message> _items = [];
  Timer? _pollingTimer;
  bool _reloadingEnCours = false;
  String? _lastMessageId;

  @override
  void initState() {
    super.initState();
    _convId = widget.conversationId ?? widget.contact.id;
    _prevSnapshot = _fetchMessages(scrollToEnd: true);
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _fetchMessages(),
    );
  }

  Future<void> _fetchMessages({bool scrollToEnd = false}) async {
    if (_reloadingEnCours) return;
    _reloadingEnCours = true;
    try {
      final data = await widget.api.fetchConversation(_convId);
      if (data == null) {
        _pollingTimer?.cancel();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Conversation supprimée')));
        Navigator.of(context).pop();
        return;
      }
      if (!mounted) return;

      final newLastMessageId = data.isNotEmpty ? data.last.id : null;
      final hasChanged =
          _items.length != data.length || newLastMessageId != _lastMessageId;
      if (hasChanged) {
        setState(() {
          _items.clear();
          _items.addAll(data);
          _lastMessageId = newLastMessageId;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollCtrl.hasClients) return;
          _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
        });
      }
    } catch (e) {
      print(e);
    } finally {
      _reloadingEnCours = false;
    }
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();

    await widget.api.sendMessage(_convId, text);
    await _fetchMessages(scrollToEnd: true);
  }

  // Future<void> _refresh() async {
  //   final id = widget.conversationId ?? widget.contact.id;
  //   final fut = widget.api.fetchConversation(id);
  //   setState(() {
  //     _messagesFut = fut;
  //   });
  //   await fut;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.contact.name),
        actions: const [Icon(Icons.more_horiz)],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _prevSnapshot,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Erreur: ${snap.error}'));
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final m = _items[i];
                    final isMe = m.authorId == 'me';
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFFE63946)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m.text),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: 'Message…'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.send), onPressed: _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
