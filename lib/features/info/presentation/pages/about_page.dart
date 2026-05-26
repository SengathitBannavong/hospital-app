import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';
import '../../../../core/theme/hospital_theme.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final about = ref.watch(aboutProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/info'),
        ),
        title: const Text('Giới thiệu'),
      ),
      body: about.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            _InfoErrorState(onRetry: () => ref.invalidate(aboutProvider)),
        data: (info) => SingleChildScrollView(
          padding: AppSpacing.pageWithTop,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: AppSpacing.cardPaddingLarge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.hospitalName,
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        info.description,
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Phiên bản ${info.version}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text('Tính năng chính', style: context.textTheme.titleMedium),

              const SizedBox(height: AppSpacing.md),

              const ListTile(
                leading: Icon(Icons.map_rounded),
                title: Text('Bản đồ bệnh viện'),
              ),

              const ListTile(
                leading: Icon(Icons.notifications_rounded),
                title: Text('Thông báo'),
              ),

              const ListTile(
                leading: Icon(Icons.local_hospital_rounded),
                title: Text('Quản lý y tế'),
              ),

              const ListTile(
                leading: Icon(Icons.person_rounded),
                title: Text('Hồ sơ người dùng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoErrorState extends StatelessWidget {
  const _InfoErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 36),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Không thể tải thông tin. Vui lòng thử lại.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
