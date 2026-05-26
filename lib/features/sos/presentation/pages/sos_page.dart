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
                onConfirm: state.isSending ? null : _handleSos,
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

class _SosHeroButton extends StatefulWidget {
  const _SosHeroButton({
    required this.isActive,
    required this.isSending,
    required this.onConfirm,
  });

  final bool isActive;
  final bool isSending;
  final VoidCallback? onConfirm;

  @override
  State<_SosHeroButton> createState() => _SosHeroButtonState();
}

class _SosHeroButtonState extends State<_SosHeroButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isHolding =>
      !widget.isActive && !widget.isSending && _controller.value > 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          duration: const Duration(milliseconds: 1200),
          vsync: this,
        )..addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
  }

  @override
  void didUpdateWidget(covariant _SosHeroButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSending || widget.isActive) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (widget.onConfirm == null || widget.isSending || widget.isActive) {
      return;
    }
    _controller.forward(from: 0);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (widget.onConfirm == null || widget.isSending || widget.isActive) {
      return;
    }
    if (_controller.value >= 1.0) {
      widget.onConfirm!();
    } else {
      _controller.reverse();
    }
  }

  void _handleLongPressCancel() {
    if (widget.onConfirm == null || widget.isSending || widget.isActive) {
      return;
    }
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final roleColor = widget.isActive
        ? AppColors.emergencyActive
        : widget.isSending
        ? AppColors.emergency.withValues(alpha: 0.7)
        : AppColors.emergency;
    final helperColor = widget.isActive
        ? AppColors.emergencyActive
        : context.colorScheme.onSurface;
    final helperText = widget.isActive
        ? 'Đang có yêu cầu khẩn cấp'
        : widget.isSending
        ? 'Đang gửi tín hiệu...'
        : 'Nhấn và giữ để gửi tín hiệu';

    return Center(
      child: Column(
        children: [
          Semantics(
            button: true,
            label: 'Gửi tín hiệu SOS',
            hint: 'Nhấn và giữ trong 1.2 giây để xác nhận',
            enabled: widget.onConfirm != null,
            child: GestureDetector(
              onTap: disableAnimations ? widget.onConfirm : null,
              onLongPressStart: disableAnimations
                  ? null
                  : _handleLongPressStart,
              onLongPressEnd: disableAnimations ? null : _handleLongPressEnd,
              onLongPressCancel: disableAnimations
                  ? null
                  : _handleLongPressCancel,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isHolding)
                    SizedBox(
                      width: 196,
                      height: 196,
                      child: CircularProgressIndicator(
                        value: _controller.value,
                        strokeWidth: 8,
                        backgroundColor: AppColors.emergencySurface,
                        color: AppColors.onEmergency,
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: roleColor,
                      boxShadow: [
                        BoxShadow(
                          color: roleColor.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: _SosHeroContent(
                      isActive: widget.isActive,
                      isSending: widget.isSending,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            helperText,
            style: context.textTheme.bodyMedium?.copyWith(
              color: helperColor,
              fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _SosHeroContent extends StatelessWidget {
  const _SosHeroContent({required this.isActive, required this.isSending});

  final bool isActive;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    if (isSending) {
      return Semantics(
        label: 'Đang gửi tín hiệu SOS',
        liveRegion: true,
        child: const Center(
          child: Icon(
            Icons.hourglass_top_rounded,
            color: AppColors.onEmergency,
            size: 52,
          ),
        ),
      );
    }

    if (isActive) {
      return Semantics(
        label: 'Đang có yêu cầu khẩn cấp, nhân viên đang được điều phối',
        liveRegion: true,
        child: const Center(
          child: Icon(
            Icons.priority_high_rounded,
            color: AppColors.onEmergency,
            size: 64,
          ),
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SOS',
            style: TextStyle(
              color: AppColors.onEmergency,
              fontSize: 52,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          SizedBox(height: 8),
          Icon(Icons.emergency_rounded, color: AppColors.onEmergency, size: 28),
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
    final color = isActive ? AppColors.emergencyActive : AppColors.taskDone;
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
