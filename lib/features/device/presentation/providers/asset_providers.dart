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
    // Show the locally-cached booking immediately, then reconcile against the
    // backend's authoritative `my_booking` so a booking made (or released) on
    // another device is reflected. Network failures keep the cached value.
    state = await _store.load();
    await _refreshFromBackend();
  }

  /// Reconciles local state with the backend's authoritative current booking.
  /// Best-effort: swallows errors (offline / old backend) so it never disturbs
  /// the cached state. Returns the resolved booking (or null).
  Future<ActiveBooking?> _refreshFromBackend() async {
    try {
      final remote = await _repository.getMyBooking();
      if (remote == null) {
        if (state != null) {
          await _store.clear();
          state = null;
        }
      } else {
        await _store.save(remote);
        state = remote;
      }
      return remote;
    } catch (_) {
      return state;
    }
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

  /// Recovers a booking the local store lost (fresh install / another phone).
  ///
  /// Asks the backend's authoritative `my_booking` first: if it reports a
  /// booking it is adopted exactly and returned as the single candidate; if it
  /// reports none, recovery stops (the user genuinely holds nothing). Only if
  /// that endpoint is unavailable (old backend / network error) does it fall
  /// back to the legacy in-use discovery heuristic, which returns candidates
  /// for the user to confirm when several assets are in use.
  Future<List<String>> recover() async {
    try {
      final remote = await _repository.getMyBooking();
      if (remote == null) return const [];
      await _store.save(remote);
      state = remote;
      return [remote.assetId];
    } catch (_) {
      // Authoritative endpoint unavailable — fall back to the heuristic.
    }
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
