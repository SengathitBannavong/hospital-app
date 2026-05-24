// lib/features/notification/presentation/pages/notification_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import '../providers/notification_provider.dart';
import '../providers/notification_state.dart';
import '../widgets/notification_tile.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(notificationProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref
        .read(notificationProvider.notifier)
        .loadNotifications(refresh: true);
  }

  void _onTapNotification(int id) {
    ref.read(notificationProvider.notifier).markAsRead(id);
  }

  void _onDeleteNotification(int id) {
    ref.read(notificationProvider.notifier).deleteNotification(id);
    AppToast.showSuccess('Đã xóa thông báo');
  }

  Future<void> _markAllRead() async {
    await ref.read(notificationProvider.notifier).markAllAsRead();
    AppToast.showSuccess('Đã đọc tất cả thông báo');
  }

  // ── Safe back navigation ─────────────────────────────────────────────────
  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Thông báo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (state.unreadCount > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${state.unreadCount}',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        // ── Fixed back button ──────────────────────────────────────────────
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _goBack,
        ),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Đọc tất cả'),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cài đặt thông báo',
            onPressed: () => context.push('/notification-settings'),
          ),
        ],
      ),
      body: _buildBody(state, cs),
    );
  }

  Widget _buildBody(NotificationState state, ColorScheme cs) {
    if (state.status == NotificationStatus.loading &&
        state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == NotificationStatus.error &&
        state.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 56, color: cs.outline),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.errorMessage ?? 'Không thể tải thông báo',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == NotificationStatus.loaded &&
        state.notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: cs.outline,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Không có thông báo nào',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            state.notifications.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 0.5,
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) {
          if (index == state.notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          final notif = state.notifications[index];
          return NotificationTile(
            notification: notif,
            onTap: () => _onTapNotification(notif.id),
            onDelete: () => _onDeleteNotification(notif.id),
          );
        },
      ),
    );
  }
}