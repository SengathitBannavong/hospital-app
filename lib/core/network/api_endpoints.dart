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
}
