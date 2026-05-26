import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRepository {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static File get _macosFallbackFile {
    final home = Platform.environment['HOME'];
    return File('$home/.hospital_app_token');
  }

  // Plaintext file fallback exists only because Keychain entitlements can be
  // flaky on local macOS dev builds. Release builds always use Keychain.
  static bool get _useMacosFallback =>
      !kIsWeb && kDebugMode && Platform.isMacOS;

  static Future<void> saveToken(String token) async {
    if (_useMacosFallback) {
      try {
        await _macosFallbackFile.writeAsString(token, flush: true);
        return;
      } catch (_) {
        // fall through to secure storage
      }
    }
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    if (_useMacosFallback) {
      try {
        if (await _macosFallbackFile.exists()) {
          final s = await _macosFallbackFile.readAsString();
          return s.isEmpty ? null : s;
        }
        return null;
      } catch (_) {
        // fall through to secure storage
      }
    }
    return _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    if (_useMacosFallback) {
      try {
        if (await _macosFallbackFile.exists()) {
          await _macosFallbackFile.delete();
        }
        return;
      } catch (_) {
        // fall through to secure storage
      }
    }
    await _storage.delete(key: _tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
