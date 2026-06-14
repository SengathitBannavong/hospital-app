import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/device/presentation/providers/asset_providers.dart';
import 'package:hospital_app/features/device/presentation/widgets/release_station_picker.dart';

/// "Xe lăn của tôi" — shows the wheelchair the user currently holds (with track
/// + release), or, when the local store doesn't know about a booking, lets them
/// recover it from the backend's in-use state (works across phones / fresh
/// installs, since the booking is no longer purely device-local).
class MyWheelchairPage extends ConsumerStatefulWidget {
  const MyWheelchairPage({super.key});

  @override
  ConsumerState<MyWheelchairPage> createState() => _MyWheelchairPageState();
}

class _MyWheelchairPageState extends ConsumerState<MyWheelchairPage> {
  bool _isBusy = false;
  // Auto-recovery runs once on entry so a booking the local store doesn't know
  // about (reinstall / another phone) surfaces without the user tapping.
  bool _autoTried = false;
  bool _autoRecovering = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoRecover());
  }

  Future<void> _maybeAutoRecover() async {
    if (_autoTried) return;
    _autoTried = true;
    if (ref.read(activeBookingProvider) != null) return; // already known

    setState(() => _autoRecovering = true);
    try {
      // Silent: an empty result just shows the empty state, no error toast.
      await _recover(silent: true);
    } finally {
      if (mounted) setState(() => _autoRecovering = false);
    }
  }

  Future<void> _release(String assetId) async {
    final stationId = await showReleaseStationPicker(context, ref);
    if (stationId == null || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await ref
          .read(activeBookingProvider.notifier)
          .release(assetId: assetId, stationId: stationId);
      if (mounted) {
        setState(() => _isBusy = false);
        AppToast.showSuccess('Đã trả thiết bị thành công!');
        ref
          ..invalidate(assetStationsProvider)
          ..invalidate(assetHealthProvider(assetId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBusy = false);
        AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _recover({bool silent = false}) async {
    setState(() => _isBusy = true);
    try {
      final candidates = await ref
          .read(activeBookingProvider.notifier)
          .recover();
      if (!mounted) return;
      setState(() => _isBusy = false);

      if (candidates.isEmpty) {
        if (!silent) {
          AppToast.showWarning('Không tìm thấy lượt mượn nào của bạn.');
        }
      } else if (candidates.length == 1) {
        AppToast.showSuccess('Đã khôi phục lượt mượn: ${candidates.first}');
      } else {
        await _pickFromCandidates(candidates);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBusy = false);
        if (!silent) {
          AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
        }
      }
    }
  }

  Future<void> _pickFromCandidates(List<String> candidates) async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chọn xe lăn của bạn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Có nhiều xe lăn đang được mượn. Chọn đúng xe của bạn:',
            ),
            const SizedBox(height: AppSpacing.md),
            ...candidates.map(
              (id) => ListTile(
                leading: const Icon(Icons.accessible_rounded),
                title: Text(id),
                onTap: () => Navigator.pop(ctx, id),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
    if (chosen != null) {
      await ref.read(activeBookingProvider.notifier).adopt(chosen);
      if (mounted) AppToast.showSuccess('Đã chọn lượt mượn: $chosen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(activeBookingProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Xe lăn của tôi'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pageWithTop,
        child: booking != null
            ? _BookingView(
                assetId: booking.assetId,
                isBusy: _isBusy,
                onRelease: () => _release(booking.assetId),
              )
            : _autoRecovering
            ? const _RecoveringState()
            : _EmptyState(isBusy: _isBusy, onRecover: () => _recover()),
      ),
    );
  }
}

class _BookingView extends ConsumerWidget {
  const _BookingView({
    required this.assetId,
    required this.isBusy,
    required this.onRelease,
  });

  final String assetId;
  final bool isBusy;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(assetHealthProvider(assetId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: context.colorScheme.primaryContainer,
          child: Padding(
            padding: AppSpacing.cardPaddingLarge,
            child: Row(
              children: [
                Icon(
                  Icons.accessible_rounded,
                  size: 32,
                  color: context.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đang mượn · $assetId',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      health.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                        data: (info) => Text(
                          [
                            'Trạng thái: ${info.status}',
                            if (info.batteryLevel != null)
                              'Pin ${info.batteryLevel}',
                          ].join(' · '),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton.icon(
          onPressed: () => context.push('/asset/track/$assetId'),
          icon: const Icon(Icons.location_on_outlined),
          label: const Text('Theo dõi vị trí'),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: isBusy ? null : onRelease,
          icon: isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout_rounded),
          label: const Text('Trả thiết bị'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton.icon(
          onPressed: () => context.push('/asset/report/$assetId'),
          icon: const Icon(Icons.report_problem_outlined),
          label: const Text('Báo hỏng'),
        ),
      ],
    );
  }
}

class _RecoveringState extends StatelessWidget {
  const _RecoveringState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Đang kiểm tra lượt mượn của bạn...',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isBusy, required this.onRecover});

  final bool isBusy;
  final VoidCallback onRecover;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Icon(
          Icons.accessible_rounded,
          size: 56,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Bạn chưa mượn xe lăn nào',
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Nếu bạn đã mượn trên thiết bị khác, hãy khôi phục lượt mượn.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: () => context.push('/asset/search'),
          icon: const Icon(Icons.search_rounded),
          label: const Text('Tìm xe lăn'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: isBusy ? null : onRecover,
          icon: isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.restore_rounded),
          label: const Text('Khôi phục lượt mượn'),
        ),
      ],
    );
  }
}
