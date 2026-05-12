class ApiEndpoints {
  // Auth
  static const String login = 'auth/login';
  static const String signup = 'auth/signup';
  static const String verifyOtp = 'auth/verify_otp';
  static const String resendOtp = 'auth/resend_otp';
  static const String forgotPassword = 'auth/forgot_password';
  static const String resetPassword = 'auth/reset_password';
  static const String logout = 'auth/logout';
  static const String changePassword = 'auth/change_password';

  // Medical & Others
  static const String patients = 'patients';
  static const String appointments = 'appointments';
  static const String getTasks = 'medical/get_tasks';
  static const String getProfile = 'user/get_profile';
  static const String setProfile = 'user/set_profile';

  // Map
  static const String getFloors = 'map/get_floors';
  static const String getNodes = 'map/get_nodes';
  static const String getEdges = 'map/get_edges';
  static const String getMeta = 'map/get_meta';
  static const String getDepts = 'map/get_depts';
  static const String searchLocation = 'map/search_location';
  static const String getLandmarks = 'map/get_landmarks';
  static const String syncFull = 'map/sync_full';

  // Route
  static const String routeGetModes = 'route/get_modes';
  static const String routePreview = 'route/preview';
  static const String routeOrder = 'route/order';
  static const String routeOrderMulti = 'route/order_multi';
  static const String routeOrderUnordered = 'route/order_unordered';
  static const String routeHistory = 'route/get_history';
  static const String routeClearHistory = 'route/clear_history';
}
