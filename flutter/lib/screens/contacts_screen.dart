import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/chat_screen.dart';
import 'package:flutter_application_1/screens/conversations_screen.dart';
import '../services/api.dart';
import '../models/contact.dart';

class ContactsScreen extends StatefulWidget {
  final ChatApi api;
  const ContactsScreen({super.key, required this.api});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late Future<List<Contact>> _contactsFuture;
  ChatApi get api => widget.api;
  @override
  void initState() {
    super.initState();
    _contactsFuture = api.fetchContacts();
  }

  Future<void> _refresh() async {
    setState(() {
      _contactsFuture = api.fetchContacts();
    });
    await _contactsFuture;
  }

  Future<void> _openOrCreateConversation(Contact contact) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final convId = await api.ensureConversationWith(int.parse(contact.id));
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: convId.toString(),
            api: api,
            contact: contact,
          ),
        ),
      );
    } catch (e) {
      print(e);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de la conversation: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final contacts = snap.data ?? const <Contact>[];
          if (contacts.isEmpty) {
            return const Center(child: Text('Aucun contacts'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'CONTACT',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: contacts.length,
                  separatorBuilder: (_, i) =>
                      Divider(color: Colors.white.withOpacity(.1), height: 1),
                  itemBuilder: (_, i) {
                    final c = contacts[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(c.avatarUrl),
                      ),
                      title: Text(c.name),
                      subtitle: Text(c.phone),
                      onTap: () => _openOrCreateConversation(c),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
