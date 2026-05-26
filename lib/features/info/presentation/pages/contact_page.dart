import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/features/util/presentation/providers/util_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/hospital_theme.dart';

class ContactPage extends ConsumerWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = ref.watch(contactProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/info'),
        ),
        title: const Text('Liên hệ'),
      ),
      body: contact.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            _ContactErrorState(onRetry: () => ref.invalidate(contactProvider)),
        data: (info) => SingleChildScrollView(
          padding: AppSpacing.pageWithTop,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: AppSpacing.cardPaddingLarge,
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_hospital_rounded,
                        size: 64,
                        color: context.colorScheme.primary,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'Bệnh viện Trung tâm',
                        style: context.textTheme.headlineSmall,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      ListTile(
                        leading: const Icon(Icons.phone_rounded),
                        title: Text(info.hotline),
                        onTap: () =>
                            _launch(Uri(scheme: 'tel', path: info.hotline)),
                      ),

                      ListTile(
                        leading: const Icon(Icons.email_rounded),
                        title: Text(info.email),
                        onTap: () =>
                            _launch(Uri(scheme: 'mailto', path: info.email)),
                      ),

                      ListTile(
                        leading: const Icon(Icons.location_on_rounded),
                        title: Text(info.address),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _ContactErrorState extends StatelessWidget {
  const _ContactErrorState({required this.onRetry});

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
              'Không thể tải thông tin liên hệ. Vui lòng thử lại.',
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
