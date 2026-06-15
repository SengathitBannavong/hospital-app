import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

/// Opens a searchable bottom-sheet of all POIs on the active map and returns
/// the chosen POI (or null if dismissed). Shared by the queue, wheelchair and
/// staff pages so users pick a location instead of typing a code.
Future<MapPoi?> showPoiPicker(
  BuildContext context, {
  String? title,
}) {
  final resolvedTitle = title ?? context.l10n.poiPickerDefaultTitle;
  return showModalBottomSheet<MapPoi>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PoiPickerSheet(title: resolvedTitle),
  );
}

/// A tappable field that shows the selected POI (or a placeholder) and opens
/// the picker when tapped.
class PoiPickerField extends StatelessWidget {
  const PoiPickerField({
    super.key,
    required this.onTap,
    this.selected,
    this.label,
    this.hint,
  });

  final VoidCallback onTap;
  final MapPoi? selected;
  final String? label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final poi = selected;
    final label = this.label ?? context.l10n.poiFieldLabel;
    final hint = this.hint ?? context.l10n.poiFieldHint;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderLg,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.location_on_outlined),
          suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
        ),
        child: Text(
          poi == null ? hint : '${poi.poiName} · ${poi.poiCode}',
          style: context.textTheme.bodyLarge?.copyWith(
            color: poi == null ? scheme.onSurfaceVariant : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _PoiPickerSheet extends ConsumerStatefulWidget {
  const _PoiPickerSheet({required this.title});

  final String title;

  @override
  ConsumerState<_PoiPickerSheet> createState() => _PoiPickerSheetState();
}

class _PoiPickerSheetState extends ConsumerState<_PoiPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final next = _controller.text.trim();
      if (next != _query) setState(() => _query = next);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<MapPoi> _filter(List<MapPoi> pois) {
    if (_query.isEmpty) return pois;
    final q = _query.toLowerCase();
    return pois
        .where(
          (p) =>
              p.poiName.toLowerCase().contains(q) ||
              p.poiCode.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Ensure a floor (mapId) is selected — floorsProvider sets it as a side
    // effect — then load that map's POIs.
    final floors = ref.watch(floorsProvider);
    final mapId = ref.watch(selectedFloorProvider);

    Widget body;
    if (floors.isLoading || (floors.hasValue && mapId == null)) {
      body = const Center(child: CircularProgressIndicator());
    } else if (floors.hasError) {
      body = Center(child: Text(context.l10n.poiLoadError));
    } else if (mapId == null) {
      body = Center(child: Text(context.l10n.poiNoMap));
    } else {
      body = ref
          .watch(mapNodesProvider(mapId))
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(e.toString().replaceFirst('Exception: ', '')),
            ),
            data: (pois) {
              final filtered = _filter(pois);
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    _query.isEmpty
                        ? context.l10n.poiEmpty
                        : context.l10n.poiNotFound(_query),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final poi = filtered[i];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(
                      poi.poiName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(poi.poiCode),
                    onTap: () => Navigator.pop(context, poi),
                  );
                },
              );
            },
          );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg + bottomInset,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.l10n.poiSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
