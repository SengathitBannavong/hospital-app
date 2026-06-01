import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/device/data/models/asset_device.dart';
import 'package:hospital_app/features/device/data/models/asset_station.dart';
import 'package:hospital_app/features/device/data/models/asset_track.dart';
import 'package:hospital_app/features/device/data/repository/asset_repository.dart';

final assetRepositoryProvider = Provider<AssetRepository>((_) {
  return AssetRepository();
});

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
