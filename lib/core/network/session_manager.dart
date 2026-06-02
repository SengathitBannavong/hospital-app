/// Global hook for forcing the user back to login when the backend rejects the
/// session token — e.g. it was invalidated by a login from another device, or
/// it expired. The network layer (interceptor) has no Riverpod ref, so the app
/// layer registers [onForceLogout] once at start (see RouterNotifier), and the
/// interceptor calls [forceLogout] when it sees a rejected token.
class SessionManager {
  SessionManager._();

  /// Clears the auth session (token + state). Set by the app layer at start.
  static Future<void> Function()? onForceLogout;

  static bool _inProgress = false;

  /// Performs a single logout. Idempotent: concurrent 401s from parallel
  /// in-flight requests only log out (and notify) once. Returns true when this
  /// call actually performed the logout, false when it was skipped (no handler
  /// registered, or a logout is already in progress).
  static Future<bool> forceLogout() async {
    if (_inProgress) return false;
    final handler = onForceLogout;
    if (handler == null) return false;
    _inProgress = true;
    try {
      await handler();
      return true;
    } finally {
      _inProgress = false;
    }
  }
}
