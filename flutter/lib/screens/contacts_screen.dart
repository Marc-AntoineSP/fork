import 'package:flutter/material.dart';
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

  _refresh() {
    setState(() {
      _contactsFuture = api.fetchContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snap) {
          if (!snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final contacts = snap.data!;
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
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.white.withOpacity(.1), height: 1),
                  itemBuilder: (_, i) {
                    final c = contacts[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(c.avatarUrl),
                      ),
                      title: Text(c.name),
                      subtitle: Text(c.phone),
                      onTap: () => Navigator.pop(context),
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
