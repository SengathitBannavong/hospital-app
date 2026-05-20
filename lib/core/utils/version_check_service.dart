import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hospital_app/features/auth/data/models/version_check_response.dart';

class VersionCheckService {
  // Show update dialog based on version check response
  static Future<void> showVersionUpdateDialog(
    BuildContext context, {
    required VersionCheckResponse response,
    String? currentVersion,
  }) async {
    if (response.updateType == null || response.updateType == 'none') {
      return; // No action needed
    }

    final isForceUpdate = response.updateType == 'force';

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (context) => AlertDialog(
        title: Text(
          isForceUpdate ? 'Update Required' : 'New Version Available',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (response.message != null)
              Text(response.message!)
            else
              Text(
                isForceUpdate
                    ? 'A critical update is required to continue using the app.'
                    : 'A new version is available. '
                        'Update now for the best experience.',
              ),
            if (currentVersion != null && response.latestVersion != null) ...[
              const SizedBox(height: 16),
              Text(
                'Current: $currentVersion → Latest: ${response.latestVersion}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          if (!isForceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (response.downloadUrl != null) {
                await _launchUrl(response.downloadUrl!);
              }
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  static Future<void> _launchUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
