import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/contact.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatApi api;
  final Contact contact;
  const ChatScreen({super.key, required this.api, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<Message>> _messagesFut;
  final _inputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messagesFut = widget.api.fetchConversation(widget.contact.id);
  }

  Future<void> _refresh() async {
    final fut = widget.api.fetchConversation(widget.contact.id);
    setState(() {
      _messagesFut = fut;
    });
    await fut;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Messages'),
        actions: const [Icon(Icons.more_horiz)],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: _messagesFut,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = snap.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i];
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
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = _inputCtrl.text.trim();
                      if (text.isEmpty) return;
                      _inputCtrl.clear();
                      await widget.api.sendMessage(widget.contact.id, text);
                      await _refresh();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
