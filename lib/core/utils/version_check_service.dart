import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hospital_app/features/auth/data/models/version_check_response.dart';

class VersionCheckService {
  // Show update dialog based on version check response
  static Future<void> showVersionUpdateDialog(
    BuildContext context, {
    required VersionCheckResponse response,
    String? currentVersion,
    String? packageName,
  }) async {
    if (response.updateType == null || response.updateType == 'none') {
      return; // No action needed
    }

    final isForceUpdate = response.updateType == 'force';
    final updateUrl =
        response.downloadUrl ?? _fallbackStoreUrl(packageName: packageName);

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (dialogContext) => PopScope(
        canPop: !isForceUpdate,
        child: AlertDialog(
          title: Text(
            isForceUpdate ? 'Update Required' : 'New Version Available',
            style: Theme.of(dialogContext).textTheme.titleLarge,
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
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          actions: [
            if (!isForceUpdate)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Later'),
              ),
            ElevatedButton(
              onPressed: () async {
                final resolvedUrl = updateUrl;

                if (resolvedUrl == null) {
                  if (isForceUpdate && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Update is required, but no store link is available.',
                        ),
                      ),
                    );
                  }

                  if (!isForceUpdate && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  return;
                }

                final launched = await _launchUrl(resolvedUrl);

                if (!dialogContext.mounted) return;

                if (launched) {
                  Navigator.pop(dialogContext);
                  return;
                }

                if (isForceUpdate && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to open the store. Please try again or exit the app.',
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Update Now'),
            ),
            if (isForceUpdate)
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Exit App'),
              ),
          ],
        ),
      ),
    );
  }

  static String? _fallbackStoreUrl({String? packageName}) {
    if (packageName == null || packageName.isEmpty) {
      return null;
    }

    return 'market://details?id=$packageName';
  }

  static Future<bool> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await canLaunchUrl(uri)) {
        return false;
      }

      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }
}
