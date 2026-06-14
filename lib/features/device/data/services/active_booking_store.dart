import 'package:hive_flutter/hive_flutter.dart';

import '../models/active_booking.dart';

/// Local persistence for the user's active wheelchair booking.
///
/// Backed by a small Hive box so the booking survives app restarts — without
/// it, leaving the booking screen would strand the borrowed wheelchair with no
/// way back to release it (a booked asset disappears from find_wheelchairs).
class ActiveBookingStore {
  static const _boxName = 'active_asset';
  static const _key = 'current';

  Future<ActiveBooking?> load() async {
    final box = await _openBox();
    final raw = box.get(_key);
    if (raw is Map) {
      final booking = ActiveBooking.fromJson(Map<String, dynamic>.from(raw));
      return booking.assetId.isEmpty ? null : booking;
    }
    return null;
  }

  Future<void> save(ActiveBooking booking) async {
    final box = await _openBox();
    await box.put(_key, booking.toJson());
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_key);
  }

  Future<Box<dynamic>> _openBox() async {
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
