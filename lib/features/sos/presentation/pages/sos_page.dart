// lib/features/sos/presentation/pages/sos_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import '../../data/models/sos_detail.dart';
import '../providers/sos_provider.dart';

class SosPage extends ConsumerStatefulWidget {
  const SosPage({super.key});

  @override
  ConsumerState<SosPage> createState() => _SosPageState();
}

class _SosPageState extends ConsumerState<SosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sosProvider.notifier).loadDetail();
    });
  }

  Future<void> _handleSos() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận SOS'),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn gửi tín hiệu SOS không?\n\n'
          'Nhân viên y tế sẽ được điều phối đến vị trí của bạn ngay lập tức.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Gửi SOS'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref.read(sosProvider.notifier).sendSos();
    if (!mounted) return;

    final state = ref.read(sosProvider);
    if (success && state.successMessage != null) {
      AppToast.showSuccess(state.successMessage!);
    } else if (state.errorMessage != null) {
      AppToast.showError(state.errorMessage!);
    }
    ref.read(sosProvider.notifier).clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS — Khẩn Cấp'),
        actions: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Tải lại',
              onPressed: () => ref.read(sosProvider.notifier).loadDetail(),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(sosProvider.notifier).loadDetail(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              _SosHeroButton(
                isActive: state.hasActiveSos,
                isSending: state.isSending,
                onPressed: state.isSending ? null : _handleSos,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (state.detail != null)
                _SosStatusCard(detail: state.detail!)
              else
                _SosInfoCard(),
              const SizedBox(height: AppSpacing.xxl),
              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: context.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Lưu ý', style: context.textTheme.titleSmall),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '• Chỉ sử dụng khi thực sự có tình huống khẩn cấp.\n'
                        '• Nhân viên y tế sẽ đến trong thời gian sớm nhất.\n'
                        '• Nếu cần trợ giúp ngay, hãy gọi quầy lễ tân.',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosHeroButton extends StatelessWidget {
  const _SosHeroButton({
    required this.isActive,
    required this.isSending,
    required this.onPressed,
  });

  final bool isActive;
  final bool isSending;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Colors.orange
                    : isSending
                    ? Colors.red.shade300
                    : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (isActive ? Colors.orange : Colors.red).withOpacity(
                      0.4,
                    ),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: isSending
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isActive
                ? 'Đang có yêu cầu khẩn cấp'
                : isSending
                ? 'Đang gửi tín hiệu...'
                : 'Nhấn để gửi tín hiệu khẩn cấp',
            style: context.textTheme.bodyMedium?.copyWith(
              color: isActive ? Colors.orange : context.colorScheme.onSurface,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _SosStatusCard extends StatelessWidget {
  const _SosStatusCard({required this.detail});
  final SosDetail detail;

  @override
  Widget build(BuildContext context) {
    final isActive = detail.status == SosStatus.active;
    final color = isActive ? Colors.orange : Colors.green;
    final icon = isActive ? Icons.pending_rounded : Icons.check_circle_rounded;
    final statusText = isActive ? 'Đang xử lý' : 'Đã giải quyết';

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppSpacing.sm),
                Text('Trạng thái yêu cầu', style: context.textTheme.titleSmall),
                const Spacer(),
                Chip(
                  label: Text(statusText),
                  backgroundColor: color.withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: color, fontSize: 12),
                  side: BorderSide.none,
                ),
              ],
            ),
            if (detail.createdAt.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Gửi lúc: ${detail.createdAt}',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SosInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Icon(
              Icons.health_and_safety_rounded,
              color: context.colorScheme.primary,
              size: 36,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Không có yêu cầu khẩn cấp',
                    style: context.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nhấn nút SOS phía trên nếu bạn cần hỗ trợ y tế khẩn cấp.',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
