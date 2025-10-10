import 'package:flutter/material.dart';
import '../services/api.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatApi api;
  const ProfileScreen({super.key, required this.api});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Nile');
  final _bioCtrl  = TextEditingController(text: 'Just living & coding.');

  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=13'),
                ),
                const SizedBox(height: 10),
                Text('ChatLine ID: me',
                    style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Display name', hintText: 'Your name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Bio', hintText: 'Say something…'),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
            title: const Text('Notifications'),
            subtitle: Text(_notifications ? 'Enabled' : 'Disabled'),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy & Security'),
            subtitle: Text('2FA, blocked users'),
            onTap: () {},
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save profile (local)'),
            onPressed: () {
              // plus tard: appel API pour update
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved locally ✅')),
              );
            },
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
