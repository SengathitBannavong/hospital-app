import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hospital_app/features/util/data/repository/util_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _boxName = 'util';
const _lastShownAtKey = 'version_gate_last_shown_at';
const _lastVersionKey = 'version_gate_last_version';

Future<void> checkAndPrompt(BuildContext context) async {
  if (kIsWeb) return;

  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final update = await UtilRepository().checkVersion(
      platform: Platform.isAndroid ? 'android' : 'ios',
      code: packageInfo.buildNumber,
    );

    if (update.status != 'update_available' || !context.mounted) {
      return;
    }

    final box = await _openBox();
    final now = DateTime.now();
    final lastShownAt = box.get(_lastShownAtKey) as int?;
    final lastVersion = box.get(_lastVersionKey) as String?;
    final shownRecently =
        lastShownAt != null &&
        now
                .difference(DateTime.fromMillisecondsSinceEpoch(lastShownAt))
                .inHours <
            24;

    if (shownRecently && lastVersion == update.latestVersion) {
      return;
    }

    await box.put(_lastShownAtKey, now.millisecondsSinceEpoch);
    await box.put(_lastVersionKey, update.latestVersion);

    if (context.mounted) {
      await _showUpdateDialog(
        context,
        update.latestVersion,
        update.changeLog,
        update.downloadUrl,
      );
    }
  } catch (error) {
    debugPrint('Version check skipped: $error');
  }
}

Future<void> _showUpdateDialog(
  BuildContext context,
  String latestVersion,
  String changeLog,
  String downloadUrl,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text('Có bản cập nhật mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phiên bản mới: $latestVersion'),
            const SizedBox(height: 12),
            Text(changeLog),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final uri = Uri.tryParse(downloadUrl);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      );
    },
  );
}

Future<Box<dynamic>> _openBox() async {
  if (Hive.isBoxOpen(_boxName)) {
    return Hive.box<dynamic>(_boxName);
  }

  try {
    return await Hive.openBox<dynamic>(_boxName);
  } catch (_) {
    await Hive.initFlutter();
    return Hive.openBox<dynamic>(_boxName);
  }
}
