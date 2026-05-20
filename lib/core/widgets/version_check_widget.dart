import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/core/utils/version_check_service.dart';

/// Widget that checks app version on startup and shows update dialog if needed.
/// Place this as a wrapper around your main app content.
class VersionCheckWidget extends ConsumerStatefulWidget {
  final Widget child;

  const VersionCheckWidget({required this.child, super.key});

  @override
  ConsumerState<VersionCheckWidget> createState() => _VersionCheckWidgetState();
}

class _VersionCheckWidgetState extends ConsumerState<VersionCheckWidget> {
  bool _versionChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersion();
    });
  }

  Future<void> _checkVersion() async {
    if (_versionChecked) return;

    try {
      // Get platform before async operations
      final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      final platform = isIOS ? 'ios' : 'android';

      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;

      if (!mounted) return;

      final authRepository = ref.read(authRepositoryProvider);
      final versionResponse = await authRepository.checkVersion(
        platform: platform,
        appVersion: version,
      );

      if (!mounted) return;

      _versionChecked = true;

      await VersionCheckService.showVersionUpdateDialog(
        context,
        response: versionResponse,
        currentVersion: version,
      );
    } catch (e) {
      debugPrint('Version check error: $e');
      // Silently fail - version check is not critical
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
