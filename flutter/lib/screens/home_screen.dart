import 'package:flutter/material.dart';
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
  late Future<List<Contact>> _contactsFut;

  @override
  void initState() {
    super.initState();
    _contactsFut = widget.api.fetchContacts();
  }

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
              child: FutureBuilder<List<Contact>>(
                future: _contactsFut,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final contacts = snap.data!;
                  if (contacts.isEmpty) {
                    return const Center(child: Text('No contacts yet'));
                  }
                  return ListView.separated(
                    itemCount: contacts.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.white.withOpacity(.08),
                      height: 1,
                    ),
                    itemBuilder: (_, i) {
                      final c = contacts[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(c.avatarUrl),
                        ),
                        title: Text(c.name),
                        subtitle: Text(
                          c.phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatScreen(api: widget.api, contact: c),
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
