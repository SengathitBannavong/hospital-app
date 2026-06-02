import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/device/presentation/providers/asset_providers.dart';

class AssetBookingPage extends ConsumerStatefulWidget {
  const AssetBookingPage({super.key, required this.assetId});

  final String assetId;

  @override
  ConsumerState<AssetBookingPage> createState() => _AssetBookingPageState();
}

class _AssetBookingPageState extends ConsumerState<AssetBookingPage> {
  bool _isLoading = false;

  // Null until the user books/releases in this session. While null, the booked
  // state is derived from the asset's server health status so re-opening the
  // page for an already-booked asset doesn't invite a double book.
  bool? _bookedOverride;

  // Official backend asset statuses: available | in_use | maintenance.
  //   available   -> bookable
  //   in_use      -> currently booked / in use
  //   maintenance -> unavailable (not bookable, not booked)
  static const _statusInUse = 'in_use';
  static const _statusMaintenance = 'maintenance';

  static bool _isInUseStatus(String? status) =>
      status?.toLowerCase() == _statusInUse;

  static bool _isMaintenanceStatus(String? status) =>
      status?.toLowerCase() == _statusMaintenance;

  Future<void> _book() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(assetRepositoryProvider).bookAsset(widget.assetId);
      if (mounted) {
        setState(() {
          _bookedOverride = true;
          _isLoading = false;
        });
        AppToast.showSuccess('Đã mượn thiết bị ${widget.assetId} thành công!');
        ref.invalidate(assetStationsProvider);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _release() async {
    final stationIdController = TextEditingController();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Trả thiết bị'),
          content: TextField(
            controller: stationIdController,
            decoration: const InputDecoration(
              labelText: 'Mã trạm trả (station_id)',
              hintText: 'vd: 1',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
      final stationId = stationIdController.text.trim();
      if (stationId.isEmpty) return;

      setState(() => _isLoading = true);
      try {
        await ref
            .read(assetRepositoryProvider)
            .releaseAsset(assetId: widget.assetId, stationId: stationId);
        if (mounted) {
          setState(() {
            _bookedOverride = false;
            _isLoading = false;
          });
          AppToast.showSuccess('Đã trả thiết bị thành công!');
          ref.invalidate(assetStationsProvider);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
        }
      }
    } finally {
      stationIdController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(assetHealthProvider(widget.assetId));
    final status = health.valueOrNull?.status;

    // A local book/release action wins; otherwise fall back to the server's
    // status so an already-booked asset shows the release flow on re-open.
    // Maintenance is a server-only state — a local action can't reach it.
    final isMaintenance =
        _bookedOverride == null && _isMaintenanceStatus(status);
    final isBooked = _bookedOverride ?? _isInUseStatus(status);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text('Thiết bị ${widget.assetId}'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pageWithTop,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            health.when(
              loading: () => const Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (info) => Card(
                child: Padding(
                  padding: AppSpacing.cardPaddingLarge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin thiết bị',
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _Row(label: 'Mã thiết bị', value: info.assetId),
                      _Row(label: 'Trạng thái', value: info.status),
                      if (info.condition != null)
                        _Row(label: 'Tình trạng', value: info.condition!),
                      if (info.batteryLevel != null)
                        _Row(label: 'Pin', value: info.batteryLevel!),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (isMaintenance) ...[
              const _MaintenanceNotice(),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/asset/report/${widget.assetId}'),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Báo hỏng'),
              ),
            ] else if (!isBooked) ...[
              FilledButton.icon(
                onPressed: _isLoading ? null : _book,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
                label: const Text('Mượn thiết bị'),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/asset/report/${widget.assetId}'),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Báo hỏng'),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: _isLoading ? null : _release,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout_rounded),
                label: const Text('Trả thiết bị'),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => context.push('/asset/track/${widget.assetId}'),
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Theo dõi vị trí'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: () =>
                    context.push('/asset/report/${widget.assetId}'),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Báo hỏng'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MaintenanceNotice extends StatelessWidget {
  const _MaintenanceNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.errorContainer,
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.build_circle_outlined,
              color: context.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thiết bị đang bảo trì',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Thiết bị này tạm thời không khả dụng để mượn. '
                    'Vui lòng chọn thiết bị khác.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onErrorContainer,
                    ),
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

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
