import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/staff/data/repository/staff_repository.dart';

final staffRepositoryProvider = Provider<StaffRepository>((_) {
  return StaffRepository();
});
