import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';

import '../providers/sos_provider.dart';

class SosPage extends ConsumerStatefulWidget {
  const SosPage({super.key});

  @override
  ConsumerState<SosPage> createState() => _SosPageState();
}

class _SosPageState extends ConsumerState<SosPage> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _sendSos() async {
    await ref
        .read(sosProvider.notifier)
        .sendRequest(reason: _reasonController.text.trim());

    final state = ref.read(sosProvider);
    if (state.wasSent && mounted) {
      AppToast.showSuccess(state.message ?? 'Đã gửi SOS.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS khẩn cấp'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: AppSpacing.cardPaddingLarge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gửi yêu cầu hỗ trợ khẩn cấp',
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Dùng khi bạn cần hỗ trợ ngay từ đội ngũ bệnh viện.',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Lý do hỗ trợ',
                hintText: 'Ví dụ: cần hỗ trợ di chuyển, đau đột ngột...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: sosState.isSending ? null : _sendSos,
              icon: sosState.isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.emergency_rounded),
              label: Text(sosState.isSending ? 'Đang gửi...' : 'Gửi SOS'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (sosState.message != null)
              Text(
                sosState.message!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: sosState.wasSent ? AppColors.success : AppColors.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
