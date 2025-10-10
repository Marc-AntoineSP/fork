import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ChatLineApp());
}

class ChatLineApp extends StatelessWidget {
  const ChatLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatLine',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      home: const LoginScreen(),
    );
  }
}
