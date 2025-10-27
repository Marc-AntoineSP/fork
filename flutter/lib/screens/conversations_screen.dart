import 'package:flutter/material.dart';
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
  late Future<List<Contact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = widget.api.fetchContacts();
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
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final contacts = snap.data!;
          return ListView.separated(
            itemCount: contacts.length,
            separatorBuilder: (_, __) =>
                Divider(color: Colors.white.withOpacity(.1), height: 1),
            itemBuilder: (_, i) {
              final c = contacts[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(c.avatarUrl),
                ),
                title: Text(
                  c.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Hey! How’s it going?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '04:04 AM',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.6),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(api: widget.api, contact: c),
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
