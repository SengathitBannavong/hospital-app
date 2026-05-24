part of '../../pages/map_page.dart';

class _FloorSelector extends StatelessWidget {
  final List<MapFloor> floors;
  final int selectedMapId;
  final ValueChanged<int?> onChanged;

  const _FloorSelector({
    required this.floors,
    required this.selectedMapId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (floors.length < 2) {
      return const SizedBox.shrink();
    }
    final scheme = context.colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 2,
      shadowColor: scheme.shadow,
      borderRadius: AppRadius.borderFull,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: selectedMapId,
            borderRadius: AppRadius.borderMd,
            icon: const Icon(Icons.expand_more_rounded),
            items: [
              for (final floor in floors)
                DropdownMenuItem<int>(
                  value: floor.mapId,
                  child: Text(
                    floor.mapName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
