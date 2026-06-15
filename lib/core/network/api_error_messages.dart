import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';

/// Maps a backend `{code, message}` pair to a user-friendly Vietnamese string.
///
/// This backend wraps most responses as HTTP 200 + `{code, message, data}`, so
/// error codes surface through the repository's `code` check rather than as Dio
/// errors. It also returns `message: "OK"` (or "Success") even on *error*
/// codes, so the raw message is worthless — the **code** is authoritative.
/// Repositories funnel both paths through this helper; the raw [raw] message is
/// only ever a last-ditch fallback for an unmapped code, and "OK"/"Success" are
/// never shown.
///
/// Session/token codes (3001/3002/3003/3009/1004) are intentionally omitted —
/// the [ErrorInterceptor] owns those (force-logout); the generic fallback keeps
/// them safe if they ever reach here.
String friendlyMessage(int? code, String? raw) {
  final l10n = appL10n;
  switch (code) {
    // ── Request / parameter ──
    case ApiResponseCodes.badRequest:
    case ApiResponseCodes.invalidBodyOrSpam:
      return l10n.errBadRequest;
    case ApiResponseCodes.missingParameter:
      return l10n.errMissingParameter;
    case ApiResponseCodes.invalidParameterType:
      return l10n.errInvalidParameterType;
    case ApiResponseCodes.invalidParameterValue:
      return l10n.errInvalidParameterValue;
    case ApiResponseCodes.methodNotAllowed:
      return l10n.errMethodNotAllowed;

    // ── Permission / limits ──
    case ApiResponseCodes.accessDenied:
    case ApiResponseCodes.permissionDenied:
    case ApiResponseCodes.adminRoleRequired:
      return l10n.errAccessDenied;
    case ApiResponseCodes.limitExceeded:
      // Asset context: only one wheelchair may be borrowed at a time.
      return l10n.errLimitExceeded;

    // ── Auth / OTP ──
    case ApiResponseCodes.otpIncorrect:
      return l10n.errOtpIncorrect;
    case ApiResponseCodes.otpExpired:
      return l10n.errOtpExpired;
    case ApiResponseCodes.userAlreadyExists:
      return l10n.errUserExists;
    case ApiResponseCodes.userNotFound:
      return l10n.errUserNotFound;
    case ApiResponseCodes.passwordIncorrect:
      return l10n.errPasswordIncorrect;

    // ── Map / routing ──
    case ApiResponseCodes.floorNotFound:
    case ApiResponseCodes.nodeNotFound:
    case ApiResponseCodes.edgeNotFound:
    case ApiResponseCodes.mapResourceNotFound:
      return l10n.errMapNotFound;
    case ApiResponseCodes.invalidStartLocation:
      return l10n.errInvalidStart;
    case ApiResponseCodes.invalidDestination:
      return l10n.errInvalidDestination;
    case ApiResponseCodes.pathNotFound:
      return l10n.errPathNotFound;
    case ApiResponseCodes.invalidLocationData:
      return l10n.errInvalidLocationData;
    case ApiResponseCodes.densityDataUnavailable:
      return l10n.errDensityUnavailable;

    // ── Medical / asset ──
    case ApiResponseCodes.clinicalTaskNotFound:
      return l10n.errTaskNotFound;
    case ApiResponseCodes.assetNotFound:
      return l10n.errAssetNotFound;
    case ApiResponseCodes.assetNotAvailable:
      return l10n.errAssetNotAvailable;

    // ── Server / infrastructure ──
    case ApiResponseCodes.internalServerError:
    case ApiResponseCodes.engineUnavailable:
    case ApiResponseCodes.engineTimeout:
    case ApiResponseCodes.dbConnectionFailed:
    case ApiResponseCodes.dbQueryFailed:
    case ApiResponseCodes.unexpectedException:
      return l10n.errServer;
    case ApiResponseCodes.hisServiceUnavailable:
      return l10n.errHisUnavailable;

    default:
      final trimmed = raw?.trim();
      // The backend returns message:"OK"/"Success" even on errors, so a
      // non-success code with that text must never surface as the message.
      if (trimmed != null &&
          trimmed.isNotEmpty &&
          trimmed.toLowerCase() != 'ok' &&
          trimmed.toLowerCase() != 'success') {
        return trimmed;
      }
      return l10n.assetGenericError;
  }
}
