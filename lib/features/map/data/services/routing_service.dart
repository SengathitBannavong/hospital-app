import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';

class RoutingService {
  final MapRepository _repository;
  final RoutingEngine _engine;
  final Connectivity _connectivity;

  RoutingService({
    required MapRepository repository,
    required RoutingEngine engine,
    Connectivity? connectivity,
  }) : _repository = repository,
       _engine = engine,
       _connectivity = connectivity ?? Connectivity();

  Future<dynamic> route({
    required int startLocation,
    required int destLocation,
    required String modeId,
    required Map<int, List<int>> adjacency,
    required int cols,
    Map<String, EdgeStatus> edgeStatuses = const <String, EdgeStatus>{},
  }) async {
    if (await _hasNetwork()) {
      try {
        return await _repository.previewRoute(
          startLocation: startLocation,
          destLocation: destLocation,
          modeId: modeId,
        );
      } catch (_) {
        // The local engine is the required fallback whenever online preview
        // cannot be reached or parsed by the repository layer.
      }
    }

    return _engine
        .route(
          startLocation: startLocation,
          destLocation: destLocation,
          modeId: modeId,
          adjacency: adjacency,
          cols: cols,
          edgeStatuses: edgeStatuses,
        )
        .toPreviewJson();
  }

  Future<bool> _hasNetwork() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
