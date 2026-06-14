import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/device/data/models/active_booking.dart';
import 'package:hospital_app/features/device/data/models/asset_device.dart';
import 'package:hospital_app/features/device/data/models/asset_station.dart';
import 'package:hospital_app/features/device/data/models/asset_track.dart';
import 'package:hospital_app/features/device/data/repository/asset_repository.dart';
import 'package:hospital_app/features/device/data/services/active_booking_store.dart';

final assetRepositoryProvider = Provider<AssetRepository>((_) {
  return AssetRepository();
});

final activeBookingStoreProvider = Provider<ActiveBookingStore>((_) {
  return ActiveBookingStore();
});

/// The user's currently-borrowed wheelchair (or null). Persisted via Hive so it
/// survives restarts; drives the Home re-entry card and the booking screen's
/// release gating.
final activeBookingProvider =
    StateNotifierProvider<ActiveBookingNotifier, ActiveBooking?>((ref) {
      return ActiveBookingNotifier(
        ref.watch(assetRepositoryProvider),
        ref.watch(activeBookingStoreProvider),
      );
    });

class ActiveBookingNotifier extends StateNotifier<ActiveBooking?> {
  ActiveBookingNotifier(this._repository, this._store) : super(null) {
    _load();
  }

  final AssetRepository _repository;
  final ActiveBookingStore _store;

  Future<void> _load() async {
    state = await _store.load();
  }

  /// Books [assetId]; on success persists and exposes it as the active booking.
  /// Throws on failure (caller shows the message).
  Future<void> book(String assetId) async {
    final booking = await _repository.bookAsset(assetId);
    await _store.save(booking);
    state = booking;
  }

  /// Releases [assetId] at [stationId]; on success clears the active booking.
  /// Throws on failure (caller shows the message).
  Future<void> release({
    required String assetId,
    required String stationId,
  }) async {
    await _repository.releaseAsset(assetId: assetId, stationId: stationId);
    await _store.clear();
    state = null;
  }

  /// Records [assetId] as the active booking locally (used after recovery /
  /// confirming an in-use asset is the user's own).
  Future<void> adopt(String assetId) async {
    final booking = ActiveBooking(assetId: assetId);
    await _store.save(booking);
    state = booking;
  }

  /// Discovers wheelchairs the backend reports as `in_use` so a booking the
  /// local store lost (fresh install / another phone) can be recovered. If
  /// exactly one is found it is adopted automatically; otherwise the candidates
  /// are returned for the user to confirm which is theirs.
  Future<List<String>> recover() async {
    final inUse = await _repository.discoverInUseAssets();
    if (inUse.length == 1) {
      await adopt(inUse.first);
    }
    return inUse;
  }

  bool isMine(String assetId) => state?.assetId == assetId;
}

final assetStationsProvider = FutureProvider<List<AssetStation>>((ref) {
  return ref.watch(assetRepositoryProvider).getStations();
});

final wheelchairSearchProvider =
    FutureProvider.family<List<AssetDevice>, String>((ref, nodeId) {
      return ref.watch(assetRepositoryProvider).findWheelchairs(nodeId: nodeId);
    });

final assetHealthProvider = FutureProvider.family<AssetTrack, String>((
  ref,
  assetId,
) {
  return ref.watch(assetRepositoryProvider).getAssetHealth(assetId);
});

final assetTrackProvider = FutureProvider.family<AssetTrack, String>((
  ref,
  assetId,
) {
  return ref.watch(assetRepositoryProvider).trackAsset(assetId);
});
