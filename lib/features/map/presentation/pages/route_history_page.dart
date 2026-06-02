import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/map/data/models/route_history_entry.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

class RouteHistoryPage extends ConsumerWidget {
  const RouteHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(routeHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/map'),
        ),
        title: const Text('Lịch sử tuyến đường'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: () => ref.invalidate(routeHistoryProvider),
          ),
          history.when(
            data: (h) => h.routes.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded),
                    tooltip: 'Xóa lịch sử',
                    onPressed: () => _confirmClear(context, ref),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(routeHistoryProvider),
        ),
        data: (h) {
          if (h.routes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 56,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Chưa có lịch sử tuyến đường',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: AppSpacing.pageWithTop,
            itemCount: h.routes.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) =>
                _HistoryCard(entry: h.routes[index]),
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa lịch sử'),
        content: const Text(
          'Bạn có chắc muốn xóa toàn bộ lịch sử tuyến đường?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(mapRepositoryProvider).clearRouteHistory();
      ref.invalidate(routeHistoryProvider);
      AppToast.showSuccess('Đã xóa lịch sử tuyến đường');
    } catch (e) {
      AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

class _HistoryCard extends ConsumerWidget {
  const _HistoryCard({required this.entry});

  final RouteHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = entry.createdAt?.toLocal();
    String? dateStr;
    if (date != null) {
      final d = date.day.toString().padLeft(2, '0');
      final mo = date.month.toString().padLeft(2, '0');
      final h = date.hour.toString().padLeft(2, '0');
      final mi = date.minute.toString().padLeft(2, '0');
      dateStr = '$d/$mo/${date.year} $h:$mi';
    }
    // route/rate and route/share require the backend route_id. The DB row id
    // (entry.id) is NOT a valid route_id, so we never fall back to it.
    final routeId = entry.routeId?.trim();

    return Card(
      child: ListTile(
        contentPadding: AppSpacing.cardPadding,
        leading: CircleAvatar(
          backgroundColor: context.colorScheme.primaryContainer,
          child: Icon(Icons.route_rounded, color: context.colorScheme.primary),
        ),
        title: Text(
          entry.displayName,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.modeId != null)
              Text(
                'Chế độ: ${entry.modeId}',
                style: context.textTheme.bodySmall,
              ),
            if (dateStr != null)
              Text(dateStr, style: context.textTheme.bodySmall),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, size: 20),
          onSelected: (value) => _handleAction(context, ref, value, routeId),
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'rate',
              child: Row(
                children: [
                  Icon(Icons.star_outline_rounded),
                  SizedBox(width: 8),
                  Text('Đánh giá'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share_outlined),
                  SizedBox(width: 8),
                  Text('Chia sẻ'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => context.push('/map'),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    String? routeId,
  ) async {
    // Without a backend route_id, neither rate nor share can be called.
    if (routeId == null || routeId.isEmpty) {
      AppToast.showError(
        'Tuyến đường này thiếu mã (route_id) nên không thể '
        'đánh giá hoặc chia sẻ.',
      );
      return;
    }

    if (action == 'rate') {
      context.push('/route/rate/$routeId');
    } else if (action == 'share') {
      try {
        final url = await ref
            .read(mapRepositoryProvider)
            .shareRoute(routeId: routeId);
        await Clipboard.setData(ClipboardData(text: url));
        AppToast.showSuccess('Đã sao chép link chia sẻ!');
      } catch (e) {
        AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
