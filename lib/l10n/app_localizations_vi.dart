// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonError => 'Đã xảy ra lỗi, vui lòng thử lại';

  @override
  String get commonOk => 'Đồng ý';

  @override
  String get commonYes => 'Có';

  @override
  String get commonNo => 'Không';

  @override
  String get commonLoading => 'Đang tải...';

  @override
  String get commonProcessing => 'Đang xử lý...';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonNext => 'Tiếp tục';

  @override
  String get commonDone => 'Hoàn tất';

  @override
  String get commonContinue => 'Tiếp tục';

  @override
  String get commonErrorShort => 'Đã xảy ra lỗi';

  @override
  String get errBadRequest => 'Yêu cầu không hợp lệ.';

  @override
  String get errMissingParameter => 'Thiếu thông tin bắt buộc.';

  @override
  String get errInvalidParameterType => 'Dữ liệu gửi lên không hợp lệ.';

  @override
  String get errInvalidParameterValue => 'Giá trị không hợp lệ.';

  @override
  String get errMethodNotAllowed => 'Thao tác không được hỗ trợ.';

  @override
  String get errAccessDenied => 'Bạn không có quyền thực hiện thao tác này.';

  @override
  String get errLimitExceeded =>
      'Bạn đang mượn thiết bị khác, vui lòng trả trước khi mượn thêm.';

  @override
  String get errOtpIncorrect => 'Mã OTP không đúng.';

  @override
  String get errOtpExpired => 'Mã OTP đã hết hạn.';

  @override
  String get errUserExists => 'Tài khoản đã tồn tại.';

  @override
  String get errUserNotFound => 'Không tìm thấy tài khoản.';

  @override
  String get errPasswordIncorrect => 'Mật khẩu không đúng.';

  @override
  String get errMapNotFound =>
      'Không tìm thấy thông tin phù hợp trên hệ thống.';

  @override
  String get errInvalidStart => 'Vị trí bắt đầu không hợp lệ.';

  @override
  String get errInvalidDestination => 'Điểm đến không hợp lệ.';

  @override
  String get errPathNotFound => 'Không tìm thấy đường đi phù hợp.';

  @override
  String get errInvalidLocationData => 'Dữ liệu vị trí không hợp lệ.';

  @override
  String get errDensityUnavailable => 'Dữ liệu mật độ tạm thời không khả dụng.';

  @override
  String get errTaskNotFound => 'Không tìm thấy nhiệm vụ.';

  @override
  String get errAssetNotFound => 'Không tìm thấy thiết bị.';

  @override
  String get errAssetNotAvailable => 'Thiết bị hiện không khả dụng.';

  @override
  String get errServer => 'Máy chủ đang gặp sự cố, vui lòng thử lại sau.';

  @override
  String get errHisUnavailable =>
      'Hệ thống bệnh viện tạm thời không phản hồi, vui lòng thử lại sau.';

  @override
  String get errAccountElsewhere =>
      'Tài khoản đã đăng nhập trên thiết bị khác. Vui lòng đăng nhập lại.';

  @override
  String get errSessionEnded =>
      'Phiên đăng nhập đã kết thúc. Vui lòng đăng nhập lại.';

  @override
  String get errTimeout => 'Kết nối tới máy chủ quá hạn, vui lòng thử lại.';

  @override
  String get errCancelled => 'Yêu cầu đã bị hủy.';

  @override
  String get errNoNetwork => 'Không có kết nối mạng.';

  @override
  String get errDataNotFound => 'Không tìm thấy dữ liệu.';

  @override
  String get daConfirmBody =>
      'Bạn có chắc chắn muốn xóa tài khoản của mình không?\nHành động này không thể đảo ngược.\nTất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.';

  @override
  String get daPasswordTitle => 'Xác nhận xóa tài khoản';

  @override
  String get daPasswordHint => 'Nhập mật khẩu của bạn';

  @override
  String get daSuccessTitle => 'Tài khoản đã được xóa thành công';

  @override
  String get daSuccessBody => 'Tài khoản của bạn đã được xóa thành công.';

  @override
  String get daErrorTitle => 'Lỗi';

  @override
  String get vgUpdateTitle => 'Có bản cập nhật mới';

  @override
  String vgNewVersion(Object version) {
    return 'Phiên bản mới: $version';
  }

  @override
  String get vgLater => 'Để sau';

  @override
  String get vgUpdate => 'Cập nhật';

  @override
  String get assetInUseOrNoPermission =>
      'Thiết bị này đang được người dùng khác sử dụng, hoặc bạn không có quyền theo dõi thiết bị này.';

  @override
  String get assetGenericError => 'Đã xảy ra lỗi, vui lòng thử lại.';

  @override
  String get chatImagePlaceholder => '[Hình ảnh]';

  @override
  String get chatVoicePlaceholder => '[Tin nhắn thoại]';

  @override
  String get chatSupportDefault => 'Hỗ trợ bệnh nhân';

  @override
  String get chatRoomsTitle => 'Tin nhắn';

  @override
  String get chatNoConversations => 'Chưa có cuộc trò chuyện nào';

  @override
  String get chatLoadError => 'Không thể tải tin nhắn';

  @override
  String get chatRoomDefault => 'Phòng chat';

  @override
  String get chatNoMessages => 'Chưa có tin nhắn';

  @override
  String get chatYesterday => 'Hôm qua';

  @override
  String get chatNoMessagesYet => 'Chưa có tin nhắn nào';

  @override
  String get chatLoadOlder => 'Tải tin nhắn cũ hơn';

  @override
  String get chatSendImage => 'Gửi ảnh';

  @override
  String get chatInputHint => 'Nhập tin nhắn...';

  @override
  String get chatNewMessages => 'Tin nhắn mới';

  @override
  String get chatMsgRead => '✓✓ Đã xem';

  @override
  String get chatMsgSent => '✓ Đã gửi';

  @override
  String get chatImageLoadError => 'Không thể tải ảnh';

  @override
  String get chatVoiceMessage => 'Tin nhắn thoại';

  @override
  String get senderPatient => 'Bệnh nhân';

  @override
  String get senderAdmin => 'Quản trị viên';

  @override
  String get senderCoordinator => 'Điều phối viên';

  @override
  String get senderStaff => 'Nhân viên hỗ trợ';

  @override
  String get chatEmptyContent => 'Nội dung tin nhắn không được để trống';

  @override
  String get sosSentMessage =>
      'Đã gửi tín hiệu SOS. Nhân viên đang trên đường đến!';

  @override
  String get authPhone => 'Số điện thoại';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authHide => 'Ẩn';

  @override
  String get authShow => 'Hiện';

  @override
  String get welcomeLogoutSuccess => 'Đã đăng xuất thành công.';

  @override
  String get welcomeTitle => 'Chào mừng trở lại!';

  @override
  String get welcomeSubtitle =>
      'Phiên đăng nhập của bạn đã được lưu an toàn. Tiếp tục sử dụng ứng dụng hoặc đăng xuất khi hoàn tất.';

  @override
  String get welcomeContinue => 'Tiếp tục vào ứng dụng';

  @override
  String get loginErrorEmptyFields =>
      'Vui lòng nhập số điện thoại và mật khẩu.';

  @override
  String get loginSuccess => 'Đăng nhập thành công.';

  @override
  String get loginWelcomeBack => 'Chào mừng trở lại';

  @override
  String get loginSubtitle => 'Đăng nhập để tiếp tục chăm sóc sức khỏe';

  @override
  String get loginCredentials => 'Thông tin đăng nhập';

  @override
  String get loginForgotPassword => 'Quên mật khẩu?';

  @override
  String get loginNoAccount => 'Chưa có tài khoản?';

  @override
  String get loginRegisterNow => 'Đăng ký ngay';

  @override
  String get authLogin => 'Đăng nhập';

  @override
  String get authRememberedPassword => 'Đã nhớ mật khẩu?';

  @override
  String get authPasswordNew => 'Mật khẩu mới';

  @override
  String get authConfirmPassword => 'Xác nhận mật khẩu';

  @override
  String get forgotErrorEmptyPhone => 'Vui lòng nhập số điện thoại.';

  @override
  String get forgotOtpSent => 'Mã xác thực đã được gửi.';

  @override
  String get forgotSubtitle => 'Nhập số điện thoại để nhận mã xác thực';

  @override
  String get forgotVerifyAccount => 'Xác minh tài khoản';

  @override
  String get forgotSendOtp => 'Gửi mã xác thực';

  @override
  String get resetErrorEmptyFields => 'Vui lòng điền tất cả các trường.';

  @override
  String get resetErrorShortPassword => 'Mật khẩu phải có ít nhất 6 ký tự.';

  @override
  String get resetErrorMismatch => 'Mật khẩu không khớp.';

  @override
  String get resetSuccess => 'Mật khẩu đã được đặt lại thành công.';

  @override
  String get resetTitle => 'Đặt lại mật khẩu';

  @override
  String get resetSubtitle => 'Tạo mật khẩu mới cho tài khoản của bạn';

  @override
  String get authHidePassword => 'Ẩn mật khẩu';

  @override
  String get authShowPassword => 'Hiện mật khẩu';

  @override
  String get genderMale => 'Nam';

  @override
  String get genderFemale => 'Nữ';

  @override
  String get genderOther => 'Khác';

  @override
  String get registerErrorSelectDob => 'Vui lòng chọn ngày sinh.';

  @override
  String get registerErrorMinAge => 'Bạn phải ít nhất 13 tuổi để đăng ký.';

  @override
  String get registerSelectDob => 'Chọn ngày sinh';

  @override
  String get registerTitle => 'Tạo tài khoản';

  @override
  String get registerSubtitle =>
      'Tham gia cùng chúng tôi để được hỗ trợ tốt nhất';

  @override
  String get registerPersonalInfo => 'Thông tin cá nhân';

  @override
  String get registerFullName => 'Họ và tên';

  @override
  String get registerFullNameError => 'Nhập họ tên của bạn';

  @override
  String get registerPhoneInvalid => 'Số điện thoại không hợp lệ';

  @override
  String get registerSecurityInfo => 'Thông tin bảo mật';

  @override
  String get registerPasswordMin => 'Mật khẩu tối thiểu 6 ký tự';

  @override
  String get registerConfirmPasswordError => 'Vui lòng xác nhận mật khẩu';

  @override
  String get registerPasswordMismatch => 'Mật khẩu không khớp';

  @override
  String get registerButton => 'Đăng ký';

  @override
  String get registerHaveAccount => 'Đã có tài khoản?';

  @override
  String get registerLoginNow => 'Đăng nhập ngay';

  @override
  String get otpResent => 'Đã gửi lại mã';

  @override
  String get otpErrorIncomplete => 'Vui lòng nhập đầy đủ mã OTP.';

  @override
  String get otpContinueReset => 'Tiếp tục đặt lại mật khẩu.';

  @override
  String get otpVerifySuccess => 'Xác thực thành công!';

  @override
  String get otpTitle => 'Xác thực OTP';

  @override
  String otpSentTo(String phone) {
    return 'Mã OTP đã được gửi đến số $phone';
  }

  @override
  String get otpFilled => 'Đã điền mã OTP';

  @override
  String get otpMockLabel => 'Mã OTP (mock)';

  @override
  String get otpResendButton => 'Gửi lại mã';

  @override
  String get otpResendError => 'Không thể gửi lại mã. Vui lòng thử lại.';

  @override
  String get changePwdErrorShortNew => 'Mật khẩu mới phải có ít nhất 6 ký tự.';

  @override
  String get changePwdErrorMismatch => 'Mật khẩu mới không khớp.';

  @override
  String get changePwdErrorSameAsOld => 'Mật khẩu mới phải khác mật khẩu cũ.';

  @override
  String get changePwdSuccess => 'Mật khẩu đã được thay đổi thành công.';

  @override
  String get changePwdSessionExpired =>
      'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get changePwdTitle => 'Thay đổi mật khẩu';

  @override
  String get changePwdSubtitle => 'Cập nhật mật khẩu để bảo mật tài khoản';

  @override
  String get changePwdVerifySection => 'Xác minh mật khẩu';

  @override
  String get changePwdCurrentHint => 'Mật khẩu hiện tại';

  @override
  String get changePwdConfirmHint => 'Xác nhận mật khẩu mới';

  @override
  String get deviceRefresh => 'Làm mới';

  @override
  String get mwTitle => 'Xe lăn của tôi';

  @override
  String get mwReleaseSuccess => 'Đã trả thiết bị thành công!';

  @override
  String get mwNoBookingFound => 'Không tìm thấy lượt mượn nào của bạn.';

  @override
  String mwRecovered(Object id) {
    return 'Đã khôi phục lượt mượn: $id';
  }

  @override
  String get mwPickTitle => 'Chọn xe lăn của bạn';

  @override
  String get mwPickContent =>
      'Có nhiều xe lăn đang được mượn. Chọn đúng xe của bạn:';

  @override
  String mwAdopted(Object id) {
    return 'Đã chọn lượt mượn: $id';
  }

  @override
  String mwBorrowing(Object id) {
    return 'Đang mượn · $id';
  }

  @override
  String mwStatus(Object status) {
    return 'Trạng thái: $status';
  }

  @override
  String mwBattery(Object level) {
    return 'Pin $level';
  }

  @override
  String get mwTrackLocation => 'Theo dõi vị trí';

  @override
  String get mwReportBroken => 'Báo hỏng';

  @override
  String get mwChecking => 'Đang kiểm tra lượt mượn của bạn...';

  @override
  String get mwEmptyTitle => 'Bạn chưa mượn xe lăn nào';

  @override
  String get mwEmptySubtitle =>
      'Nếu bạn đã mượn trên thiết bị khác, hãy khôi phục lượt mượn.';

  @override
  String get mwRecoverBooking => 'Khôi phục lượt mượn';

  @override
  String get wsPickLocationTitle => 'Chọn vị trí của bạn';

  @override
  String get wsYourLocation => 'Vị trí của bạn';

  @override
  String get wsYourLocationHint => 'Chọn vị trí để tìm xe lăn gần đó...';

  @override
  String get wsEnterLocationPrompt => 'Nhập mã vị trí để tìm xe lăn gần đó';

  @override
  String get wsNoWheelchairs => 'Không có xe lăn trống gần vị trí này.';

  @override
  String get wsAvailable => 'Có sẵn';

  @override
  String get wsUnavailable => 'Không khả dụng';

  @override
  String wsBatteryPercent(Object level) {
    return 'Pin: $level%';
  }

  @override
  String wsDistance(Object distance) {
    return 'Cách ${distance}m';
  }

  @override
  String get wsBorrow => 'Mượn';

  @override
  String trackTitle(Object id) {
    return 'Vị trí $id';
  }

  @override
  String get trackInfoTitle => 'Thông tin theo dõi';

  @override
  String get trackAssetCode => 'Mã thiết bị';

  @override
  String get trackStatus => 'Trạng thái';

  @override
  String get trackMoving => 'Chuyển động';

  @override
  String get trackCurrentPos => 'Vị trí hiện tại';

  @override
  String get trackCondition => 'Tình trạng';

  @override
  String get trackBattery => 'Pin';

  @override
  String abTitle(Object id) {
    return 'Thiết bị $id';
  }

  @override
  String abBookSuccess(Object id) {
    return 'Đã mượn thiết bị $id thành công!';
  }

  @override
  String get abDeviceInfo => 'Thông tin thiết bị';

  @override
  String get abBookDevice => 'Mượn thiết bị';

  @override
  String get abMaintenanceTitle => 'Thiết bị đang bảo trì';

  @override
  String get abMaintenanceBody =>
      'Thiết bị này tạm thời không khả dụng để mượn. Vui lòng chọn thiết bị khác.';

  @override
  String get abInUseTitle => 'Thiết bị đang được sử dụng';

  @override
  String get abInUseBody =>
      'Thiết bị này đang được người dùng khác mượn. Vui lòng chọn thiết bị khác.';

  @override
  String get baTitle => 'Báo hỏng thiết bị';

  @override
  String get baCardTitle => 'Báo cáo thiết bị hỏng';

  @override
  String get baErrorNoAssetId => 'Vui lòng nhập mã thiết bị.';

  @override
  String get baErrorNoReason => 'Vui lòng nhập mô tả tình trạng hỏng.';

  @override
  String get baSuccess => 'Đã báo cáo hỏng thiết bị thành công!';

  @override
  String get baAssetCodeLabel => 'Mã thiết bị *';

  @override
  String get baReasonLabel => 'Mô tả tình trạng hỏng *';

  @override
  String get baReasonHint => 'Mô tả chi tiết vấn đề...';

  @override
  String get baSubmit => 'Gửi báo cáo';

  @override
  String get baSuccessTitle => 'Đã báo cáo thành công!';

  @override
  String get baSuccessSubtitle =>
      'Đội ngũ kỹ thuật sẽ xử lý sự cố sớm nhất có thể.';

  @override
  String get stationsEmpty => 'Không có trạm thiết bị nào.';

  @override
  String stationAvailable(int count) {
    return '$count xe trống';
  }

  @override
  String stationCapacity(int count) {
    return 'Sức chứa: $count';
  }

  @override
  String get releaseAtStation => 'Trả thiết bị tại trạm';

  @override
  String stationSlotFull(int available, int capacity) {
    return '$available/$capacity (đầy)';
  }

  @override
  String stationSlotFree(int available, int capacity) {
    return '$available/$capacity trống';
  }

  @override
  String get feedbackErrorNoRating => 'Vui lòng chọn số sao đánh giá.';

  @override
  String get feedbackThanks => 'Cảm ơn bạn đã đánh giá!';

  @override
  String feedbackSummary(int count, String rating) {
    return 'Đã có $count đánh giá • $rating★';
  }

  @override
  String get feedbackHowSatisfied => 'Bạn hài lòng mức nào?';

  @override
  String feedbackStars(int count) {
    return '$count sao';
  }

  @override
  String get feedbackCommentLabel => 'Góp ý';

  @override
  String get feedbackCommentHint => 'Nhập chia sẻ của bạn';

  @override
  String get feedbackImageTooltip => 'Tính năng đính kèm ảnh sẽ sớm có mặt';

  @override
  String get feedbackPickImage => 'Chọn ảnh (Sắp ra mắt)';

  @override
  String get feedbackSubmit => 'Gửi đánh giá';

  @override
  String get feedbackLoading => 'Đang tải đánh giá...';

  @override
  String get queuePickRoom => 'Chọn phòng khám';

  @override
  String queueOpenHours(Object hours) {
    return 'Giờ mở cửa: $hours';
  }

  @override
  String get queueUnknown => 'Không rõ';

  @override
  String get queueOpen => 'Đang mở';

  @override
  String get queueClosed => 'Đang đóng';

  @override
  String get queueRoomLabel => 'Phòng khám';

  @override
  String get queueRoomHint => 'Chọn phòng khám...';

  @override
  String get queueSelectPrompt =>
      'Hãy chọn phòng khám để xem trạng thái hàng đợi và giờ mở cửa.';

  @override
  String get queueNoRoomData => 'Không có dữ liệu phòng';

  @override
  String get queueNoQueueData => 'Không có dữ liệu hàng đợi';

  @override
  String queuePoi(Object id) {
    return 'POI #$id';
  }

  @override
  String get queueCurrentNumber => 'Số hiện tại';

  @override
  String get queueWaiting => 'Đang chờ';

  @override
  String get queueAvgWait => 'Chờ TB (phút)';

  @override
  String get presEmpty => 'Chưa có đơn thuốc';

  @override
  String get presPharmacy => 'Nhà thuốc';

  @override
  String presStatus(Object status) {
    return 'Trạng thái: $status';
  }

  @override
  String presIssuedAt(Object date) {
    return 'Ngày kê: $date';
  }

  @override
  String get presMedList => 'Danh sách thuốc';

  @override
  String get mlTitle => 'Chỉ định khám';

  @override
  String get mlEmptyTasks => 'Chưa có chỉ định nào';

  @override
  String get mlHistoryToday => 'Lịch sử hôm nay';

  @override
  String get mlNoHistory => 'Chưa có lịch sử';

  @override
  String get mlQueueSubtitle => 'Xem số thứ tự';

  @override
  String get mlPrescriptionSubtitle => 'Lịch sử đơn thuốc';

  @override
  String get mlStationsTitle => 'Trạm xe lăn';

  @override
  String get mlStationsSubtitle => 'Các trạm xe lăn';

  @override
  String get mlFindNearbyTitle => 'Tìm xe lăn gần đây';

  @override
  String get mlFindNearbySubtitle => 'Xe lăn còn trống';

  @override
  String get mlStaffTitle => 'Hỗ trợ nhân viên';

  @override
  String get mlObstacleTitle => 'Báo cáo vật cản';

  @override
  String get mlObstacleSubtitle => 'Báo lối đi bị chặn';

  @override
  String get mlInfoTitle => 'Thông tin & FAQ';

  @override
  String get mlInfoSubtitle => 'Hướng dẫn, câu hỏi';

  @override
  String get mlSyncSuccess => 'Đã đồng bộ HIS';

  @override
  String get mlSyncTooltip => 'Đồng bộ HIS';

  @override
  String get tdDetailTitle => 'Chi tiết chỉ định';

  @override
  String get tdActions => 'Thao tác';

  @override
  String get tdNoResultData => 'Không có dữ liệu kết quả';

  @override
  String get tdResultTitle => 'Kết quả';

  @override
  String tdResultBody(Object id, Object status, Object hasResult) {
    return 'Treatment: $id\nTrạng thái: $status\nCó kết quả: $hasResult';
  }

  @override
  String get tdResultHas => 'Có';

  @override
  String get tdResultNotYet => 'Chưa';

  @override
  String get tdCancelTitle => 'Hủy chỉ định';

  @override
  String get tdCancelConfirm => 'Bạn có chắc chắn muốn hủy không?';

  @override
  String get tdCancelled => 'Đã hủy chỉ định';

  @override
  String get tdCheckin => 'Check-in';

  @override
  String get tdCheckinSuccess => 'Check-in thành công';

  @override
  String get tdCheckout => 'Check-out';

  @override
  String get tdCheckoutSuccess => 'Check-out thành công';

  @override
  String tcRoom(Object name) {
    return 'Phòng: $name';
  }

  @override
  String tcWard(Object name) {
    return 'Khoa: $name';
  }

  @override
  String tcPriority(Object priority) {
    return 'Ưu tiên: $priority';
  }

  @override
  String tcSequence(Object number) {
    return 'STT: $number';
  }

  @override
  String get tcHasResult => 'Có kết quả';

  @override
  String get tcNoResult => 'Chưa có kết quả';

  @override
  String tcCheckinCompleted(Object checkin, Object completed) {
    return 'Check-in: $checkin\nHoàn tất: $completed';
  }

  @override
  String presDosage(Object dosage) {
    return 'Liều dùng: $dosage';
  }

  @override
  String presQuantity(Object quantity) {
    return 'Số lượng: $quantity';
  }

  @override
  String presInstructions(Object instructions) {
    return 'Hướng dẫn: $instructions';
  }

  @override
  String get staffTitle => 'Yêu cầu hỗ trợ';

  @override
  String get staffTypeMove => 'Hỗ trợ di chuyển';

  @override
  String get staffTypeWheelchair => 'Hỗ trợ xe lăn';

  @override
  String get staffTypeMedical => 'Hỗ trợ y tế';

  @override
  String get staffTypeOther => 'Hỗ trợ khác';

  @override
  String get staffPickLocationTitle => 'Chọn vị trí hiện tại';

  @override
  String get staffErrorSelectLocation => 'Vui lòng chọn vị trí của bạn.';

  @override
  String get staffTypeLabel => 'Loại hỗ trợ';

  @override
  String get staffCurrentLocationLabel => 'Vị trí hiện tại *';

  @override
  String get staffCurrentLocationHint => 'Chọn vị trí của bạn...';

  @override
  String get staffAssetCodeLabel => 'Mã thiết bị (nếu có)';

  @override
  String get staffAssetCodeHint => 'vd: WL-001';

  @override
  String get staffNoteLabel => 'Ghi chú thêm';

  @override
  String get staffNoteHint => 'Mô tả tình huống cần hỗ trợ...';

  @override
  String get staffSubmit => 'Gửi yêu cầu';

  @override
  String get staffSuccessTitle => 'Yêu cầu đã được gửi!';

  @override
  String get staffSuccessSubtitle =>
      'Nhân viên sẽ đến hỗ trợ bạn trong thời gian sớm nhất.';

  @override
  String get sosTitle => 'SOS — Khẩn Cấp';

  @override
  String get sosNote => 'Lưu ý';

  @override
  String get sosNoteContent =>
      '• Chỉ sử dụng khi thực sự có tình huống khẩn cấp.\n• Nhân viên y tế sẽ đến trong thời gian sớm nhất.\n• Nếu cần trợ giúp ngay, hãy gọi quầy lễ tân.';

  @override
  String get sosHelperActive => 'Đang có yêu cầu khẩn cấp';

  @override
  String get sosHelperSending => 'Đang gửi tín hiệu...';

  @override
  String get sosHelperIdle => 'Nhấn và giữ để gửi tín hiệu';

  @override
  String get sosSemanticsSend => 'Gửi tín hiệu SOS';

  @override
  String get sosSemanticsHint => 'Nhấn và giữ trong 1.2 giây để xác nhận';

  @override
  String get sosSemanticsSending => 'Đang gửi tín hiệu SOS';

  @override
  String get sosSemanticsActive =>
      'Đang có yêu cầu khẩn cấp, nhân viên đang được điều phối';

  @override
  String get sosStatusProcessing => 'Đang xử lý';

  @override
  String get sosStatusResolved => 'Đã giải quyết';

  @override
  String get sosStatusTitle => 'Trạng thái yêu cầu';

  @override
  String sosSentAt(Object time) {
    return 'Gửi lúc: $time';
  }

  @override
  String get sosNoRequest => 'Không có yêu cầu khẩn cấp';

  @override
  String get sosNoRequestSubtitle =>
      'Nhấn nút SOS phía trên nếu bạn cần hỗ trợ y tế khẩn cấp.';

  @override
  String get notifMarkAllRead => 'Đánh dấu tất cả đã đọc';

  @override
  String get notifAllRead => 'Đã đọc tất cả thông báo';

  @override
  String get notifSettings => 'Cài đặt thông báo';

  @override
  String get notifEmpty => 'Không có thông báo nào';

  @override
  String get notifDeleted => 'Đã xóa thông báo';

  @override
  String get notifAllLoaded => 'Đã tải hết thông báo';

  @override
  String get notifLoadError => 'Không thể tải thông báo';

  @override
  String get profileLogoutConfirm => 'Bạn có chắc chắn muốn đăng xuất không?';

  @override
  String get profileRemoveAvatarTitle => 'Xóa ảnh đại diện';

  @override
  String get profileRemoveAvatarConfirm =>
      'Bạn có chắc chắn muốn xóa ảnh đại diện không?';

  @override
  String get profileAvatarRemoved => 'Đã xóa ảnh đại diện.';

  @override
  String get profileAvatarRemoveError => 'Không thể xóa ảnh đại diện.';

  @override
  String get profileEditTitle => 'Chỉnh sửa hồ sơ';

  @override
  String get profileImageTooLarge =>
      'Ảnh vượt quá 10MB. Vui lòng chọn ảnh nhỏ hơn.';

  @override
  String profileUploadError(Object error) {
    return 'Không thể tải ảnh lên: $error';
  }

  @override
  String get profileAvatarUpdated => 'Cập nhật ảnh đại diện thành công.';

  @override
  String get profileAvatarUpdateError => 'Không thể cập nhật ảnh đại diện.';

  @override
  String get profileUpdated => 'Cập nhật hồ sơ thành công.';

  @override
  String get profileUpdateError => 'Không thể cập nhật hồ sơ.';

  @override
  String get profileLoadError => 'Không thể tải hồ sơ';

  @override
  String get profileDob => 'Ngày sinh';

  @override
  String get profileNotUpdated => 'Chưa cập nhật';

  @override
  String get profileGender => 'Giới tính';

  @override
  String get profileRateApp => 'Đánh giá ứng dụng';

  @override
  String get profilePickGallery => 'Thư viện';

  @override
  String get profilePickCamera => 'Máy ảnh';

  @override
  String get profileFullNameRequired => 'Vui lòng nhập họ và tên';

  @override
  String get profileInvalidDob => 'Ngày sinh không hợp lệ.';

  @override
  String get infoTitle => 'Thông tin';

  @override
  String get infoHelpSection => 'Trợ giúp & Giới thiệu';

  @override
  String get infoAbout => 'Giới thiệu';

  @override
  String get infoContact => 'Liên hệ';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqAll => 'Tất cả';

  @override
  String get faqEmpty => 'Chưa có câu hỏi thường gặp.';

  @override
  String get faqError => 'Không thể tải câu hỏi thường gặp. Vui lòng thử lại.';

  @override
  String aboutVersion(Object version) {
    return 'Phiên bản $version';
  }

  @override
  String get aboutKeyFeatures => 'Tính năng chính';

  @override
  String get aboutFeatureMedical => 'Quản lý y tế';

  @override
  String get aboutFeatureProfile => 'Hồ sơ người dùng';

  @override
  String get aboutError => 'Không thể tải thông tin. Vui lòng thử lại.';

  @override
  String get contactHospitalName => 'Bệnh viện Trung tâm';

  @override
  String get contactError =>
      'Không thể tải thông tin liên hệ. Vui lòng thử lại.';

  @override
  String get voiceGoStraight => 'Đi thẳng';

  @override
  String get voiceTurnLeft => 'Rẽ trái';

  @override
  String get voiceTurnRight => 'Rẽ phải';

  @override
  String get voiceArrived => 'Đã đến đích';

  @override
  String get voiceElevatorUp => 'Đi thang máy lên';

  @override
  String get voiceElevatorDown => 'Đi thang máy xuống';

  @override
  String get voiceStairsUp => 'Đi cầu thang lên';

  @override
  String get voiceStairsDown => 'Đi cầu thang xuống';

  @override
  String get poiPickerDefaultTitle => 'Chọn vị trí';

  @override
  String get poiFieldLabel => 'Vị trí';

  @override
  String get poiFieldHint => 'Chọn vị trí...';

  @override
  String get poiLoadError => 'Không tải được danh sách vị trí.';

  @override
  String get poiNoMap => 'Không có bản đồ khả dụng.';

  @override
  String get poiEmpty => 'Chưa có vị trí nào.';

  @override
  String poiNotFound(Object query) {
    return 'Không tìm thấy \"$query\".';
  }

  @override
  String get poiSearchHint => 'Tìm theo tên hoặc mã...';

  @override
  String get mapSemanticIdle => 'Bản đồ bệnh viện. Chọn điểm đến để bắt đầu.';

  @override
  String mapSemanticNavigating(Object dest, int steps, int distance) {
    return 'Đang chỉ đường đến $dest. $steps bước, khoảng $distance mét.';
  }

  @override
  String get rhRateRoute => 'Đánh giá tuyến';

  @override
  String get obTypeLabel => 'Loại vật cản';

  @override
  String get obstacleTypeObstacle => 'Vật cản';

  @override
  String get obstacleTypeWetFloor => 'Sàn ướt';

  @override
  String get obstacleTypeConstruction => 'Đang thi công';

  @override
  String get obstacleTypeCrowd => 'Đông người';

  @override
  String get obErrorNoLocation => 'Vui lòng nhập mã vị trí (grid location).';

  @override
  String get obErrorNotInteger => 'Mã vị trí phải là số nguyên.';

  @override
  String get obSuccess => 'Đã báo cáo vật cản thành công!';

  @override
  String get obLocationLabel => 'Mã vị trí *';

  @override
  String get obLocationHint => 'Nhập số grid location (vd: 342)';

  @override
  String get obLocationHelper => 'Tìm mã vị trí trên bản đồ hoặc hỏi nhân viên';

  @override
  String get obNoteLabel => 'Mô tả thêm';

  @override
  String get obNoteHint => 'Mô tả tình trạng vật cản...';

  @override
  String get obSuccessTitle => 'Đã gửi báo cáo!';

  @override
  String get obSuccessSubtitle =>
      'Cảm ơn bạn đã thông báo vật cản. Đội ngũ sẽ xử lý sớm nhất.';

  @override
  String get rrTitle => 'Đánh giá tuyến đường';

  @override
  String get rrThanks => 'Cảm ơn bạn đã đánh giá tuyến đường!';

  @override
  String rrRouteId(Object id) {
    return 'Mã tuyến: $id';
  }

  @override
  String get rrQuality => 'Chất lượng tuyến đường';

  @override
  String get rrCommentLabel => 'Nhận xét (tùy chọn)';

  @override
  String get rrCommentHint => 'Chia sẻ cảm nhận về tuyến đường...';

  @override
  String get rrAccurateQuestion => 'Tuyến đường có chính xác không?';

  @override
  String get rrSuccessTitle => 'Đã gửi đánh giá!';

  @override
  String get rrSuccessSubtitle =>
      'Cảm ơn bạn đã giúp cải thiện chất lượng hướng dẫn.';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navUtilities => 'Tiện ích';

  @override
  String get navMap => 'Bản đồ';

  @override
  String get navChat => 'Trò chuyện';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get homeTitle => 'Trang chủ';

  @override
  String get homeLoggedOut => 'Đã đăng xuất';

  @override
  String get homeOpenNotifications => 'Mở thông báo';

  @override
  String get homeNotificationsTitle => 'Thông báo';

  @override
  String get homeOpenMenu => 'Mở menu trang chủ';

  @override
  String get homeMenu => 'Menu';

  @override
  String get homeReloadHome => 'Tải lại trang chủ';

  @override
  String get homeReload => 'Tải lại';

  @override
  String get homeOpenSettings => 'Mở cài đặt';

  @override
  String get homeLogoutAccount => 'Đăng xuất khỏi tài khoản';

  @override
  String get homeQuickAccess => 'Truy cập nhanh';

  @override
  String get homeActionQueue => 'Hàng đợi';

  @override
  String get homeActionFindWheelchair => 'Tìm xe lăn';

  @override
  String get homeActionSupport => 'Hỗ trợ';

  @override
  String get homeActionPrescription => 'Đơn thuốc';

  @override
  String get homeActionReportObstacle => 'Báo vật cản';

  @override
  String get homeActionDeviceStations => 'Trạm thiết bị';

  @override
  String get homeOverview => 'Tổng quan';

  @override
  String get homeCurrentTasks => 'Nhiệm vụ hiện tại';

  @override
  String homeTasksActive(int count) {
    return '$count Hoạt động';
  }

  @override
  String get homeLoadingWeather => 'Đang tải thời tiết...';

  @override
  String get homeWeatherCurrent => 'Thời tiết hiện tại';

  @override
  String homeWeatherDetail(String description, int humidity, int wind) {
    return '$description • Độ ẩm $humidity% • Gió $wind km/h';
  }

  @override
  String get homeNotificationsLoading => 'Đang tải thông báo...';

  @override
  String homeNotificationsUnread(int count) {
    return 'Bạn có $count thông báo mới';
  }

  @override
  String get homeNotificationsNone => 'Không có thông báo mới';

  @override
  String get homeNotificationsTapToView => 'Nhấn để xem danh sách thông báo';

  @override
  String get homeNoBooking => 'Chưa mượn xe lăn nào';

  @override
  String get homeNoBookingSubtitle => 'Nhấn để tìm hoặc khôi phục lượt mượn';

  @override
  String homeActiveBooking(Object assetId) {
    return 'Xe lăn đang mượn · $assetId';
  }

  @override
  String get homeTrack => 'Theo dõi';

  @override
  String get homeReturnDevice => 'Trả thiết bị';

  @override
  String get logoutSheetMessage => 'Bạn sẽ phải đăng nhập lại để tiếp tục.';

  @override
  String get mapPreviewOpen => 'Mở bản đồ bệnh viện';

  @override
  String get mapPreviewTitle => 'Bản đồ bệnh viện';

  @override
  String get mapPreviewSubtitle => 'Tìm đường đến phòng ban';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsLoadError => 'Không thể tải cài đặt';

  @override
  String get settingsSaveError => 'Không thể lưu cài đặt';

  @override
  String get settingsSectionAccount => 'Tài khoản';

  @override
  String get settingsChangePassword => 'Đổi mật khẩu';

  @override
  String get settingsLogout => 'Đăng xuất';

  @override
  String get settingsLogoutConfirmTitle => 'Đăng xuất';

  @override
  String get settingsLogoutConfirmMessage =>
      'Bạn có chắc muốn đăng xuất khỏi ứng dụng?';

  @override
  String get settingsDeleteAccount => 'Xóa tài khoản';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Xóa vĩnh viễn tài khoản và dữ liệu';

  @override
  String get settingsSectionAppearance => 'Giao diện';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeSystem => 'Hệ thống';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsSectionNotification => 'Thông báo';

  @override
  String get settingsEnableNotification => 'Bật thông báo';

  @override
  String get settingsEnableNotificationSubtitle => 'Nhận thông báo từ hệ thống';

  @override
  String get settingsSectionLanguage => 'Ngôn ngữ';

  @override
  String get settingsDisplayLanguage => 'Ngôn ngữ hiển thị';

  @override
  String get settingsLanguageVietnamese => 'Tiếng Việt';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsSectionOffline => 'Dữ liệu ngoại tuyến';

  @override
  String get settingsClearMapCache => 'Xóa bộ nhớ đệm bản đồ';

  @override
  String get settingsClearMapCacheSubtitle =>
      'Gỡ dữ liệu bản đồ và lộ trình đã tải về thiết bị';

  @override
  String get settingsClearMapCacheConfirm =>
      'Thao tác này gỡ dữ liệu bản đồ và lộ trình đã tải về thiết bị. Ứng dụng sẽ tải lại khi cần.';

  @override
  String get settingsClearMapCacheSuccess => 'Đã xóa bộ nhớ đệm bản đồ';

  @override
  String get settingsSectionAppInfo => 'Thông tin ứng dụng';

  @override
  String get settingsHelp => 'Trợ giúp';

  @override
  String get settingsAbout => 'Về ứng dụng';

  @override
  String get settingsVersion => 'Phiên bản';

  @override
  String get settingsAboutDescription =>
      'Ứng dụng hỗ trợ bệnh nhân tra cứu thông tin, điều hướng nội viện và quản lý lịch khám bệnh.';

  @override
  String get settingsDeletePasswordIncorrect =>
      'Mật khẩu không chính xác. Vui lòng thử lại.';
}
