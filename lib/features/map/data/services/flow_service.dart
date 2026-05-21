import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/flow_snapshot.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';

class FlowService {
  final MapRepository _repository;
  final MapCacheService _cache;

  const FlowService({
    required MapRepository repository,
    required MapCacheService cache,
  }) : _repository = repository,
       _cache = cache;

  Future<FlowSnapshot> snapshot({required int mapId}) async {
    try {
      final cells = await _repository.getFlowHeatmap();
      final edgeStatuses = await _repository.getFlowEdgeStatus();
      final alerts = await _repository.getFlowAlerts();
      final snapshot = FlowSnapshot(
        cells: cells,
        edgeStatuses: edgeStatuses,
        alerts: alerts,
        updatedAt: DateTime.now().toUtc(),
      );
      await _cache.saveFlowSnapshot(mapId: mapId, snapshot: snapshot);
      return snapshot;
    } catch (_) {
      return await _cache.loadFlowSnapshot(mapId: mapId) ??
          FlowSnapshot.empty().asStale();
    }
  }
}
