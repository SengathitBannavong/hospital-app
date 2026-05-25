import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/util_repository.dart';

final utilRepositoryProvider = Provider<UtilRepository>((ref) {
  return UtilRepository();
});

final weatherSummaryProvider = FutureProvider<UtilitySnapshot>((ref) {
  return ref.watch(utilRepositoryProvider).getWeather();
});

final parkingSummaryProvider = FutureProvider<UtilitySnapshot>((ref) {
  return ref.watch(utilRepositoryProvider).getParking();
});
