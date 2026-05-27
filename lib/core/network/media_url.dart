import 'package:hospital_app/core/config/app_config.dart';

/// Resolves a backend-served media path to an absolute URL usable by
/// `NetworkImage` or similar. Backend returns paths like `/uploads/abc.png`
/// (relative to the server origin, NOT relative to the `/api/` base path),
/// so we strip the API path from [AppConfig.baseUrl] and use only the origin.
///
/// Returns null for null/empty input. Returns input unchanged if it is
/// already absolute (`http://` or `https://`).
String? resolveMediaUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

  // Backend serves uploads only under /uploads/. Reject anything else so
  // stale device paths (e.g. /private/var/mobile/...) from earlier broken
  // builds render as "no avatar" instead of 404-spamming the API origin.
  final normalized = raw.startsWith('/') ? raw : '/$raw';
  if (!normalized.startsWith('/uploads/')) return null;

  final origin = Uri.parse(AppConfig.baseUrl).origin;
  return '$origin$normalized';
}
