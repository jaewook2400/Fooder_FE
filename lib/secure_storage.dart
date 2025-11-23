import 'dart:io';

class SecureStorage {
  SecureStorage._internal();
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;

  String? _token;

  final _file = File('token.txt');

  Future<void> saveAccessToken(String token) async {
    _token = token;
    await _file.writeAsString(token);
  }

  Future<String?> getAccessToken() async {
    if (_token != null) return _token;
    if (await _file.exists()) {
      _token = await _file.readAsString();
      return _token;
    }
    return null;
  }
}