import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';

class MapSearchResultsPanel extends StatelessWidget {
  final AsyncValue<List<MapPoi>> results;
  final ValueChanged<MapPoi> onSelect;

  const MapSearchResultsPanel({
    super.key,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: results.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No results'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final poi = items[index];
              return ListTile(
                title: Text(poi.poiName),
                subtitle: Text(poi.poiType),
                onTap: () => onSelect(poi),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
