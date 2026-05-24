part of '../../pages/map_page.dart';

class _RoutePoiPickerSheet extends StatefulWidget {
  final String title;
  final List<MapPoi> pois;
  final Map<int, String> normalizedNames;

  const _RoutePoiPickerSheet({
    required this.title,
    required this.pois,
    required this.normalizedNames,
  });

  @override
  State<_RoutePoiPickerSheet> createState() => _RoutePoiPickerSheetState();
}

class _RoutePoiPickerSheetState extends State<_RoutePoiPickerSheet> {
  late final TextEditingController _controller;
  String _query = '';
  String? _cachedFilterKey;
  List<MapPoi> _cachedFiltered = const <MapPoi>[];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final next = _controller.text.trim();
    if (next == _query) return;
    setState(() => _query = next);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final scheme = context.colorScheme;
    final filteredPois = _filteredPois();

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
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: AppRadius.borderFull,
                ),
              ),
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
                decoration: const InputDecoration(
                  hintText: 'Search a place',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: filteredPois.isEmpty
                    ? Center(
                        child: Text(
                          _query.isEmpty
                              ? 'Start typing to find a place.'
                              : 'No matches for "$_query".',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredPois.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final poi = filteredPois[index];
                          final color = MapPoiPalette.colorFor(poi.poiType);
                          return ListTile(
                            leading: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            title: Text(
                              poi.poiName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${MapPoiPalette.labelFor(poi.poiType)} · '
                              '${poi.poiCode}',
                            ),
                            onTap: () => Navigator.pop(context, poi),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MapPoi> _filteredPois() {
    if (_query.isEmpty) return widget.pois;
    if (_cachedFilterKey == _query) return _cachedFiltered;
    final normalizedQuery = normalizeForSearch(_query);
    final result = widget.pois.where((poi) {
      final text =
          widget.normalizedNames[poi.poiId] ?? normalizeForSearch(poi.poiName);
      return text.contains(normalizedQuery);
    }).toList();
    _cachedFilterKey = _query;
    _cachedFiltered = result;
    return result;
  }
}
