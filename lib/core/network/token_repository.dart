import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRepository {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static final File _macosFallbackFile = File(
    '${Platform.environment['HOME']}/.hospital_app_token',
  );

  static Future<void> saveToken(String token) async {
    if (Platform.isMacOS) {
      try {
        await _macosFallbackFile.writeAsString(token, flush: true);
      } catch (_) {
        await _storage.write(key: _tokenKey, value: token);
      }
    } else {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  static Future<String?> getToken() async {
    if (Platform.isMacOS) {
      try {
        if (await _macosFallbackFile.exists()) {
          final s = await _macosFallbackFile.readAsString();
          return s.isEmpty ? null : s;
        }
        return null;
      } catch (_) {
        return await _storage.read(key: _tokenKey);
      }
    }
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    if (Platform.isMacOS) {
      try {
        if (await _macosFallbackFile.exists()) {
          await _macosFallbackFile.delete();
        }
      } catch (_) {
        await _storage.delete(key: _tokenKey);
      }
    } else {
      await _storage.delete(key: _tokenKey);
    }
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
