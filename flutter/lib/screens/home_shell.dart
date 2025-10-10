import 'package:flutter/material.dart';
import '../services/api.dart';
import 'conversations_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart'; 

class HomeShell extends StatefulWidget {
  final ChatApi api;
  const HomeShell({super.key, required this.api});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 1; 

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(api: widget.api),          
      ConversationsScreen(api: widget.api), 
      ProfileScreen(api: widget.api),       
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
