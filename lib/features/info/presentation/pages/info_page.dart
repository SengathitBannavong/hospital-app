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
        children: const [
          // ── Help & Info ──────────────────────────────────────
          _SectionHeader(title: 'Trợ giúp & Giới thiệu'),
          _InfoTile(
            icon: Icons.help_outline_rounded,
            title: 'FAQ',
            route: '/faq',
          ),
          _InfoTile(
            icon: Icons.info_outline_rounded,
            title: 'Giới thiệu',
            route: '/about',
          ),
          _InfoTile(
            icon: Icons.contact_support_outlined,
            title: 'Liên hệ',
            route: '/contact',
          ),

          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon, color: context.colorScheme.primary),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(route),
        ),
      ),
    );
  }
}
