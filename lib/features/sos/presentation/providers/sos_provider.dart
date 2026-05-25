// lib/features/sos/presentation/providers/sos_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sos_detail.dart';
import '../../data/repository/sos_repository.dart';

class SosState {
  const SosState({
    this.detail,
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
    this.successMessage,
  });

  final SosDetail? detail;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final String? successMessage;

  bool get hasActiveSos => detail != null && detail!.status == SosStatus.active;

  SosState copyWith({
    SosDetail? detail,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    String? successMessage,
    bool clearDetail = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SosState(
      detail: clearDetail ? null : (detail ?? this.detail),
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

final sosRepositoryProvider = Provider<SosRepository>((_) => SosRepository());

class SosNotifier extends StateNotifier<SosState> {
  SosNotifier(this._repository) : super(const SosState());

  final SosRepository _repository;

  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _repository.getSosDetail();
      state = state.copyWith(detail: detail, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _fmt(e));
    }
  }

  Future<bool> sendSos() async {
    state = state.copyWith(
      isSending: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await _repository.createSos();
      final detail = await _repository.getSosDetail();
      state = state.copyWith(
        isSending: false,
        detail: detail,
        successMessage: 'Đã gửi tín hiệu SOS. Nhân viên đang trên đường đến!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, errorMessage: _fmt(e));
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  String _fmt(Object e) => e.toString().replaceFirst('Exception: ', '');
}

final sosProvider = StateNotifierProvider<SosNotifier, SosState>((ref) {
  final repo = ref.watch(sosRepositoryProvider);
  final notifier = SosNotifier(repo);
  notifier.loadDetail();
  return notifier;
});
