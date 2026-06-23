import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_profile.dart';

/// Persists the last successfully loaded profile so it can be shown while
/// offline. The page reads this fallback when a live fetch fails.
class ProfileLocalDataSource {
  static const _boxName = 'profile_cache';
  static const _profileKey = 'profile';

  Future<Box<dynamic>>? _boxFuture;

  Future<void> saveProfile(UserProfile profile) async {
    final box = await _openBox();
    await box.put(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile() async {
    final box = await _openBox();
    final raw = box.get(_profileKey);
    if (raw is String) {
      final json = jsonDecode(raw);
      if (json is Map) {
        return UserProfile.fromJson(Map<String, dynamic>.from(json));
      }
    }
    return null;
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_profileKey);
  }

  Future<Box<dynamic>> _openBox() {
    return _boxFuture ??= _initAndOpenBox();
  }

  Future<Box<dynamic>> _initAndOpenBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    try {
      return await Hive.openBox<dynamic>(_boxName);
    } catch (_) {
      await Hive.initFlutter();
      return Hive.openBox<dynamic>(_boxName);
    }
  }
}
