import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // ⚠️ Ne crée JAMAIS le plugin si Linux (évite l'appel libsecret)
  final FlutterSecureStorage? _s = Platform.isLinux
      ? null
      : const FlutterSecureStorage();
  static final Map<String, String> _mem = {}; // fallback dev (non sécurisé)

  bool get _useMem => Platform.isLinux;

  Future<void> save(String at, String rt, String uid) async {
    if (_useMem) {
      _mem['at'] = at;
      _mem['rt'] = rt;
      _mem['uid'] = uid;
      return;
    }
    try {
      await _s!.write(key: 'at', value: at);
      await _s!.write(key: 'rt', value: rt);
      await _s!.write(key: 'uid', value: uid);
    } on PlatformException {
      _mem['at'] = at;
      _mem['rt'] = rt;
      _mem['uid'] = uid;
    }
  }

  Future<String?> get at async {
    if (_useMem) return _mem['at'];
    try {
      return await _s!.read(key: 'at');
    } on PlatformException {
      return _mem['at'];
    }
  }

  Future<String?> get rt async {
    if (_useMem) return _mem['rt'];
    try {
      return await _s!.read(key: 'rt');
    } on PlatformException {
      return _mem['rt'];
    }
  }

  Future<String?> get uid async {
    if (_useMem) return _mem['uid'];
    try {
      return await _s!.read(key: 'uid');
    } on PlatformException {
      return _mem['uid'];
    }
  }

  Future<void> clear() async {
    if (_useMem) {
      _mem.clear();
      return;
    }
    try {
      await _s!.delete(key: 'at');
      await _s!.delete(key: 'rt');
      await _s!.delete(key: 'uid');
    } on PlatformException {
      _mem.clear();
    }
  }
}
