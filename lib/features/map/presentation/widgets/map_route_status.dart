import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapRouteStatus extends StatelessWidget {
  final AsyncValue<dynamic> routeResult;
  final List<int> routeLocations;

  const MapRouteStatus({
    super.key,
    required this.routeResult,
    required this.routeLocations,
  });

  @override
  Widget build(BuildContext context) {
    return routeResult.when(
      data: (data) {
        if (data == null) {
          return const Text('Choose start and destination to preview route.');
        }
        return Text('Route points: ${routeLocations.length}');
      },
      loading: () => const Text('Calculating route…'),
      error: (error, _) => Text('Route error: ${error.toString()}'),
    );
  }
}
