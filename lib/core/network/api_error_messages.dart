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
  switch (code) {
    // ── Request / parameter ──
    case ApiResponseCodes.badRequest:
    case ApiResponseCodes.invalidBodyOrSpam:
      return 'Yêu cầu không hợp lệ.';
    case ApiResponseCodes.missingParameter:
      return 'Thiếu thông tin bắt buộc.';
    case ApiResponseCodes.invalidParameterType:
      return 'Dữ liệu gửi lên không hợp lệ.';
    case ApiResponseCodes.invalidParameterValue:
      return 'Giá trị không hợp lệ.';
    case ApiResponseCodes.methodNotAllowed:
      return 'Thao tác không được hỗ trợ.';

    // ── Permission / limits ──
    case ApiResponseCodes.accessDenied:
    case ApiResponseCodes.permissionDenied:
    case ApiResponseCodes.adminRoleRequired:
      return 'Bạn không có quyền thực hiện thao tác này.';
    case ApiResponseCodes.limitExceeded:
      // Asset context: only one wheelchair may be borrowed at a time.
      return 'Bạn đang mượn thiết bị khác, vui lòng trả trước khi mượn thêm.';

    // ── Auth / OTP ──
    case ApiResponseCodes.otpIncorrect:
      return 'Mã OTP không đúng.';
    case ApiResponseCodes.otpExpired:
      return 'Mã OTP đã hết hạn.';
    case ApiResponseCodes.userAlreadyExists:
      return 'Tài khoản đã tồn tại.';
    case ApiResponseCodes.userNotFound:
      return 'Không tìm thấy tài khoản.';
    case ApiResponseCodes.passwordIncorrect:
      return 'Mật khẩu không đúng.';

    // ── Map / routing ──
    case ApiResponseCodes.floorNotFound:
    case ApiResponseCodes.nodeNotFound:
    case ApiResponseCodes.edgeNotFound:
    case ApiResponseCodes.mapResourceNotFound:
      return 'Không tìm thấy thông tin phù hợp trên hệ thống.';
    case ApiResponseCodes.invalidStartLocation:
      return 'Vị trí bắt đầu không hợp lệ.';
    case ApiResponseCodes.invalidDestination:
      return 'Điểm đến không hợp lệ.';
    case ApiResponseCodes.pathNotFound:
      return 'Không tìm thấy đường đi phù hợp.';
    case ApiResponseCodes.invalidLocationData:
      return 'Dữ liệu vị trí không hợp lệ.';
    case ApiResponseCodes.densityDataUnavailable:
      return 'Dữ liệu mật độ tạm thời không khả dụng.';

    // ── Medical / asset ──
    case ApiResponseCodes.clinicalTaskNotFound:
      return 'Không tìm thấy nhiệm vụ.';
    case ApiResponseCodes.assetNotFound:
      return 'Không tìm thấy thiết bị.';
    case ApiResponseCodes.assetNotAvailable:
      return 'Thiết bị hiện không khả dụng.';

    // ── Server / infrastructure ──
    case ApiResponseCodes.internalServerError:
    case ApiResponseCodes.engineUnavailable:
    case ApiResponseCodes.engineTimeout:
    case ApiResponseCodes.dbConnectionFailed:
    case ApiResponseCodes.dbQueryFailed:
    case ApiResponseCodes.unexpectedException:
      return 'Máy chủ đang gặp sự cố, vui lòng thử lại sau.';
    case ApiResponseCodes.hisServiceUnavailable:
      return 'Hệ thống bệnh viện tạm thời không phản hồi, '
          'vui lòng thử lại sau.';

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
      return 'Đã xảy ra lỗi, vui lòng thử lại.';
  }
}
