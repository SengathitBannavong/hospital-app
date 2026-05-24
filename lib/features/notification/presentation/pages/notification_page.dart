import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final unreadCount = notificationState.items
        .where((item) => !item.isRead)
        .length;
    final showBanner =
        notificationState.errorMessage != null && notificationState.hasItems;

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo ($unreadCount)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: notificationState.items.isEmpty
                ? null
                : () async {
                    try {
                      await ref
                          .read(notificationProvider.notifier)
                          .markAllAsRead();
                    } catch (error) {
                      AppToast.showError(_formatError(error));
                    }
                  },
          ),
        ],
      ),
      body: _buildBody(state: notificationState, showBanner: showBanner),
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
        onRefresh: () => ref
            .read(notificationProvider.notifier)
            .refresh()
            .catchError((error) {
              AppToast.showError(_formatError(error));
            }),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pageWithTop,
          children: const [
            SizedBox(height: AppSpacing.xxl),
            Center(child: Text('Không có thông báo nào')),
          ],
        ),
      );
    }

    final displayCount = state.items.length + 1 + (showBanner ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(notificationProvider.notifier).refresh().catchError((error) {
            AppToast.showError(_formatError(error));
          }),
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
                try {
                  await ref
                      .read(notificationProvider.notifier)
                      .deleteNotifications([item.id]);
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

  Widget _buildInlineErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationProvider.notifier).refresh().catchError((
                error,
              ) {
                AppToast.showError(_formatError(error));
              });
            },
            child: const Text('Thử lại'),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: Text('Đã tải hết thông báo')),
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
            const Text('Không thể tải thông báo'),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(notificationProvider.notifier).refresh().catchError((
                  error,
                ) {
                  AppToast.showError(_formatError(error));
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
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
