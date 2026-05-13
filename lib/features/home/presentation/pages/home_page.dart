import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/medical_info_card.dart';
import '../../../../core/widgets/fade_slide_transition.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/home_repository.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _homeRepository = HomeRepository();
  int _counter = 0;
  int _taskCount = 0;
  bool _isLoadingTasks = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final tasks = await _homeRepository.getTasks();
      if (mounted) {
        setState(() {
          _taskCount = tasks.length;
        });
      }
    } catch (error) {
      if (mounted) {
        AppToast.showError(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTasks = false;
        });
      }
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
      if (mounted) {
        AppToast.showSuccess('Đã đăng xuất');
        // GoRouter will automatically redirect to /login due to authState change
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tải lại',
            onPressed: _isLoadingTasks ? null : _fetchTasks,
          ),
          // Theme Toggle Button
          IconButton(
            icon: Icon(
              context.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Giao diện',
            onPressed: () {
              themeController.toggleTheme();
            },
          ),
          // Logout Button
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
                  onTap: () {
                    _fetchTasks();
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              FadeSlideTransition(
                delay: const Duration(milliseconds: 250),
                child: MedicalInfoCard(
                  label: 'Lịch hẹn hôm nay',
                  value: '$_counter Lịch hẹn',
                  icon: Icons.calendar_month_rounded,
                  onTap: () {
                    debugPrint('Tapped appointments card');
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              FadeSlideTransition(
                delay: const Duration(milliseconds: 270),
                child: MedicalInfoCard(
                  label: 'Dịch vụ thiết bị',
                  value: 'Mượn xe lăn & thiết bị',
                  icon: Icons.accessible_rounded,
                  onTap: () => context.go('/device'),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              FadeSlideTransition(
                delay: const Duration(milliseconds: 290),
                child: MedicalInfoCard(
                  label: 'Hỗ trợ & Thông báo',
                  value: 'SOS & Chat Support',
                  icon: Icons.support_agent_rounded,
                  color: AppColors.error,
                  onTap: () => context.go('/support'),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              const FadeSlideTransition(
                delay: Duration(milliseconds: 300),
                child: MedicalInfoCard(
                  label: 'Bác sĩ sẵn sàng',
                  value: '42 Chuyên gia',
                  icon: Icons.medical_services_rounded,
                  color: AppColors.secondary,
                ),
              ),

              const SizedBox(height: AppSpacing.md),
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
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            AppToast.showSuccess('Đặt lịch khám thành công'),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Thành công'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            AppToast.showWarning('Bác sĩ hiện đang bận'),
                        icon: const Icon(Icons.warning_rounded),
                        label: const Text('Cảnh báo'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            AppToast.showError('Không thể tải dữ liệu'),
                        icon: const Icon(Icons.error_rounded),
                        label: const Text('Lỗi'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Status Badge Example
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
      floatingActionButton: FadeSlideTransition(
        delay: const Duration(milliseconds: 500),
        slideOffset: const Offset(0, 50),
        child: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Thêm lịch hẹn',
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}
