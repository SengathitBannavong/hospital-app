class ApiResponseCodes {
  // --- Standard HTTP Status Codes ---
  static const int httpSuccess = 200;
  static const int httpCreated = 201;
  static const int httpBadRequest = 400;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpValidationError = 422;
  static const int httpInternalServerError = 500;

  // --- Project Custom Status Codes ---
  static const int success = 1000;
  static const int badRequest = 4000;
  static const int internalServerError = 5000;

  static const int missingParameter = 2001;
  static const int invalidParameterType = 2002;
  static const int invalidParameterValue = 2003;
  static const int methodNotAllowed = 2004;
  static const int invalidBodyOrSpam = 2005;

  static const int invalidToken = 1004;
  static const int accessDenied = 1009;
  static const int tokenInvalid = 3001;
  static const int tokenExpired = 3002;
  static const int userNotAuthenticated = 3003;
  static const int otpIncorrect = 3004;
  static const int otpExpired = 3005;
  static const int userAlreadyExists = 3006;
  static const int userNotFound = 3007;
  static const int passwordIncorrect = 3008;
  static const int permissionDenied = 3101;
  static const int adminRoleRequired = 3102;

  static const int floorNotFound = 4001;
  static const int nodeNotFound = 4002;
  static const int edgeNotFound = 4003;
  static const int mapResourceNotFound = 4004;

  static const int invalidStartLocation = 5001;
  static const int invalidDestination = 5002;
  static const int pathNotFound = 5003;
  static const int invalidLocationData = 6001;
  static const int densityDataUnavailable = 6002;

  static const int limitExceeded = 1010;
  static const int hisServiceUnavailable = 7001;
  static const int clinicalTaskNotFound = 7002;
  static const int assetNotFound = 8001;
  static const int assetNotAvailable = 8002;

  static const int engineUnavailable = 9001;
  static const int engineTimeout = 9002;
  static const int dbConnectionFailed = 9901;
  static const int dbQueryFailed = 9902;
  static const int unexpectedException = 9999;
}
