import 'package:flutter_riverpod/flutter_riverpod.dart';

class SosState {
  const SosState({this.isSending = false, this.wasSent = false, this.message});

  final bool isSending;
  final bool wasSent;
  final String? message;

  SosState copyWith({bool? isSending, bool? wasSent, String? message}) {
    return SosState(
      isSending: isSending ?? this.isSending,
      wasSent: wasSent ?? this.wasSent,
      message: message ?? this.message,
    );
  }
}

class SosNotifier extends StateNotifier<SosState> {
  SosNotifier() : super(const SosState());

  Future<void> sendRequest({required String reason}) async {
    state = state.copyWith(isSending: true, wasSent: false, message: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      state = state.copyWith(
        isSending: false,
        wasSent: true,
        message: reason.isEmpty
            ? 'Đã gửi SOS khẩn cấp.'
            : 'Đã gửi SOS: $reason',
      );
    } catch (error) {
      state = state.copyWith(
        isSending: false,
        wasSent: false,
        message: error.toString(),
      );
    }
  }
}

final sosProvider = StateNotifierProvider<SosNotifier, SosState>((ref) {
  return SosNotifier();
});
