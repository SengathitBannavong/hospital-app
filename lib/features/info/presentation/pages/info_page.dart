import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/hospital_theme.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Thông tin'),
      ),
      body: ListView(
        padding: AppSpacing.pageWithTop,
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                Icons.help_outline_rounded,
                color: context.colorScheme.primary,
              ),
              title: const Text('FAQ'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/faq'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.info_outline_rounded,
                color: context.colorScheme.primary,
              ),
              title: const Text('Giới thiệu'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/about'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.contact_support_outlined,
                color: context.colorScheme.primary,
              ),
              title: const Text('Liên hệ'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/contact'),
            ),
          ),
        ],
      ),
    );
  }
}
