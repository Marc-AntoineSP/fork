import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/contact.dart';

class ContactsScreen extends StatelessWidget {
  final ChatApi api;
  const ContactsScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: FutureBuilder<List<Contact>>(
        future: api.fetchContacts(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final contacts = snap.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text('CONTACT', style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 2))),
              Expanded(
                child: ListView.separated(
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(.1), height: 1),
                  itemBuilder: (_, i) {
                    final c = contacts[i];
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(c.avatarUrl)),
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
