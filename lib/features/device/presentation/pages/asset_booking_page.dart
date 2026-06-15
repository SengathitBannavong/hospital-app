import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/device/data/repository/asset_repository.dart';
import 'package:hospital_app/features/device/presentation/providers/asset_providers.dart';
import 'package:hospital_app/features/device/presentation/widgets/release_station_picker.dart';

class AssetBookingPage extends ConsumerStatefulWidget {
  const AssetBookingPage({super.key, required this.assetId});

  final String assetId;

  @override
  ConsumerState<AssetBookingPage> createState() => _AssetBookingPageState();
}

class _AssetBookingPageState extends ConsumerState<AssetBookingPage> {
  bool _isLoading = false;

  // Official backend asset statuses: available | in_use | maintenance.
  //   available   -> bookable
  //   in_use      -> in use (by this user or someone else)
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
      await ref.read(activeBookingProvider.notifier).book(widget.assetId);
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showSuccess(context.l10n.abBookSuccess(widget.assetId));
        ref
          ..invalidate(assetStationsProvider)
          ..invalidate(assetHealthProvider(widget.assetId));
      }
    } on AlreadyBookingException catch (e) {
      // The server says we already hold a wheelchair, but locally we don't know
      // which (e.g. booked on another phone). Recover it, then send the user to
      // the "my wheelchair" screen to track/release it.
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.showWarning(e.message);
      final candidates = await ref
          .read(activeBookingProvider.notifier)
          .recover();
      if (mounted && candidates.isNotEmpty) context.push('/asset/my');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _release() async {
    final stationId = await showReleaseStationPicker(context, ref);
    if (stationId == null || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(activeBookingProvider.notifier)
          .release(assetId: widget.assetId, stationId: stationId);
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showSuccess(context.l10n.mwReleaseSuccess);
        ref
          ..invalidate(assetStationsProvider)
          ..invalidate(assetHealthProvider(widget.assetId));
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
    final status = health.valueOrNull?.status;
    final isMine = ref.watch(
      activeBookingProvider.select((b) => b?.assetId == widget.assetId),
    );

    // The local active-booking flag is the source of truth for "this is mine"
    // (the backend exposes no booked_by). Server status only drives display:
    // maintenance, or in-use by *someone else* (which must not offer release).
    final isMaintenance = _isMaintenanceStatus(status);
    final isBooked = isMine;
    final isUsedByOther = !isMine && !isMaintenance && _isInUseStatus(status);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(context.l10n.abTitle(widget.assetId)),
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
                        context.l10n.abDeviceInfo,
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _Row(
                        label: context.l10n.trackAssetCode,
                        value: info.assetId,
                      ),
                      _Row(
                        label: context.l10n.trackStatus,
                        value: info.status,
                      ),
                      if (info.condition != null)
                        _Row(
                          label: context.l10n.trackCondition,
                          value: info.condition!,
                        ),
                      if (info.batteryLevel != null)
                        _Row(
                          label: context.l10n.trackBattery,
                          value: info.batteryLevel!,
                        ),
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
                label: Text(context.l10n.mwReportBroken),
              ),
            ] else if (isUsedByOther) ...[
              const _InUseByOtherNotice(),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/asset/report/${widget.assetId}'),
                icon: const Icon(Icons.report_problem_outlined),
                label: Text(context.l10n.mwReportBroken),
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
                label: Text(context.l10n.abBookDevice),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/asset/report/${widget.assetId}'),
                icon: const Icon(Icons.report_problem_outlined),
                label: Text(context.l10n.mwReportBroken),
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
                label: Text(context.l10n.homeReturnDevice),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => context.push('/asset/track/${widget.assetId}'),
                icon: const Icon(Icons.location_on_outlined),
                label: Text(context.l10n.mwTrackLocation),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: () =>
                    context.push('/asset/report/${widget.assetId}'),
                icon: const Icon(Icons.report_problem_outlined),
                label: Text(context.l10n.mwReportBroken),
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
                    context.l10n.abMaintenanceTitle,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.abMaintenanceBody,
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

class _InUseByOtherNotice extends StatelessWidget {
  const _InUseByOtherNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_clock_outlined,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.abInUseTitle,
                    style: context.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.abInUseBody,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
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
