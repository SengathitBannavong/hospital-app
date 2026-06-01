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

          SizedBox(height: AppSpacing.xl),

          // ── Hospital Utilities ───────────────────────────────
          _SectionHeader(title: 'Tiện ích bệnh viện'),
          _InfoTile(
            icon: Icons.local_pharmacy_rounded,
            title: 'Nhà thuốc',
            route: '/pharmacy',
          ),
          _InfoTile(
            icon: Icons.restaurant_rounded,
            title: 'Căng-tin',
            route: '/canteen',
          ),
          _InfoTile(
            icon: Icons.local_parking_rounded,
            title: 'Bãi đỗ xe',
            route: '/parking',
          ),
          _InfoTile(icon: Icons.wifi_rounded, title: 'WiFi', route: '/wifi'),
          _InfoTile(
            icon: Icons.wb_sunny_rounded,
            title: 'Thời tiết',
            route: '/weather',
          ),

          SizedBox(height: AppSpacing.xl),

          // ── Asset / Device Services ──────────────────────────
          _SectionHeader(title: 'Dịch vụ thiết bị'),
          _InfoTile(
            icon: Icons.accessible_rounded,
            title: 'Trạm xe lăn',
            route: '/asset/stations',
          ),
          _InfoTile(
            icon: Icons.search_rounded,
            title: 'Tìm xe lăn gần đây',
            route: '/asset/search',
          ),

          SizedBox(height: AppSpacing.xl),

          // ── Staff Assistance ─────────────────────────────────
          _SectionHeader(title: 'Hỗ trợ nhân viên'),
          _InfoTile(
            icon: Icons.support_agent_rounded,
            title: 'Yêu cầu hỗ trợ',
            route: '/staff',
          ),

          SizedBox(height: AppSpacing.xl),

          // ── Traffic & Flow ───────────────────────────────────
          _SectionHeader(title: 'Giao thông & Lưu thông'),
          _InfoTile(
            icon: Icons.warning_amber_rounded,
            title: 'Cảnh báo giao thông',
            route: '/flow/alerts',
          ),
          _InfoTile(
            icon: Icons.people_rounded,
            title: 'Mật độ đông người',
            route: '/flow/density',
          ),
          _InfoTile(
            icon: Icons.report_rounded,
            title: 'Báo cáo vật cản',
            route: '/flow/report-obstacle',
          ),

          SizedBox(height: AppSpacing.xl),

          // ── Route Features ───────────────────────────────────
          _SectionHeader(title: 'Tuyến đường'),
          _InfoTile(
            icon: Icons.history_rounded,
            title: 'Lịch sử tuyến đường',
            route: '/route/history',
          ),

          SizedBox(height: AppSpacing.xl),

          // ── Heatmap ──────────────────────────────────────────
          _SectionHeader(title: 'Bản đồ nhiệt'),
          _InfoTile(
            icon: Icons.grid_on_rounded,
            title: 'Bản đồ nhiệt mật độ',
            route: '/flow/heatmap',
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
