part of '../../pages/map_page.dart';

class _MapStatusCluster extends StatelessWidget {
  final AsyncValue<FlowSnapshot> snapshot;
  final bool? isOnline;
  final DateTime? lastSyncedAt;
  final LocationSource locationSource;
  final String? notice;
  final VoidCallback onRetry;

  const _MapStatusCluster({
    required this.snapshot,
    required this.isOnline,
    required this.lastSyncedAt,
    required this.locationSource,
    required this.notice,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final flow = snapshot.valueOrNull;
    final isLoading = snapshot.isLoading && flow == null;
    final isError = snapshot.hasError && flow == null;
    final isStale = flow?.isStale ?? false;
    final hasAlert = flow?.alerts.isNotEmpty ?? false;
    final online = isOnline;

    final network = _statusForNetwork(
      scheme: scheme,
      online: online,
      isStale: isStale,
    );
    final data = _statusForData(
      scheme: scheme,
      online: online,
      isLoading: isLoading,
      isError: isError,
      hasAlert: hasAlert,
      isStale: isStale,
      lastSyncedAt: lastSyncedAt,
    );
    final position = _statusForPosition(
      scheme: scheme,
      locationSource: locationSource,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _StatusPill(data: network),
              _StatusPill(data: data, onTap: isError ? onRetry : null),
              _StatusPill(data: position),
            ],
          ),
          if (notice != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _StatusPill(
              data: _PillData(
                icon: Icons.info_outline_rounded,
                label: notice!,
                background: scheme.surfaceContainerHigh,
                foreground: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _PillData _statusForNetwork({
    required ColorScheme scheme,
    required bool? online,
    required bool isStale,
  }) {
    if (online == false || (online == null && isStale)) {
      return _PillData(
        icon: Icons.cloud_off_rounded,
        label: 'Offline',
        background: scheme.tertiaryContainer,
        foreground: scheme.onTertiaryContainer,
      );
    }
    if (online == null) {
      return _PillData(
        icon: Icons.sync_rounded,
        label: 'Checking',
        background: scheme.surfaceContainerHigh,
        foreground: scheme.onSurfaceVariant,
      );
    }
    return _PillData(
      icon: Icons.cloud_done_rounded,
      label: 'Online',
      background: scheme.surfaceContainerHigh,
      foreground: scheme.onSurfaceVariant,
    );
  }

  _PillData _statusForData({
    required ColorScheme scheme,
    required bool? online,
    required bool isLoading,
    required bool isError,
    required bool hasAlert,
    required bool isStale,
    required DateTime? lastSyncedAt,
  }) {
    final syncLabel = _formatSyncAge(lastSyncedAt);
    if (isError) {
      return _PillData(
        icon: Icons.error_outline_rounded,
        label: 'Sync error',
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
      );
    }
    if (online == false || isStale) {
      return _PillData(
        icon: Icons.storage_rounded,
        label: syncLabel == null ? 'Cache data' : 'Cache $syncLabel',
        background: scheme.tertiaryContainer,
        foreground: scheme.onTertiaryContainer,
      );
    }
    if (hasAlert) {
      return _PillData(
        icon: Icons.warning_amber_rounded,
        label: 'Flow alert',
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
      );
    }
    if (isLoading) {
      return _PillData(
        icon: Icons.sync_rounded,
        label: 'Syncing',
        background: scheme.surfaceContainerHigh,
        foreground: scheme.onSurfaceVariant,
      );
    }
    return _PillData(
      icon: Icons.check_circle_outline_rounded,
      label: syncLabel == null ? 'Data live' : 'Live $syncLabel',
      background: scheme.surfaceContainerHigh,
      foreground: scheme.onSurfaceVariant,
    );
  }

  _PillData _statusForPosition({
    required ColorScheme scheme,
    required LocationSource locationSource,
  }) {
    final label = switch (locationSource) {
      LocationSource.qr => 'Position QR',
      LocationSource.manual => 'Position local',
      LocationSource.simulatedPin => 'Position pin',
      LocationSource.entranceDefault => 'Position default',
    };
    return _PillData(
      icon: Icons.my_location_rounded,
      label: label,
      background: scheme.surfaceContainerHigh,
      foreground: scheme.onSurfaceVariant,
    );
  }

  String? _formatSyncAge(DateTime? value) {
    if (value == null) {
      return null;
    }
    final delta = DateTime.now().difference(value.toLocal());
    if (delta.inMinutes < 1) {
      return 'now';
    }
    if (delta.inHours < 1) {
      return '${delta.inMinutes}m';
    }
    if (delta.inDays < 1) {
      return '${delta.inHours}h';
    }
    return '${delta.inDays}d';
  }
}
