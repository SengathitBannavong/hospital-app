// lib/core/network/api_endpoints.dart

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
  static const String deleteAccount = 'user/delete_account';

  // Medical
  static const String patients = 'patients';
  static const String appointments = 'appointments';
  static const String getTasks = 'medical/get_tasks';
  static const String medicalGetQueue = 'medical/get_queue';
  static const String medicalCheckinRoom = 'medical/checkin_room';
  static const String medicalCheckoutRoom = 'medical/checkout_room';
  static const String medicalResultStatus = 'medical/result_status';
  static const String medicalGetPrescription = 'medical/get_prescription';
  static const String medicalSyncNow = 'medical/sync_now';
  static const String medicalRoomOpen = 'medical/room_open';
  static const String medicalCancelTask = 'medical/cancel_task';
  static const String medicalGetHistory = 'medical/get_history';
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
  static const String routeGetSteps = 'route/get_steps';
  static const String routeGetNext = 'route/get_next';
  static const String routeRecalculate = 'route/recalculate';
  static const String routePassNode = 'route/pass_node';
  static const String routeHistory = 'route/get_history';
  static const String routeClearHistory = 'route/clear_history';

  // Flow
  static const String flowGetDensity = 'flow/get_density';
  static const String flowGetHeatmap = 'flow/get_heatmap';
  static const String flowGetBottlenecks = 'flow/get_bottlenecks';
  static const String flowGetForecast = 'flow/get_forecast';
  static const String flowGetAlerts = 'flow/get_alerts';
  static const String flowEdgeStatus = 'flow/edge_status';
  static const String flowPingLocation = 'flow/ping_location';
  static const String flowReportObstacle = 'flow/report_obstacle';
  static const String flowGetObstacles = 'flow/get_obstacles';

  // Voice
  static const String sysGetVoiceKey = 'sys/get_voice_key';
  static const String sysGetVoiceFiles = 'sys/get_voice_files';

  // Notification
  static const String notificationGetList = 'notification/get_list';
  static const String notificationSetRead = 'notification/set_read';
  static const String notificationDelete = 'notification/delete';

  // User / Settings / Device Token
  static const String setDevToken = 'user/set_devtoken';
  static const String getSettings = 'user/get_settings';
  static const String setSettings = 'user/set_settings';

  // SOS
  static const String sosCreate = 'sos/create';
  static const String sosGetDetail = 'sos/get_detail';

  // Utility
  static const String utilFaq = 'util/faq';
  static const String utilAbout = 'util/about';
  static const String utilContact = 'util/contact';
  static const String utilLanguages = 'util/languages';
  static const String utilCheckVersion = 'util/check_version';
  static const String utilWeather = 'util/weather';
  static const String utilFeedback = 'util/feedback';
  static const String utilFeedbackSummary = 'util/feedback_summary';
  static const String utilUpload = 'util/upload';
}
