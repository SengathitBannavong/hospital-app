// lib/features/notification/presentation/pages/notification_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import '../../data/models/notification_settings_model.dart';
import '../providers/notification_provider.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationSettingsProvider.notifier).loadSettings();
    });
  }

  Future<void> _save(NotificationSettingsModel settings) async {
    final success = await ref
        .read(notificationSettingsProvider.notifier)
        .saveSettings(settings);
    if (!mounted) return;
    if (success) {
      AppToast.showSuccess('Đã lưu cài đặt');
    } else {
      AppToast.showError('Không thể lưu cài đặt');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Cài đặt thông báo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Không thể tải cài đặt',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => ref
                    .read(notificationSettingsProvider.notifier)
                    .loadSettings(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (settings) => _buildContent(settings, cs),
      ),
    );
  }

  Widget _buildContent(NotificationSettingsModel settings, ColorScheme cs) {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Notifications ────────────────────────────────────────────────
          const _SectionHeader(title: 'Thông báo'),
          _SettingsTile(
            icon: Icons.notifications_active_rounded,
            iconColor: cs.primary,
            title: 'Bật thông báo',
            subtitle: 'Nhận thông báo từ hệ thống',
            value: settings.notificationEnabled,
            onChanged: (val) =>
                _save(settings.copyWith(notificationEnabled: val)),
          ),
          _SettingsTile(
            icon: Icons.record_voice_over_rounded,
            iconColor: cs.secondary,
            title: 'Hướng dẫn giọng nói',
            subtitle: 'Đọc hướng dẫn đường đi bằng giọng nói',
            value: settings.voiceGuidanceEnabled,
            onChanged: (val) =>
                _save(settings.copyWith(voiceGuidanceEnabled: val)),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Travel Mode ──────────────────────────────────────────────────
          const _SectionHeader(title: 'Chế độ di chuyển'),
          _TravelModeTile(
            current: settings.travelMode,
            onChanged: (val) => _save(settings.copyWith(travelMode: val)),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Language ─────────────────────────────────────────────────────
          const _SectionHeader(title: 'Ngôn ngữ'),
          _DropdownTile(
            icon: Icons.language_rounded,
            iconColor: cs.tertiary,
            title: 'Ngôn ngữ hiển thị',
            value: settings.language,
            items: const {'vi': 'Tiếng Việt', 'en': 'English'},
            onChanged: (val) => _save(settings.copyWith(language: val)),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// Private widgets.

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _TravelModeTile extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _TravelModeTile({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final modes = {
      'walk': ('Đi bộ', Icons.directions_walk_rounded),
      'wheelchair': ('Xe lăn', Icons.accessible_rounded),
      'stretcher': ('Cáng', Icons.airline_seat_flat_rounded),
    };

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: RadioGroup<String>(
        groupValue: current,
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
        child: Column(
          children: modes.entries.map((entry) {
            final isSelected = current == entry.key;
            return RadioListTile<String>(
              value: entry.key,
              secondary: Icon(
                entry.value.$2,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
              title: Text(
                entry.value.$1,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title),
        trailing: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (val) => onChanged(val!),
        ),
      ),
    );
  }
}
