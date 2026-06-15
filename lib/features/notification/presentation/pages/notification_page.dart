// lib/features/notification/presentation/pages/notification_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/utils/app_toast.dart';
import '../providers/notification_provider.dart';
import '../providers/notification_state.dart';
import '../widgets/notification_card.dart';

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
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(notificationProvider.notifier).loadMore().catchError((error) {
        AppToast.showError(_formatError(error));
      });
    }
  }

  // ── Safe back navigation (works whether pushed or shown as a tab) ──────────
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
    final showBanner = state.errorMessage != null && state.hasItems;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _goBack,
        ),
        title: Row(
          children: [
            Text(
              context.l10n.homeNotificationsTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: context.l10n.notifMarkAllRead,
            onPressed: state.unreadCount == 0
                ? null
                : () async {
                    final l10n = context.l10n;
                    try {
                      await ref
                          .read(notificationProvider.notifier)
                          .markAllAsRead();
                      AppToast.showSuccess(l10n.notifAllRead);
                    } catch (error) {
                      AppToast.showError(_formatError(error));
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.l10n.notifSettings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _buildBody(state: state, showBanner: showBanner),
    );
  }

  Widget _buildBody({
    required NotificationState state,
    required bool showBanner,
  }) {
    if (state.isInitialLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isEmpty && state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    if (state.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pageWithTop,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Center(child: Text(context.l10n.notifEmpty)),
          ],
        ),
      );
    }

    final displayCount = state.items.length + 1 + (showBanner ? 1 : 0);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.pageWithTop,
        itemCount: displayCount,
        itemBuilder: (context, index) {
          if (showBanner && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildInlineErrorBanner(state.errorMessage!),
            );
          }

          final itemIndex = index - (showBanner ? 1 : 0);
          if (itemIndex == state.items.length) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: _buildFooter(state),
            );
          }

          final item = state.items[itemIndex];

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: NotificationCard(
              notification: item,
              onTap: () async {
                try {
                  await ref
                      .read(notificationProvider.notifier)
                      .markAsRead(item.id);
                } catch (error) {
                  AppToast.showError(_formatError(error));
                }
              },
              onDelete: () async {
                final l10n = context.l10n;
                try {
                  await ref
                      .read(notificationProvider.notifier)
                      .deleteNotifications([item.id]);
                  AppToast.showSuccess(l10n.notifDeleted);
                } catch (error) {
                  AppToast.showError(_formatError(error));
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _refresh() {
    return ref.read(notificationProvider.notifier).refresh().catchError((
      error,
    ) {
      AppToast.showError(_formatError(error));
    });
  }

  Widget _buildInlineErrorBanner(String message) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: cs.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: TextStyle(color: cs.onErrorContainer)),
          ),
          TextButton(
            onPressed: _refresh,
            child: Text(context.l10n.commonRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(NotificationState state) {
    if (state.isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: Text(context.l10n.notifAllLoaded)),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageWithTop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_rounded, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.notifLoadError),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }

  String _formatError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
