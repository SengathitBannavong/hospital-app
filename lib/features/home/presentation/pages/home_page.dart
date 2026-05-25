// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/medical_info_card.dart';
import '../../../../core/widgets/fade_slide_transition.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../notification/presentation/widgets/notification_badge.dart';
import '../../data/home_repository.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _homeRepository = HomeRepository();
  int _taskCount = 0;
  bool _isLoadingTasks = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    // Load real notifications on home page open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoadingTasks = true);
    try {
      final tasks = await _homeRepository.getTasks();
      if (mounted) setState(() => _taskCount = tasks.length);
    } catch (error) {
      if (mounted) {
        AppToast.showError(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoadingTasks = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) AppToast.showSuccess('Đã đăng xuất');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Watch real unread count from provider ──────────────────────────────
    final unreadCount = ref.watch(unreadCountProvider);
    final notifState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tải lại',
            onPressed: _isLoadingTasks ? null : _fetchTasks,
          ),
          IconButton(
            icon: Icon(
              context.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Giao diện',
            onPressed: () => themeController.toggleTheme(),
          ),
          IconButton(
            icon: const NotificationBadge(
              top: -6,
              right: -6,
              child: Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Thông báo',
            onPressed: () => context.push('/notification'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTasks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Welcome Card
              FadeSlideTransition(
                delay: const Duration(milliseconds: 50),
                child: Card(
                  child: Padding(
                    padding: AppSpacing.cardPaddingLarge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chào mừng bạn!',
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: context.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Sức khỏe của bạn là ưu tiên hàng đầu của chúng tôi. '
                          'Hệ thống đang hoạt động ổn định.',
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              FadeSlideTransition(
                delay: const Duration(milliseconds: 150),
                child: Text('Tổng quan', style: context.textTheme.titleMedium),
              ),
              const SizedBox(height: AppSpacing.md),

              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: MedicalInfoCard(
                  label: 'Nhiệm vụ hiện tại',
                  value: _isLoadingTasks
                      ? 'Đang tải...'
                      : '$_taskCount Hoạt động',
                  icon: Icons.assignment_rounded,
                  onTap: _fetchTasks,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Notification Section ──────────────────────────────────────
              const FadeSlideTransition(
                delay: Duration(milliseconds: 350),
                child: Text(
                  'Thông báo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              FadeSlideTransition(
                delay: const Duration(milliseconds: 400),
                child: Card(
                  child: ListTile(
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          unreadCount > 0
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_outlined,
                          color: context.colorScheme.primary,
                        ),
                        // Red dot badge if unread > 0
                        if (unreadCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              decoration: BoxDecoration(
                                color: context.colorScheme.error,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: TextStyle(
                                  color: context.colorScheme.onError,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Show real count — or loading — or "no notifications"
                    title: Text(
                      notifState.isLoading
                          ? 'Đang tải thông báo...'
                          : unreadCount > 0
                          ? 'Bạn có $unreadCount thông báo mới'
                          : 'Không có thông báo mới',
                    ),
                    subtitle: const Text('Nhấn để xem danh sách thông báo'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () => context.push('/notification'),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              FadeSlideTransition(
                delay: const Duration(milliseconds: 450),
                child: Text(
                  'Truy cập nhanh',
                  style: context.textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              FadeSlideTransition(
                delay: const Duration(milliseconds: 500),
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    _QuickActionCard(
                      title: 'Thông tin',
                      icon: Icons.info_outline_rounded,
                      onTap: () => context.push('/info'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              FadeSlideTransition(
                delay: const Duration(milliseconds: 450),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.borderLg,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.statusAvailable,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Tất cả hệ thống hoạt động bình thường',
                        style: context.textTheme.labelLarge,
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: InkWell(
          borderRadius: AppRadius.borderLg,
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              children: [
                Icon(icon, size: 32, color: context.colorScheme.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: context.textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
