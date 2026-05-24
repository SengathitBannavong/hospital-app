import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _appointmentReminder = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: AppSpacing.pageWithTop,
        children: [
          // ── Tài khoản ──
          _SectionLabel('Tài khoản'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outline_rounded, color: cs.primary),
                  title: const Text('Đổi mật khẩu'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/change-password'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Giao diện ──
          _SectionLabel('Giao diện'),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chủ đề hiển thị',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ListenableBuilder(
                    listenable: themeController,
                    builder: (context, _) {
                      return SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text('Sáng'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto_outlined),
                            label: Text('Hệ thống'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text('Tối'),
                          ),
                        ],
                        selected: {themeController.themeMode},
                        onSelectionChanged: (modes) =>
                            themeController.setThemeMode(modes.first),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Thông báo ──
          _SectionLabel('Thông báo'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_outlined,
                    color: cs.primary,
                  ),
                  title: const Text('Cho phép thông báo'),
                  subtitle: const Text('Nhận thông báo từ bệnh viện'),
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
                const Divider(height: 1, indent: 72),
                SwitchListTile(
                  secondary: Icon(Icons.alarm_outlined, color: cs.primary),
                  title: const Text('Nhắc lịch khám'),
                  subtitle: const Text('Nhắc nhở trước 30 phút'),
                  value: _appointmentReminder && _notificationsEnabled,
                  onChanged: _notificationsEnabled
                      ? (v) => setState(() => _appointmentReminder = v)
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Thông tin ứng dụng ──
          _SectionLabel('Thông tin ứng dụng'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.help_outline_rounded,
                    color: cs.primary,
                  ),
                  title: const Text('Trợ giúp & Hỗ trợ'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/help'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: cs.primary,
                  ),
                  title: const Text('Về ứng dụng'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.verified_outlined, color: cs.primary),
                  title: const Text('Phiên bản'),
                  trailing: Text(
                    '1.0.0',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              ctx.pop();
              ref.read(authStateProvider.notifier).logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Hospital App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Hospital App Team',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Ứng dụng hỗ trợ bệnh nhân tra cứu thông tin, '
          'điều hướng nội viện và quản lý lịch khám bệnh.',
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
