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
  bool _isBooked = false;

  Future<void> _book() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(assetRepositoryProvider).bookAsset(widget.assetId);
      if (mounted) {
        setState(() {
          _isBooked = true;
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
      await ref.read(assetRepositoryProvider).releaseAsset(
        assetId: widget.assetId,
        stationId: stationId,
      );
      if (mounted) {
        setState(() {
          _isBooked = false;
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
  }

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(assetHealthProvider(widget.assetId));

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
                      _Row(
                        label: 'Trạng thái',
                        value: info.status,
                      ),
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
            if (!_isBooked) ...[
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
                onPressed: () =>
                    context.push('/asset/track/${widget.assetId}'),
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
          Expanded(
            child: Text(value, style: context.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
