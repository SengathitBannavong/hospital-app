/// A single saved search from the user's history
/// (`GET /api/map/get_search_history`).
///
/// The backend stores what the user searched for plus the result they landed
/// on, so the tile can show the human-readable [resultName] when present and
/// fall back to the raw [keyword]. Parsing is defensive: only [keyword] is
/// guaranteed, every other field is optional.
class SearchHistoryEntry {
  const SearchHistoryEntry({
    required this.keyword,
    this.id,
    this.mapId,
    this.poiId,
    this.resultName,
    this.createdAt,
  });

  final String keyword;
  final int? id;
  final int? mapId;
  final int? poiId;
  final String? resultName;
  final DateTime? createdAt;

  /// What to show in the list — the resolved place name if the search landed
  /// on one, otherwise the raw keyword.
  String get displayLabel {
    final name = resultName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return keyword;
  }

  factory SearchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SearchHistoryEntry(
      keyword: json['keyword']?.toString() ?? json['query']?.toString() ?? '',
      id: _parseInt(json['id']),
      mapId: _parseInt(json['map_id'] ?? json['floor_id']),
      poiId: _parseInt(json['poi_id']),
      resultName:
          json['result_name']?.toString() ?? json['poi_name']?.toString(),
      createdAt: DateTime.tryParse(
        json['created_at']?.toString() ?? json['searched_at']?.toString() ?? '',
      ),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

/// Paginated search history: `{ items, total, page, limit }`.
class SearchHistory {
  const SearchHistory({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 20,
  });

  final List<SearchHistoryEntry> items;
  final int total;
  final int page;
  final int limit;

  bool get isEmpty => items.isEmpty;

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['data'] ?? const [];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (e) =>
                    SearchHistoryEntry.fromJson(Map<String, dynamic>.from(e)),
              )
              .where((e) => e.keyword.isNotEmpty || e.resultName != null)
              .toList()
        : <SearchHistoryEntry>[];
    return SearchHistory(
      items: items,
      total: SearchHistoryEntry._parseInt(json['total']) ?? items.length,
      page: SearchHistoryEntry._parseInt(json['page']) ?? 1,
      limit: SearchHistoryEntry._parseInt(json['limit']) ?? 20,
    );
  }
}
