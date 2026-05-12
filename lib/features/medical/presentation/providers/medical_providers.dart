import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/medical_task.dart';
import '../../data/models/prescription.dart';
import '../../data/models/queue_status.dart';
import '../../data/models/result_status.dart';
import '../../data/models/room_open.dart';
import '../../data/repository/medical_repository.dart';

final medicalRepositoryProvider = Provider<MedicalRepository>((ref) {
  return MedicalRepository();
});

final medicalTasksProvider = FutureProvider<List<MedicalTask>>((ref) async {
  final repository = ref.watch(medicalRepositoryProvider);
  return repository.getTasks();
});

final medicalHistoryProvider = FutureProvider<List<MedicalTask>>((ref) async {
  final repository = ref.watch(medicalRepositoryProvider);
  return repository.getHistory();
});

final medicalQueueProvider = FutureProvider.family<QueueStatus?, int>((
  ref,
  poiId,
) async {
  final repository = ref.watch(medicalRepositoryProvider);
  return repository.getQueue(poiId: poiId);
});

final medicalRoomOpenProvider = FutureProvider.family<RoomOpen?, int>((
  ref,
  poiId,
) async {
  final repository = ref.watch(medicalRepositoryProvider);
  return repository.getRoomOpen(poiId: poiId);
});

final medicalResultStatusProvider = FutureProvider.family<ResultStatus?, int>((
  ref,
  treatmentId,
) async {
  final repository = ref.watch(medicalRepositoryProvider);
  return repository.getResultStatus(treatmentId: treatmentId);
});

final medicalPrescriptionProvider = FutureProvider<Prescription?>((ref) async {
  final repository = ref.watch(medicalRepositoryProvider);
  return repository.getPrescription();
});
