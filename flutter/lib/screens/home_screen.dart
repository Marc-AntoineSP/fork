import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/conversation_preview.dart';
import '../services/api.dart';
import '../models/contact.dart';
import 'contacts_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final ChatApi api;
  const HomeScreen({super.key, required this.api});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  late Future<List<Contact>> _contactsFut;

  @override
  void initState() {
    super.initState();
    _prevSnapshot = _loadNewSnapshot();
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
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHATLINE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(hintText: 'Search…'),
              onChanged:
                  (_) {}, // tu pourras brancher plus tard mon vaillant marc
            ),
            const SizedBox(height: 16),

            // Quick actions
            Row(
              children: [
                _QuickAction(
                  icon: Icons.message_outlined,
                  label: 'New chat',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactsScreen(api: widget.api),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.group_outlined,
                  label: 'Contacts',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactsScreen(api: widget.api),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(api: widget.api),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              'Recent conversations',
              style: TextStyle(
                color: Colors.white.withOpacity(.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: FutureBuilder<void>(
                future: _prevSnapshot,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }
                  if (_items.isEmpty) {
                    return const Center(child: Text('Pas de conversations'));
                  }
                  return ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.white.withOpacity(.08),
                      height: 1,
                    ),
                    itemBuilder: (_, i) {
                      final p = _items[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(p.avatarUrl),
                        ),
                        title: Text(p.name),
                        subtitle: Text(
                          p.lastText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: (p.lastSentAt == null)
                            ? const SizedBox.shrink()
                            : Text(
                                getHourAndMinutes(p.lastSentAt!),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.6),
                                  fontSize: 12,
                                ),
                              ),
                        onTap: () {
                          final c = Contact(
                            id: p.contactId,
                            name: p.name,
                            phone: '0600000000',
                            avatarUrl: p.avatarUrl,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                api: widget.api,
                                contact: c,
                                conversationId: p.conversationId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(color: Colors.white.withOpacity(.9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
