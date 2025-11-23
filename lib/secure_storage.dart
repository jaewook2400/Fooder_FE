import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._internal();
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _key = "access_token";

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _key);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _key);
  }
}
