import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/util/data/models/about_info.dart';
import 'package:hospital_app/features/util/data/models/contact_info.dart';
import 'package:hospital_app/features/util/data/models/faq_item.dart';
import 'package:hospital_app/features/util/data/models/feedback_summary.dart';
import 'package:hospital_app/features/util/data/models/language_option.dart';
import 'package:hospital_app/features/util/data/models/util_poi.dart';
import 'package:hospital_app/features/util/data/models/weather.dart';
import 'package:hospital_app/features/util/data/repository/util_repository.dart';

final utilRepositoryProvider = Provider<UtilRepository>((ref) {
  return UtilRepository();
});

final aboutProvider = FutureProvider<AboutInfo>((ref) {
  return ref.watch(utilRepositoryProvider).getAbout();
});

final contactProvider = FutureProvider<ContactInfo>((ref) {
  return ref.watch(utilRepositoryProvider).getContact();
});

final faqProvider = FutureProvider.family<List<FaqItem>, String?>((
  ref,
  category,
) {
  return ref.watch(utilRepositoryProvider).getFaq(category: category);
});

final feedbackSummaryProvider = FutureProvider<FeedbackSummary>((ref) {
  return ref.watch(utilRepositoryProvider).getFeedbackSummary();
});

final languagesProvider = FutureProvider<List<LanguageOption>>((ref) {
  return ref.watch(utilRepositoryProvider).getLanguages();
});

final weatherProvider = FutureProvider<Weather>((ref) {
  return ref.watch(utilRepositoryProvider).getWeather();
});

final pharmacyProvider = FutureProvider<List<UtilPoi>>((ref) {
  return ref.watch(utilRepositoryProvider).getPharmacy();
});

final canteenProvider = FutureProvider<List<UtilPoi>>((ref) {
  return ref.watch(utilRepositoryProvider).getCanteen();
});

final parkingProvider = FutureProvider<List<UtilPoi>>((ref) {
  return ref.watch(utilRepositoryProvider).getParking();
});

final wifiProvider = FutureProvider<List<UtilPoi>>((ref) {
  return ref.watch(utilRepositoryProvider).getWifi();
});
