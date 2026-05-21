import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/services/route_result_mapper.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';

class RoutingService {
  final MapRepository _repository;
  final RoutingEngine _engine;
  final Connectivity _connectivity;
  final RouteResultMapper _mapper;

  RoutingService({
    required MapRepository repository,
    required RoutingEngine engine,
    Connectivity? connectivity,
    RouteResultMapper mapper = const RouteResultMapper(),
  }) : _repository = repository,
       _engine = engine,
       _connectivity = connectivity ?? Connectivity(),
       _mapper = mapper;

  Future<RouteResult> route({
    required int startLocation,
    required int destLocation,
    required String modeId,
    required Map<int, List<int>> adjacency,
    required int cols,
    Map<String, EdgeStatus> edgeStatuses = const <String, EdgeStatus>{},
  }) async {
    if (await _hasNetwork()) {
      try {
        final preview = await _repository.previewRoute(
          startLocation: startLocation,
          destLocation: destLocation,
          modeId: modeId,
        );
        final result = _mapper.fromPreviewJson(preview);
        if (result.path.isNotEmpty) {
          return result;
        }
      } catch (_) {
        // The local engine is the required fallback whenever online preview
        // cannot be reached or parsed by the repository layer.
      }
    }

    return _engine.route(
      startLocation: startLocation,
      destLocation: destLocation,
      modeId: modeId,
      adjacency: adjacency,
      cols: cols,
      edgeStatuses: edgeStatuses,
    );
  }

  Future<bool> _hasNetwork() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
