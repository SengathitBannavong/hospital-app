import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';
import '../../../../core/l10n/locale_controller.dart';
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
        title: Text(context.l10n.infoAbout),
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
                        context.l10n.aboutVersion(info.version),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                context.l10n.aboutKeyFeatures,
                style: context.textTheme.titleMedium,
              ),

              const SizedBox(height: AppSpacing.md),

              ListTile(
                leading: const Icon(Icons.map_rounded),
                title: Text(context.l10n.mapPreviewTitle),
              ),

              ListTile(
                leading: const Icon(Icons.notifications_rounded),
                title: Text(context.l10n.homeNotificationsTitle),
              ),

              ListTile(
                leading: const Icon(Icons.local_hospital_rounded),
                title: Text(context.l10n.aboutFeatureMedical),
              ),

              ListTile(
                leading: const Icon(Icons.person_rounded),
                title: Text(context.l10n.aboutFeatureProfile),
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
              context.l10n.aboutError,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
