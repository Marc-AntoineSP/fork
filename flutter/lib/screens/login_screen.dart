import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/http_api.dart';
import '../services/api.dart';
import '../services/mock_api.dart';
import 'home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final HttpApi _httpApi = HttpApi();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'CHATLINE',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(hintText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      final ok = await _httpApi.login(
                        _userCtrl.text,
                        _passCtrl.text,
                      );
                      setState(() {
                        _loading = false;
                      });
                      if (ok && mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => HomeShell(api: _httpApi),
                          ),
                        );
                      } else {
                        setState(() {
                          _error = "Identifiants invalides";
                        });
                      }
                    },
              child: Text(_loading ? 'Connexion…' : 'Se connecter'),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            const Spacer(),
            Text(
              "Pas de compte ? Créez-en un !",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(.7)),
            ),
          ],
        ),
      ),
    );
  }
}
