import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get commonConfirm;

  /// No description provided for @commonClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get commonRetry;

  /// No description provided for @commonError.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi, vui lòng thử lại'**
  String get commonError;

  /// No description provided for @commonOk.
  ///
  /// In vi, this message translates to:
  /// **'Đồng ý'**
  String get commonOk;

  /// No description provided for @commonYes.
  ///
  /// In vi, this message translates to:
  /// **'Có'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In vi, this message translates to:
  /// **'Không'**
  String get commonNo;

  /// No description provided for @commonLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get commonLoading;

  /// No description provided for @commonProcessing.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý...'**
  String get commonProcessing;

  /// No description provided for @commonBack.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get commonNext;

  /// No description provided for @commonDone.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất'**
  String get commonDone;

  /// No description provided for @commonContinue.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get commonContinue;

  /// No description provided for @commonErrorShort.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi'**
  String get commonErrorShort;

  /// No description provided for @errBadRequest.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu không hợp lệ.'**
  String get errBadRequest;

  /// No description provided for @errMissingParameter.
  ///
  /// In vi, this message translates to:
  /// **'Thiếu thông tin bắt buộc.'**
  String get errMissingParameter;

  /// No description provided for @errInvalidParameterType.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu gửi lên không hợp lệ.'**
  String get errInvalidParameterType;

  /// No description provided for @errInvalidParameterValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị không hợp lệ.'**
  String get errInvalidParameterValue;

  /// No description provided for @errMethodNotAllowed.
  ///
  /// In vi, this message translates to:
  /// **'Thao tác không được hỗ trợ.'**
  String get errMethodNotAllowed;

  /// No description provided for @errAccessDenied.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không có quyền thực hiện thao tác này.'**
  String get errAccessDenied;

  /// No description provided for @errLimitExceeded.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang mượn thiết bị khác, vui lòng trả trước khi mượn thêm.'**
  String get errLimitExceeded;

  /// No description provided for @errOtpIncorrect.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP không đúng.'**
  String get errOtpIncorrect;

  /// No description provided for @errOtpExpired.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP đã hết hạn.'**
  String get errOtpExpired;

  /// No description provided for @errUserExists.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản đã tồn tại.'**
  String get errUserExists;

  /// No description provided for @errUserNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy tài khoản.'**
  String get errUserNotFound;

  /// No description provided for @errPasswordIncorrect.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không đúng.'**
  String get errPasswordIncorrect;

  /// No description provided for @errMapNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy thông tin phù hợp trên hệ thống.'**
  String get errMapNotFound;

  /// No description provided for @errInvalidStart.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí bắt đầu không hợp lệ.'**
  String get errInvalidStart;

  /// No description provided for @errInvalidDestination.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đến không hợp lệ.'**
  String get errInvalidDestination;

  /// No description provided for @errPathNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy đường đi phù hợp.'**
  String get errPathNotFound;

  /// No description provided for @errInvalidLocationData.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu vị trí không hợp lệ.'**
  String get errInvalidLocationData;

  /// No description provided for @errDensityUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu mật độ tạm thời không khả dụng.'**
  String get errDensityUnavailable;

  /// No description provided for @errTaskNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy nhiệm vụ.'**
  String get errTaskNotFound;

  /// No description provided for @errAssetNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy thiết bị.'**
  String get errAssetNotFound;

  /// No description provided for @errAssetNotAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị hiện không khả dụng.'**
  String get errAssetNotAvailable;

  /// No description provided for @errServer.
  ///
  /// In vi, this message translates to:
  /// **'Máy chủ đang gặp sự cố, vui lòng thử lại sau.'**
  String get errServer;

  /// No description provided for @errHisUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống bệnh viện tạm thời không phản hồi, vui lòng thử lại sau.'**
  String get errHisUnavailable;

  /// No description provided for @errAccountElsewhere.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản đã đăng nhập trên thiết bị khác. Vui lòng đăng nhập lại.'**
  String get errAccountElsewhere;

  /// No description provided for @errSessionEnded.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đăng nhập đã kết thúc. Vui lòng đăng nhập lại.'**
  String get errSessionEnded;

  /// No description provided for @errTimeout.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối tới máy chủ quá hạn, vui lòng thử lại.'**
  String get errTimeout;

  /// No description provided for @errCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu đã bị hủy.'**
  String get errCancelled;

  /// No description provided for @errNoNetwork.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối mạng.'**
  String get errNoNetwork;

  /// No description provided for @errDataNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy dữ liệu.'**
  String get errDataNotFound;

  /// No description provided for @daConfirmBody.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa tài khoản của mình không?\nHành động này không thể đảo ngược.\nTất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.'**
  String get daConfirmBody;

  /// No description provided for @daPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa tài khoản'**
  String get daPasswordTitle;

  /// No description provided for @daPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu của bạn'**
  String get daPasswordHint;

  /// No description provided for @daSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản đã được xóa thành công'**
  String get daSuccessTitle;

  /// No description provided for @daSuccessBody.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản của bạn đã được xóa thành công.'**
  String get daSuccessBody;

  /// No description provided for @daErrorTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi'**
  String get daErrorTitle;

  /// No description provided for @vgUpdateTitle.
  ///
  /// In vi, this message translates to:
  /// **'Có bản cập nhật mới'**
  String get vgUpdateTitle;

  /// No description provided for @vgNewVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản mới: {version}'**
  String vgNewVersion(Object version);

  /// No description provided for @vgLater.
  ///
  /// In vi, this message translates to:
  /// **'Để sau'**
  String get vgLater;

  /// No description provided for @vgUpdate.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật'**
  String get vgUpdate;

  /// No description provided for @assetInUseOrNoPermission.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị này đang được người dùng khác sử dụng, hoặc bạn không có quyền theo dõi thiết bị này.'**
  String get assetInUseOrNoPermission;

  /// No description provided for @assetGenericError.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi, vui lòng thử lại.'**
  String get assetGenericError;

  /// No description provided for @chatImagePlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'[Hình ảnh]'**
  String get chatImagePlaceholder;

  /// No description provided for @chatVoicePlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'[Tin nhắn thoại]'**
  String get chatVoicePlaceholder;

  /// No description provided for @chatSupportDefault.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ bệnh nhân'**
  String get chatSupportDefault;

  /// No description provided for @chatRoomsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn'**
  String get chatRoomsTitle;

  /// No description provided for @chatNoConversations.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có cuộc trò chuyện nào'**
  String get chatNoConversations;

  /// No description provided for @chatLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải tin nhắn'**
  String get chatLoadError;

  /// No description provided for @chatRoomDefault.
  ///
  /// In vi, this message translates to:
  /// **'Phòng chat'**
  String get chatRoomDefault;

  /// No description provided for @chatNoMessages.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tin nhắn'**
  String get chatNoMessages;

  /// No description provided for @chatYesterday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm qua'**
  String get chatYesterday;

  /// No description provided for @chatNoMessagesYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tin nhắn nào'**
  String get chatNoMessagesYet;

  /// No description provided for @chatLoadOlder.
  ///
  /// In vi, this message translates to:
  /// **'Tải tin nhắn cũ hơn'**
  String get chatLoadOlder;

  /// No description provided for @chatSendImage.
  ///
  /// In vi, this message translates to:
  /// **'Gửi ảnh'**
  String get chatSendImage;

  /// No description provided for @chatInputHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tin nhắn...'**
  String get chatInputHint;

  /// No description provided for @chatNewMessages.
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn mới'**
  String get chatNewMessages;

  /// No description provided for @chatMsgRead.
  ///
  /// In vi, this message translates to:
  /// **'✓✓ Đã xem'**
  String get chatMsgRead;

  /// No description provided for @chatMsgSent.
  ///
  /// In vi, this message translates to:
  /// **'✓ Đã gửi'**
  String get chatMsgSent;

  /// No description provided for @chatImageLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải ảnh'**
  String get chatImageLoadError;

  /// No description provided for @chatVoiceMessage.
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn thoại'**
  String get chatVoiceMessage;

  /// No description provided for @senderPatient.
  ///
  /// In vi, this message translates to:
  /// **'Bệnh nhân'**
  String get senderPatient;

  /// No description provided for @senderAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị viên'**
  String get senderAdmin;

  /// No description provided for @senderCoordinator.
  ///
  /// In vi, this message translates to:
  /// **'Điều phối viên'**
  String get senderCoordinator;

  /// No description provided for @senderStaff.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên hỗ trợ'**
  String get senderStaff;

  /// No description provided for @chatEmptyContent.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung tin nhắn không được để trống'**
  String get chatEmptyContent;

  /// No description provided for @sosSentMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi tín hiệu SOS. Nhân viên đang trên đường đến!'**
  String get sosSentMessage;

  /// No description provided for @authPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get authPhone;

  /// No description provided for @authPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get authPassword;

  /// No description provided for @authHide.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn'**
  String get authHide;

  /// No description provided for @authShow.
  ///
  /// In vi, this message translates to:
  /// **'Hiện'**
  String get authShow;

  /// No description provided for @welcomeLogoutSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng xuất thành công.'**
  String get welcomeLogoutSuccess;

  /// No description provided for @welcomeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng trở lại!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đăng nhập của bạn đã được lưu an toàn. Tiếp tục sử dụng ứng dụng hoặc đăng xuất khi hoàn tất.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeContinue.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục vào ứng dụng'**
  String get welcomeContinue;

  /// No description provided for @loginErrorEmptyFields.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số điện thoại và mật khẩu.'**
  String get loginErrorEmptyFields;

  /// No description provided for @loginSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thành công.'**
  String get loginSuccess;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng trở lại'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để tiếp tục chăm sóc sức khỏe'**
  String get loginSubtitle;

  /// No description provided for @loginCredentials.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin đăng nhập'**
  String get loginCredentials;

  /// No description provided for @loginForgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản?'**
  String get loginNoAccount;

  /// No description provided for @loginRegisterNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký ngay'**
  String get loginRegisterNow;

  /// No description provided for @authLogin.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get authLogin;

  /// No description provided for @authRememberedPassword.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhớ mật khẩu?'**
  String get authRememberedPassword;

  /// No description provided for @authPasswordNew.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới'**
  String get authPasswordNew;

  /// No description provided for @authConfirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get authConfirmPassword;

  /// No description provided for @forgotErrorEmptyPhone.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số điện thoại.'**
  String get forgotErrorEmptyPhone;

  /// No description provided for @forgotOtpSent.
  ///
  /// In vi, this message translates to:
  /// **'Mã xác thực đã được gửi.'**
  String get forgotOtpSent;

  /// No description provided for @forgotSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số điện thoại để nhận mã xác thực'**
  String get forgotSubtitle;

  /// No description provided for @forgotVerifyAccount.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh tài khoản'**
  String get forgotVerifyAccount;

  /// No description provided for @forgotSendOtp.
  ///
  /// In vi, this message translates to:
  /// **'Gửi mã xác thực'**
  String get forgotSendOtp;

  /// No description provided for @resetErrorEmptyFields.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng điền tất cả các trường.'**
  String get resetErrorEmptyFields;

  /// No description provided for @resetErrorShortPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có ít nhất 6 ký tự.'**
  String get resetErrorShortPassword;

  /// No description provided for @resetErrorMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không khớp.'**
  String get resetErrorMismatch;

  /// No description provided for @resetSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu đã được đặt lại thành công.'**
  String get resetSuccess;

  /// No description provided for @resetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo mật khẩu mới cho tài khoản của bạn'**
  String get resetSubtitle;

  /// No description provided for @authHidePassword.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn mật khẩu'**
  String get authHidePassword;

  /// No description provided for @authShowPassword.
  ///
  /// In vi, this message translates to:
  /// **'Hiện mật khẩu'**
  String get authShowPassword;

  /// No description provided for @genderMale.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get genderOther;

  /// No description provided for @registerErrorSelectDob.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn ngày sinh.'**
  String get registerErrorSelectDob;

  /// No description provided for @registerErrorMinAge.
  ///
  /// In vi, this message translates to:
  /// **'Bạn phải ít nhất 13 tuổi để đăng ký.'**
  String get registerErrorMinAge;

  /// No description provided for @registerSelectDob.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày sinh'**
  String get registerSelectDob;

  /// No description provided for @registerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia cùng chúng tôi để được hỗ trợ tốt nhất'**
  String get registerSubtitle;

  /// No description provided for @registerPersonalInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get registerPersonalInfo;

  /// No description provided for @registerFullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get registerFullName;

  /// No description provided for @registerFullNameError.
  ///
  /// In vi, this message translates to:
  /// **'Nhập họ tên của bạn'**
  String get registerFullNameError;

  /// No description provided for @registerPhoneInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại không hợp lệ'**
  String get registerPhoneInvalid;

  /// No description provided for @registerSecurityInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin bảo mật'**
  String get registerSecurityInfo;

  /// No description provided for @registerPasswordMin.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu tối thiểu 6 ký tự'**
  String get registerPasswordMin;

  /// No description provided for @registerConfirmPasswordError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xác nhận mật khẩu'**
  String get registerConfirmPasswordError;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không khớp'**
  String get registerPasswordMismatch;

  /// No description provided for @registerButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản?'**
  String get registerHaveAccount;

  /// No description provided for @registerLoginNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập ngay'**
  String get registerLoginNow;

  /// No description provided for @otpResent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi lại mã'**
  String get otpResent;

  /// No description provided for @otpErrorIncomplete.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập đầy đủ mã OTP.'**
  String get otpErrorIncomplete;

  /// No description provided for @otpContinueReset.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục đặt lại mật khẩu.'**
  String get otpContinueReset;

  /// No description provided for @otpVerifySuccess.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực thành công!'**
  String get otpVerifySuccess;

  /// No description provided for @otpTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực OTP'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP đã được gửi đến số {phone}'**
  String otpSentTo(String phone);

  /// No description provided for @otpFilled.
  ///
  /// In vi, this message translates to:
  /// **'Đã điền mã OTP'**
  String get otpFilled;

  /// No description provided for @otpMockLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP (mock)'**
  String get otpMockLabel;

  /// No description provided for @otpResendButton.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã'**
  String get otpResendButton;

  /// No description provided for @otpResendError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể gửi lại mã. Vui lòng thử lại.'**
  String get otpResendError;

  /// No description provided for @changePwdErrorShortNew.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới phải có ít nhất 6 ký tự.'**
  String get changePwdErrorShortNew;

  /// No description provided for @changePwdErrorMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới không khớp.'**
  String get changePwdErrorMismatch;

  /// No description provided for @changePwdErrorSameAsOld.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới phải khác mật khẩu cũ.'**
  String get changePwdErrorSameAsOld;

  /// No description provided for @changePwdSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu đã được thay đổi thành công.'**
  String get changePwdSuccess;

  /// No description provided for @changePwdSessionExpired.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.'**
  String get changePwdSessionExpired;

  /// No description provided for @changePwdTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi mật khẩu'**
  String get changePwdTitle;

  /// No description provided for @changePwdSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật mật khẩu để bảo mật tài khoản'**
  String get changePwdSubtitle;

  /// No description provided for @changePwdVerifySection.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh mật khẩu'**
  String get changePwdVerifySection;

  /// No description provided for @changePwdCurrentHint.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu hiện tại'**
  String get changePwdCurrentHint;

  /// No description provided for @changePwdConfirmHint.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu mới'**
  String get changePwdConfirmHint;

  /// No description provided for @deviceRefresh.
  ///
  /// In vi, this message translates to:
  /// **'Làm mới'**
  String get deviceRefresh;

  /// No description provided for @mwTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xe lăn của tôi'**
  String get mwTitle;

  /// No description provided for @mwReleaseSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã trả thiết bị thành công!'**
  String get mwReleaseSuccess;

  /// No description provided for @mwNoBookingFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy lượt mượn nào của bạn.'**
  String get mwNoBookingFound;

  /// No description provided for @mwRecovered.
  ///
  /// In vi, this message translates to:
  /// **'Đã khôi phục lượt mượn: {id}'**
  String mwRecovered(Object id);

  /// No description provided for @mwPickTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn xe lăn của bạn'**
  String get mwPickTitle;

  /// No description provided for @mwPickContent.
  ///
  /// In vi, this message translates to:
  /// **'Có nhiều xe lăn đang được mượn. Chọn đúng xe của bạn:'**
  String get mwPickContent;

  /// No description provided for @mwAdopted.
  ///
  /// In vi, this message translates to:
  /// **'Đã chọn lượt mượn: {id}'**
  String mwAdopted(Object id);

  /// No description provided for @mwBorrowing.
  ///
  /// In vi, this message translates to:
  /// **'Đang mượn · {id}'**
  String mwBorrowing(Object id);

  /// No description provided for @mwStatus.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái: {status}'**
  String mwStatus(Object status);

  /// No description provided for @mwBattery.
  ///
  /// In vi, this message translates to:
  /// **'Pin {level}'**
  String mwBattery(Object level);

  /// No description provided for @mwTrackLocation.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi vị trí'**
  String get mwTrackLocation;

  /// No description provided for @mwReportBroken.
  ///
  /// In vi, this message translates to:
  /// **'Báo hỏng'**
  String get mwReportBroken;

  /// No description provided for @mwChecking.
  ///
  /// In vi, this message translates to:
  /// **'Đang kiểm tra lượt mượn của bạn...'**
  String get mwChecking;

  /// No description provided for @mwEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa mượn xe lăn nào'**
  String get mwEmptyTitle;

  /// No description provided for @mwEmptySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nếu bạn đã mượn trên thiết bị khác, hãy khôi phục lượt mượn.'**
  String get mwEmptySubtitle;

  /// No description provided for @mwRecoverBooking.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục lượt mượn'**
  String get mwRecoverBooking;

  /// No description provided for @wsPickLocationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn vị trí của bạn'**
  String get wsPickLocationTitle;

  /// No description provided for @wsYourLocation.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí của bạn'**
  String get wsYourLocation;

  /// No description provided for @wsYourLocationHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn vị trí để tìm xe lăn gần đó...'**
  String get wsYourLocationHint;

  /// No description provided for @wsEnterLocationPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã vị trí để tìm xe lăn gần đó'**
  String get wsEnterLocationPrompt;

  /// No description provided for @wsNoWheelchairs.
  ///
  /// In vi, this message translates to:
  /// **'Không có xe lăn trống gần vị trí này.'**
  String get wsNoWheelchairs;

  /// No description provided for @wsAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Có sẵn'**
  String get wsAvailable;

  /// No description provided for @wsUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Không khả dụng'**
  String get wsUnavailable;

  /// No description provided for @wsBatteryPercent.
  ///
  /// In vi, this message translates to:
  /// **'Pin: {level}%'**
  String wsBatteryPercent(Object level);

  /// No description provided for @wsDistance.
  ///
  /// In vi, this message translates to:
  /// **'Cách {distance}m'**
  String wsDistance(Object distance);

  /// No description provided for @wsBorrow.
  ///
  /// In vi, this message translates to:
  /// **'Mượn'**
  String get wsBorrow;

  /// No description provided for @trackTitle.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí {id}'**
  String trackTitle(Object id);

  /// No description provided for @trackInfoTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin theo dõi'**
  String get trackInfoTitle;

  /// No description provided for @trackAssetCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã thiết bị'**
  String get trackAssetCode;

  /// No description provided for @trackStatus.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get trackStatus;

  /// No description provided for @trackMoving.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển động'**
  String get trackMoving;

  /// No description provided for @trackCurrentPos.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí hiện tại'**
  String get trackCurrentPos;

  /// No description provided for @trackCondition.
  ///
  /// In vi, this message translates to:
  /// **'Tình trạng'**
  String get trackCondition;

  /// No description provided for @trackBattery.
  ///
  /// In vi, this message translates to:
  /// **'Pin'**
  String get trackBattery;

  /// No description provided for @abTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị {id}'**
  String abTitle(Object id);

  /// No description provided for @abBookSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã mượn thiết bị {id} thành công!'**
  String abBookSuccess(Object id);

  /// No description provided for @abDeviceInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin thiết bị'**
  String get abDeviceInfo;

  /// No description provided for @abBookDevice.
  ///
  /// In vi, this message translates to:
  /// **'Mượn thiết bị'**
  String get abBookDevice;

  /// No description provided for @abMaintenanceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị đang bảo trì'**
  String get abMaintenanceTitle;

  /// No description provided for @abMaintenanceBody.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị này tạm thời không khả dụng để mượn. Vui lòng chọn thiết bị khác.'**
  String get abMaintenanceBody;

  /// No description provided for @abInUseTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị đang được sử dụng'**
  String get abInUseTitle;

  /// No description provided for @abInUseBody.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị này đang được người dùng khác mượn. Vui lòng chọn thiết bị khác.'**
  String get abInUseBody;

  /// No description provided for @baTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo hỏng thiết bị'**
  String get baTitle;

  /// No description provided for @baCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo thiết bị hỏng'**
  String get baCardTitle;

  /// No description provided for @baErrorNoAssetId.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mã thiết bị.'**
  String get baErrorNoAssetId;

  /// No description provided for @baErrorNoReason.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mô tả tình trạng hỏng.'**
  String get baErrorNoReason;

  /// No description provided for @baSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã báo cáo hỏng thiết bị thành công!'**
  String get baSuccess;

  /// No description provided for @baAssetCodeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã thiết bị *'**
  String get baAssetCodeLabel;

  /// No description provided for @baReasonLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả tình trạng hỏng *'**
  String get baReasonLabel;

  /// No description provided for @baReasonHint.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả chi tiết vấn đề...'**
  String get baReasonHint;

  /// No description provided for @baSubmit.
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo cáo'**
  String get baSubmit;

  /// No description provided for @baSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã báo cáo thành công!'**
  String get baSuccessTitle;

  /// No description provided for @baSuccessSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đội ngũ kỹ thuật sẽ xử lý sự cố sớm nhất có thể.'**
  String get baSuccessSubtitle;

  /// No description provided for @stationsEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Không có trạm thiết bị nào.'**
  String get stationsEmpty;

  /// No description provided for @stationAvailable.
  ///
  /// In vi, this message translates to:
  /// **'{count} xe trống'**
  String stationAvailable(int count);

  /// No description provided for @stationCapacity.
  ///
  /// In vi, this message translates to:
  /// **'Sức chứa: {count}'**
  String stationCapacity(int count);

  /// No description provided for @releaseAtStation.
  ///
  /// In vi, this message translates to:
  /// **'Trả thiết bị tại trạm'**
  String get releaseAtStation;

  /// No description provided for @stationSlotFull.
  ///
  /// In vi, this message translates to:
  /// **'{available}/{capacity} (đầy)'**
  String stationSlotFull(int available, int capacity);

  /// No description provided for @stationSlotFree.
  ///
  /// In vi, this message translates to:
  /// **'{available}/{capacity} trống'**
  String stationSlotFree(int available, int capacity);

  /// No description provided for @feedbackErrorNoRating.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn số sao đánh giá.'**
  String get feedbackErrorNoRating;

  /// No description provided for @feedbackThanks.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn đã đánh giá!'**
  String get feedbackThanks;

  /// No description provided for @feedbackSummary.
  ///
  /// In vi, this message translates to:
  /// **'Đã có {count} đánh giá • {rating}★'**
  String feedbackSummary(int count, String rating);

  /// No description provided for @feedbackHowSatisfied.
  ///
  /// In vi, this message translates to:
  /// **'Bạn hài lòng mức nào?'**
  String get feedbackHowSatisfied;

  /// No description provided for @feedbackStars.
  ///
  /// In vi, this message translates to:
  /// **'{count} sao'**
  String feedbackStars(int count);

  /// No description provided for @feedbackCommentLabel.
  ///
  /// In vi, this message translates to:
  /// **'Góp ý'**
  String get feedbackCommentLabel;

  /// No description provided for @feedbackCommentHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập chia sẻ của bạn'**
  String get feedbackCommentHint;

  /// No description provided for @feedbackImageTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng đính kèm ảnh sẽ sớm có mặt'**
  String get feedbackImageTooltip;

  /// No description provided for @feedbackPickImage.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh (Sắp ra mắt)'**
  String get feedbackPickImage;

  /// No description provided for @feedbackSubmit.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đánh giá'**
  String get feedbackSubmit;

  /// No description provided for @feedbackLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải đánh giá...'**
  String get feedbackLoading;

  /// No description provided for @queuePickRoom.
  ///
  /// In vi, this message translates to:
  /// **'Chọn phòng khám'**
  String get queuePickRoom;

  /// No description provided for @queueOpenHours.
  ///
  /// In vi, this message translates to:
  /// **'Giờ mở cửa: {hours}'**
  String queueOpenHours(Object hours);

  /// No description provided for @queueUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Không rõ'**
  String get queueUnknown;

  /// No description provided for @queueOpen.
  ///
  /// In vi, this message translates to:
  /// **'Đang mở'**
  String get queueOpen;

  /// No description provided for @queueClosed.
  ///
  /// In vi, this message translates to:
  /// **'Đang đóng'**
  String get queueClosed;

  /// No description provided for @queueRoomLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phòng khám'**
  String get queueRoomLabel;

  /// No description provided for @queueRoomHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn phòng khám...'**
  String get queueRoomHint;

  /// No description provided for @queueSelectPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Hãy chọn phòng khám để xem trạng thái hàng đợi và giờ mở cửa.'**
  String get queueSelectPrompt;

  /// No description provided for @queueNoRoomData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu phòng'**
  String get queueNoRoomData;

  /// No description provided for @queueNoQueueData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu hàng đợi'**
  String get queueNoQueueData;

  /// No description provided for @queuePoi.
  ///
  /// In vi, this message translates to:
  /// **'POI #{id}'**
  String queuePoi(Object id);

  /// No description provided for @queueCurrentNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số hiện tại'**
  String get queueCurrentNumber;

  /// No description provided for @queueWaiting.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ'**
  String get queueWaiting;

  /// No description provided for @queueAvgWait.
  ///
  /// In vi, this message translates to:
  /// **'Chờ TB (phút)'**
  String get queueAvgWait;

  /// No description provided for @presEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đơn thuốc'**
  String get presEmpty;

  /// No description provided for @presPharmacy.
  ///
  /// In vi, this message translates to:
  /// **'Nhà thuốc'**
  String get presPharmacy;

  /// No description provided for @presStatus.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái: {status}'**
  String presStatus(Object status);

  /// No description provided for @presIssuedAt.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kê: {date}'**
  String presIssuedAt(Object date);

  /// No description provided for @presMedList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách thuốc'**
  String get presMedList;

  /// No description provided for @mlTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ định khám'**
  String get mlTitle;

  /// No description provided for @mlEmptyTasks.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có chỉ định nào'**
  String get mlEmptyTasks;

  /// No description provided for @mlHistoryToday.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử hôm nay'**
  String get mlHistoryToday;

  /// No description provided for @mlNoHistory.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lịch sử'**
  String get mlNoHistory;

  /// No description provided for @mlQueueSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Xem số thứ tự'**
  String get mlQueueSubtitle;

  /// No description provided for @mlPrescriptionSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử đơn thuốc'**
  String get mlPrescriptionSubtitle;

  /// No description provided for @mlStationsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trạm xe lăn'**
  String get mlStationsTitle;

  /// No description provided for @mlStationsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Các trạm xe lăn'**
  String get mlStationsSubtitle;

  /// No description provided for @mlFindNearbyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tìm xe lăn gần đây'**
  String get mlFindNearbyTitle;

  /// No description provided for @mlFindNearbySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Xe lăn còn trống'**
  String get mlFindNearbySubtitle;

  /// No description provided for @mlStaffTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ nhân viên'**
  String get mlStaffTitle;

  /// No description provided for @mlObstacleTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo vật cản'**
  String get mlObstacleTitle;

  /// No description provided for @mlObstacleSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo lối đi bị chặn'**
  String get mlObstacleSubtitle;

  /// No description provided for @mlInfoTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin & FAQ'**
  String get mlInfoTitle;

  /// No description provided for @mlInfoSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hướng dẫn, câu hỏi'**
  String get mlInfoSubtitle;

  /// No description provided for @mlSyncSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã đồng bộ HIS'**
  String get mlSyncSuccess;

  /// No description provided for @mlSyncTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ HIS'**
  String get mlSyncTooltip;

  /// No description provided for @tdDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết chỉ định'**
  String get tdDetailTitle;

  /// No description provided for @tdActions.
  ///
  /// In vi, this message translates to:
  /// **'Thao tác'**
  String get tdActions;

  /// No description provided for @tdNoResultData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu kết quả'**
  String get tdNoResultData;

  /// No description provided for @tdResultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả'**
  String get tdResultTitle;

  /// No description provided for @tdResultBody.
  ///
  /// In vi, this message translates to:
  /// **'Treatment: {id}\nTrạng thái: {status}\nCó kết quả: {hasResult}'**
  String tdResultBody(Object id, Object status, Object hasResult);

  /// No description provided for @tdResultHas.
  ///
  /// In vi, this message translates to:
  /// **'Có'**
  String get tdResultHas;

  /// No description provided for @tdResultNotYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa'**
  String get tdResultNotYet;

  /// No description provided for @tdCancelTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hủy chỉ định'**
  String get tdCancelTitle;

  /// No description provided for @tdCancelConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn hủy không?'**
  String get tdCancelConfirm;

  /// No description provided for @tdCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy chỉ định'**
  String get tdCancelled;

  /// No description provided for @tdCheckin.
  ///
  /// In vi, this message translates to:
  /// **'Check-in'**
  String get tdCheckin;

  /// No description provided for @tdCheckinSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Check-in thành công'**
  String get tdCheckinSuccess;

  /// No description provided for @tdCheckout.
  ///
  /// In vi, this message translates to:
  /// **'Check-out'**
  String get tdCheckout;

  /// No description provided for @tdCheckoutSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Check-out thành công'**
  String get tdCheckoutSuccess;

  /// No description provided for @tcRoom.
  ///
  /// In vi, this message translates to:
  /// **'Phòng: {name}'**
  String tcRoom(Object name);

  /// No description provided for @tcWard.
  ///
  /// In vi, this message translates to:
  /// **'Khoa: {name}'**
  String tcWard(Object name);

  /// No description provided for @tcPriority.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên: {priority}'**
  String tcPriority(Object priority);

  /// No description provided for @tcSequence.
  ///
  /// In vi, this message translates to:
  /// **'STT: {number}'**
  String tcSequence(Object number);

  /// No description provided for @tcHasResult.
  ///
  /// In vi, this message translates to:
  /// **'Có kết quả'**
  String get tcHasResult;

  /// No description provided for @tcNoResult.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có kết quả'**
  String get tcNoResult;

  /// No description provided for @tcCheckinCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Check-in: {checkin}\nHoàn tất: {completed}'**
  String tcCheckinCompleted(Object checkin, Object completed);

  /// No description provided for @presDosage.
  ///
  /// In vi, this message translates to:
  /// **'Liều dùng: {dosage}'**
  String presDosage(Object dosage);

  /// No description provided for @presQuantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng: {quantity}'**
  String presQuantity(Object quantity);

  /// No description provided for @presInstructions.
  ///
  /// In vi, this message translates to:
  /// **'Hướng dẫn: {instructions}'**
  String presInstructions(Object instructions);

  /// No description provided for @staffTitle.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu hỗ trợ'**
  String get staffTitle;

  /// No description provided for @staffTypeMove.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ di chuyển'**
  String get staffTypeMove;

  /// No description provided for @staffTypeWheelchair.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ xe lăn'**
  String get staffTypeWheelchair;

  /// No description provided for @staffTypeMedical.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ y tế'**
  String get staffTypeMedical;

  /// No description provided for @staffTypeOther.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ khác'**
  String get staffTypeOther;

  /// No description provided for @staffPickLocationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn vị trí hiện tại'**
  String get staffPickLocationTitle;

  /// No description provided for @staffErrorSelectLocation.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn vị trí của bạn.'**
  String get staffErrorSelectLocation;

  /// No description provided for @staffTypeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Loại hỗ trợ'**
  String get staffTypeLabel;

  /// No description provided for @staffCurrentLocationLabel.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí hiện tại *'**
  String get staffCurrentLocationLabel;

  /// No description provided for @staffCurrentLocationHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn vị trí của bạn...'**
  String get staffCurrentLocationHint;

  /// No description provided for @staffAssetCodeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã thiết bị (nếu có)'**
  String get staffAssetCodeLabel;

  /// No description provided for @staffAssetCodeHint.
  ///
  /// In vi, this message translates to:
  /// **'vd: WL-001'**
  String get staffAssetCodeHint;

  /// No description provided for @staffNoteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú thêm'**
  String get staffNoteLabel;

  /// No description provided for @staffNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả tình huống cần hỗ trợ...'**
  String get staffNoteHint;

  /// No description provided for @staffSubmit.
  ///
  /// In vi, this message translates to:
  /// **'Gửi yêu cầu'**
  String get staffSubmit;

  /// No description provided for @staffSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu đã được gửi!'**
  String get staffSuccessTitle;

  /// No description provided for @staffSuccessSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên sẽ đến hỗ trợ bạn trong thời gian sớm nhất.'**
  String get staffSuccessSubtitle;

  /// No description provided for @sosTitle.
  ///
  /// In vi, this message translates to:
  /// **'SOS — Khẩn Cấp'**
  String get sosTitle;

  /// No description provided for @sosNote.
  ///
  /// In vi, this message translates to:
  /// **'Lưu ý'**
  String get sosNote;

  /// No description provided for @sosNoteContent.
  ///
  /// In vi, this message translates to:
  /// **'• Chỉ sử dụng khi thực sự có tình huống khẩn cấp.\n• Nhân viên y tế sẽ đến trong thời gian sớm nhất.\n• Nếu cần trợ giúp ngay, hãy gọi quầy lễ tân.'**
  String get sosNoteContent;

  /// No description provided for @sosHelperActive.
  ///
  /// In vi, this message translates to:
  /// **'Đang có yêu cầu khẩn cấp'**
  String get sosHelperActive;

  /// No description provided for @sosHelperSending.
  ///
  /// In vi, this message translates to:
  /// **'Đang gửi tín hiệu...'**
  String get sosHelperSending;

  /// No description provided for @sosHelperIdle.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn và giữ để gửi tín hiệu'**
  String get sosHelperIdle;

  /// No description provided for @sosSemanticsSend.
  ///
  /// In vi, this message translates to:
  /// **'Gửi tín hiệu SOS'**
  String get sosSemanticsSend;

  /// No description provided for @sosSemanticsHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn và giữ trong 1.2 giây để xác nhận'**
  String get sosSemanticsHint;

  /// No description provided for @sosSemanticsSending.
  ///
  /// In vi, this message translates to:
  /// **'Đang gửi tín hiệu SOS'**
  String get sosSemanticsSending;

  /// No description provided for @sosSemanticsActive.
  ///
  /// In vi, this message translates to:
  /// **'Đang có yêu cầu khẩn cấp, nhân viên đang được điều phối'**
  String get sosSemanticsActive;

  /// No description provided for @sosStatusProcessing.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý'**
  String get sosStatusProcessing;

  /// No description provided for @sosStatusResolved.
  ///
  /// In vi, this message translates to:
  /// **'Đã giải quyết'**
  String get sosStatusResolved;

  /// No description provided for @sosStatusTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái yêu cầu'**
  String get sosStatusTitle;

  /// No description provided for @sosSentAt.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lúc: {time}'**
  String sosSentAt(Object time);

  /// No description provided for @sosNoRequest.
  ///
  /// In vi, this message translates to:
  /// **'Không có yêu cầu khẩn cấp'**
  String get sosNoRequest;

  /// No description provided for @sosNoRequestSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn nút SOS phía trên nếu bạn cần hỗ trợ y tế khẩn cấp.'**
  String get sosNoRequestSubtitle;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu tất cả đã đọc'**
  String get notifMarkAllRead;

  /// No description provided for @notifAllRead.
  ///
  /// In vi, this message translates to:
  /// **'Đã đọc tất cả thông báo'**
  String get notifAllRead;

  /// No description provided for @notifSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt thông báo'**
  String get notifSettings;

  /// No description provided for @notifEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Không có thông báo nào'**
  String get notifEmpty;

  /// No description provided for @notifDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa thông báo'**
  String get notifDeleted;

  /// No description provided for @notifAllLoaded.
  ///
  /// In vi, this message translates to:
  /// **'Đã tải hết thông báo'**
  String get notifAllLoaded;

  /// No description provided for @notifLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải thông báo'**
  String get notifLoadError;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất không?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileRemoveAvatarTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ảnh đại diện'**
  String get profileRemoveAvatarTitle;

  /// No description provided for @profileRemoveAvatarConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa ảnh đại diện không?'**
  String get profileRemoveAvatarConfirm;

  /// No description provided for @profileAvatarRemoved.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa ảnh đại diện.'**
  String get profileAvatarRemoved;

  /// No description provided for @profileAvatarRemoveError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể xóa ảnh đại diện.'**
  String get profileAvatarRemoveError;

  /// No description provided for @profileEditTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ'**
  String get profileEditTitle;

  /// No description provided for @profileImageTooLarge.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh vượt quá 10MB. Vui lòng chọn ảnh nhỏ hơn.'**
  String get profileImageTooLarge;

  /// No description provided for @profileUploadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải ảnh lên: {error}'**
  String profileUploadError(Object error);

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật ảnh đại diện thành công.'**
  String get profileAvatarUpdated;

  /// No description provided for @profileAvatarUpdateError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể cập nhật ảnh đại diện.'**
  String get profileAvatarUpdateError;

  /// No description provided for @profileUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật hồ sơ thành công.'**
  String get profileUpdated;

  /// No description provided for @profileUpdateError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể cập nhật hồ sơ.'**
  String get profileUpdateError;

  /// No description provided for @profileLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải hồ sơ'**
  String get profileLoadError;

  /// No description provided for @profileDob.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sinh'**
  String get profileDob;

  /// No description provided for @profileNotUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cập nhật'**
  String get profileNotUpdated;

  /// No description provided for @profileGender.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get profileGender;

  /// No description provided for @profileRateApp.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá ứng dụng'**
  String get profileRateApp;

  /// No description provided for @profilePickGallery.
  ///
  /// In vi, this message translates to:
  /// **'Thư viện'**
  String get profilePickGallery;

  /// No description provided for @profilePickCamera.
  ///
  /// In vi, this message translates to:
  /// **'Máy ảnh'**
  String get profilePickCamera;

  /// No description provided for @profileFullNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ và tên'**
  String get profileFullNameRequired;

  /// No description provided for @profileInvalidDob.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sinh không hợp lệ.'**
  String get profileInvalidDob;

  /// No description provided for @infoTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin'**
  String get infoTitle;

  /// No description provided for @infoHelpSection.
  ///
  /// In vi, this message translates to:
  /// **'Trợ giúp & Giới thiệu'**
  String get infoHelpSection;

  /// No description provided for @infoAbout.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get infoAbout;

  /// No description provided for @infoContact.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get infoContact;

  /// No description provided for @faqTitle.
  ///
  /// In vi, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @faqAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get faqAll;

  /// No description provided for @faqEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có câu hỏi thường gặp.'**
  String get faqEmpty;

  /// No description provided for @faqError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải câu hỏi thường gặp. Vui lòng thử lại.'**
  String get faqError;

  /// No description provided for @aboutVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản {version}'**
  String aboutVersion(Object version);

  /// No description provided for @aboutKeyFeatures.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng chính'**
  String get aboutKeyFeatures;

  /// No description provided for @aboutFeatureMedical.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý y tế'**
  String get aboutFeatureMedical;

  /// No description provided for @aboutFeatureProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ người dùng'**
  String get aboutFeatureProfile;

  /// No description provided for @aboutError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải thông tin. Vui lòng thử lại.'**
  String get aboutError;

  /// No description provided for @contactHospitalName.
  ///
  /// In vi, this message translates to:
  /// **'Bệnh viện Trung tâm'**
  String get contactHospitalName;

  /// No description provided for @contactError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải thông tin liên hệ. Vui lòng thử lại.'**
  String get contactError;

  /// No description provided for @voiceGoStraight.
  ///
  /// In vi, this message translates to:
  /// **'Đi thẳng'**
  String get voiceGoStraight;

  /// No description provided for @voiceTurnLeft.
  ///
  /// In vi, this message translates to:
  /// **'Rẽ trái'**
  String get voiceTurnLeft;

  /// No description provided for @voiceTurnRight.
  ///
  /// In vi, this message translates to:
  /// **'Rẽ phải'**
  String get voiceTurnRight;

  /// No description provided for @voiceArrived.
  ///
  /// In vi, this message translates to:
  /// **'Đã đến đích'**
  String get voiceArrived;

  /// No description provided for @voiceElevatorUp.
  ///
  /// In vi, this message translates to:
  /// **'Đi thang máy lên'**
  String get voiceElevatorUp;

  /// No description provided for @voiceElevatorDown.
  ///
  /// In vi, this message translates to:
  /// **'Đi thang máy xuống'**
  String get voiceElevatorDown;

  /// No description provided for @voiceStairsUp.
  ///
  /// In vi, this message translates to:
  /// **'Đi cầu thang lên'**
  String get voiceStairsUp;

  /// No description provided for @voiceStairsDown.
  ///
  /// In vi, this message translates to:
  /// **'Đi cầu thang xuống'**
  String get voiceStairsDown;

  /// No description provided for @poiPickerDefaultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn vị trí'**
  String get poiPickerDefaultTitle;

  /// No description provided for @poiFieldLabel.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí'**
  String get poiFieldLabel;

  /// No description provided for @poiFieldHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn vị trí...'**
  String get poiFieldHint;

  /// No description provided for @poiLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được danh sách vị trí.'**
  String get poiLoadError;

  /// No description provided for @poiNoMap.
  ///
  /// In vi, this message translates to:
  /// **'Không có bản đồ khả dụng.'**
  String get poiNoMap;

  /// No description provided for @poiEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có vị trí nào.'**
  String get poiEmpty;

  /// No description provided for @poiNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy \"{query}\".'**
  String poiNotFound(Object query);

  /// No description provided for @poiSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo tên hoặc mã...'**
  String get poiSearchHint;

  /// No description provided for @mapSemanticIdle.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ bệnh viện. Chọn điểm đến để bắt đầu.'**
  String get mapSemanticIdle;

  /// No description provided for @mapSemanticNavigating.
  ///
  /// In vi, this message translates to:
  /// **'Đang chỉ đường đến {dest}. {steps} bước, khoảng {distance} mét.'**
  String mapSemanticNavigating(Object dest, int steps, int distance);

  /// No description provided for @rhRateRoute.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá tuyến'**
  String get rhRateRoute;

  /// No description provided for @obTypeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Loại vật cản'**
  String get obTypeLabel;

  /// No description provided for @obstacleTypeObstacle.
  ///
  /// In vi, this message translates to:
  /// **'Vật cản'**
  String get obstacleTypeObstacle;

  /// No description provided for @obstacleTypeWetFloor.
  ///
  /// In vi, this message translates to:
  /// **'Sàn ướt'**
  String get obstacleTypeWetFloor;

  /// No description provided for @obstacleTypeConstruction.
  ///
  /// In vi, this message translates to:
  /// **'Đang thi công'**
  String get obstacleTypeConstruction;

  /// No description provided for @obstacleTypeCrowd.
  ///
  /// In vi, this message translates to:
  /// **'Đông người'**
  String get obstacleTypeCrowd;

  /// No description provided for @obErrorNoLocation.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mã vị trí (grid location).'**
  String get obErrorNoLocation;

  /// No description provided for @obErrorNotInteger.
  ///
  /// In vi, this message translates to:
  /// **'Mã vị trí phải là số nguyên.'**
  String get obErrorNotInteger;

  /// No description provided for @obSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã báo cáo vật cản thành công!'**
  String get obSuccess;

  /// No description provided for @obLocationLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã vị trí *'**
  String get obLocationLabel;

  /// No description provided for @obLocationHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số grid location (vd: 342)'**
  String get obLocationHint;

  /// No description provided for @obLocationHelper.
  ///
  /// In vi, this message translates to:
  /// **'Tìm mã vị trí trên bản đồ hoặc hỏi nhân viên'**
  String get obLocationHelper;

  /// No description provided for @obNoteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả thêm'**
  String get obNoteLabel;

  /// No description provided for @obNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả tình trạng vật cản...'**
  String get obNoteHint;

  /// No description provided for @obSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi báo cáo!'**
  String get obSuccessTitle;

  /// No description provided for @obSuccessSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn đã thông báo vật cản. Đội ngũ sẽ xử lý sớm nhất.'**
  String get obSuccessSubtitle;

  /// No description provided for @rrTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá tuyến đường'**
  String get rrTitle;

  /// No description provided for @rrThanks.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn đã đánh giá tuyến đường!'**
  String get rrThanks;

  /// No description provided for @rrRouteId.
  ///
  /// In vi, this message translates to:
  /// **'Mã tuyến: {id}'**
  String rrRouteId(Object id);

  /// No description provided for @rrQuality.
  ///
  /// In vi, this message translates to:
  /// **'Chất lượng tuyến đường'**
  String get rrQuality;

  /// No description provided for @rrCommentLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nhận xét (tùy chọn)'**
  String get rrCommentLabel;

  /// No description provided for @rrCommentHint.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ cảm nhận về tuyến đường...'**
  String get rrCommentHint;

  /// No description provided for @rrAccurateQuestion.
  ///
  /// In vi, this message translates to:
  /// **'Tuyến đường có chính xác không?'**
  String get rrAccurateQuestion;

  /// No description provided for @rrSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi đánh giá!'**
  String get rrSuccessTitle;

  /// No description provided for @rrSuccessSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn đã giúp cải thiện chất lượng hướng dẫn.'**
  String get rrSuccessSubtitle;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get navHome;

  /// No description provided for @navUtilities.
  ///
  /// In vi, this message translates to:
  /// **'Tiện ích'**
  String get navUtilities;

  /// No description provided for @navMap.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ'**
  String get navMap;

  /// No description provided for @navChat.
  ///
  /// In vi, this message translates to:
  /// **'Trò chuyện'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get navProfile;

  /// No description provided for @homeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get homeTitle;

  /// No description provided for @homeLoggedOut.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng xuất'**
  String get homeLoggedOut;

  /// No description provided for @homeOpenNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Mở thông báo'**
  String get homeOpenNotifications;

  /// No description provided for @homeNotificationsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get homeNotificationsTitle;

  /// No description provided for @homeOpenMenu.
  ///
  /// In vi, this message translates to:
  /// **'Mở menu trang chủ'**
  String get homeOpenMenu;

  /// No description provided for @homeMenu.
  ///
  /// In vi, this message translates to:
  /// **'Menu'**
  String get homeMenu;

  /// No description provided for @homeReloadHome.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại trang chủ'**
  String get homeReloadHome;

  /// No description provided for @homeReload.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại'**
  String get homeReload;

  /// No description provided for @homeOpenSettings.
  ///
  /// In vi, this message translates to:
  /// **'Mở cài đặt'**
  String get homeOpenSettings;

  /// No description provided for @homeLogoutAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất khỏi tài khoản'**
  String get homeLogoutAccount;

  /// No description provided for @homeQuickAccess.
  ///
  /// In vi, this message translates to:
  /// **'Truy cập nhanh'**
  String get homeQuickAccess;

  /// No description provided for @homeActionQueue.
  ///
  /// In vi, this message translates to:
  /// **'Hàng đợi'**
  String get homeActionQueue;

  /// No description provided for @homeActionFindWheelchair.
  ///
  /// In vi, this message translates to:
  /// **'Tìm xe lăn'**
  String get homeActionFindWheelchair;

  /// No description provided for @homeActionSupport.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ'**
  String get homeActionSupport;

  /// No description provided for @homeActionPrescription.
  ///
  /// In vi, this message translates to:
  /// **'Đơn thuốc'**
  String get homeActionPrescription;

  /// No description provided for @homeActionReportObstacle.
  ///
  /// In vi, this message translates to:
  /// **'Báo vật cản'**
  String get homeActionReportObstacle;

  /// No description provided for @homeActionDeviceStations.
  ///
  /// In vi, this message translates to:
  /// **'Trạm thiết bị'**
  String get homeActionDeviceStations;

  /// No description provided for @homeOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get homeOverview;

  /// No description provided for @homeCurrentTasks.
  ///
  /// In vi, this message translates to:
  /// **'Nhiệm vụ hiện tại'**
  String get homeCurrentTasks;

  /// No description provided for @homeTasksActive.
  ///
  /// In vi, this message translates to:
  /// **'{count} Hoạt động'**
  String homeTasksActive(int count);

  /// No description provided for @homeLoadingWeather.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải thời tiết...'**
  String get homeLoadingWeather;

  /// No description provided for @homeWeatherCurrent.
  ///
  /// In vi, this message translates to:
  /// **'Thời tiết hiện tại'**
  String get homeWeatherCurrent;

  /// No description provided for @homeWeatherDetail.
  ///
  /// In vi, this message translates to:
  /// **'{description} • Độ ẩm {humidity}% • Gió {wind} km/h'**
  String homeWeatherDetail(String description, int humidity, int wind);

  /// No description provided for @homeNotificationsLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải thông báo...'**
  String get homeNotificationsLoading;

  /// No description provided for @homeNotificationsUnread.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có {count} thông báo mới'**
  String homeNotificationsUnread(int count);

  /// No description provided for @homeNotificationsNone.
  ///
  /// In vi, this message translates to:
  /// **'Không có thông báo mới'**
  String get homeNotificationsNone;

  /// No description provided for @homeNotificationsTapToView.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn để xem danh sách thông báo'**
  String get homeNotificationsTapToView;

  /// No description provided for @homeNoBooking.
  ///
  /// In vi, this message translates to:
  /// **'Chưa mượn xe lăn nào'**
  String get homeNoBooking;

  /// No description provided for @homeNoBookingSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn để tìm hoặc khôi phục lượt mượn'**
  String get homeNoBookingSubtitle;

  /// No description provided for @homeActiveBooking.
  ///
  /// In vi, this message translates to:
  /// **'Xe lăn đang mượn · {assetId}'**
  String homeActiveBooking(Object assetId);

  /// No description provided for @homeTrack.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi'**
  String get homeTrack;

  /// No description provided for @homeReturnDevice.
  ///
  /// In vi, this message translates to:
  /// **'Trả thiết bị'**
  String get homeReturnDevice;

  /// No description provided for @logoutSheetMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn sẽ phải đăng nhập lại để tiếp tục.'**
  String get logoutSheetMessage;

  /// No description provided for @mapPreviewOpen.
  ///
  /// In vi, this message translates to:
  /// **'Mở bản đồ bệnh viện'**
  String get mapPreviewOpen;

  /// No description provided for @mapPreviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ bệnh viện'**
  String get mapPreviewTitle;

  /// No description provided for @mapPreviewSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tìm đường đến phòng ban'**
  String get mapPreviewSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// No description provided for @settingsLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải cài đặt'**
  String get settingsLoadError;

  /// No description provided for @settingsSaveError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu cài đặt'**
  String get settingsSaveError;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get settingsSectionAccount;

  /// No description provided for @settingsChangePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get settingsChangePassword;

  /// No description provided for @settingsLogout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get settingsLogoutConfirmTitle;

  /// No description provided for @settingsLogoutConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn đăng xuất khỏi ứng dụng?'**
  String get settingsLogoutConfirmMessage;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tài khoản'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa vĩnh viễn tài khoản và dữ liệu'**
  String get settingsDeleteAccountSubtitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsThemeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get settingsThemeDark;

  /// No description provided for @settingsSectionNotification.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get settingsSectionNotification;

  /// No description provided for @settingsEnableNotification.
  ///
  /// In vi, this message translates to:
  /// **'Bật thông báo'**
  String get settingsEnableNotification;

  /// No description provided for @settingsEnableNotificationSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhận thông báo từ hệ thống'**
  String get settingsEnableNotificationSubtitle;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsDisplayLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ hiển thị'**
  String get settingsDisplayLanguage;

  /// No description provided for @settingsLanguageVietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get settingsLanguageVietnamese;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsSectionOffline.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu ngoại tuyến'**
  String get settingsSectionOffline;

  /// No description provided for @settingsClearMapCache.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bộ nhớ đệm bản đồ'**
  String get settingsClearMapCache;

  /// No description provided for @settingsClearMapCacheSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Gỡ dữ liệu bản đồ và lộ trình đã tải về thiết bị'**
  String get settingsClearMapCacheSubtitle;

  /// No description provided for @settingsClearMapCacheConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Thao tác này gỡ dữ liệu bản đồ và lộ trình đã tải về thiết bị. Ứng dụng sẽ tải lại khi cần.'**
  String get settingsClearMapCacheConfirm;

  /// No description provided for @settingsClearMapCacheSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa bộ nhớ đệm bản đồ'**
  String get settingsClearMapCacheSuccess;

  /// No description provided for @settingsSectionAppInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin ứng dụng'**
  String get settingsSectionAppInfo;

  /// No description provided for @settingsHelp.
  ///
  /// In vi, this message translates to:
  /// **'Trợ giúp'**
  String get settingsHelp;

  /// No description provided for @settingsAbout.
  ///
  /// In vi, this message translates to:
  /// **'Về ứng dụng'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get settingsVersion;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng hỗ trợ bệnh nhân tra cứu thông tin, điều hướng nội viện và quản lý lịch khám bệnh.'**
  String get settingsAboutDescription;

  /// No description provided for @settingsDeletePasswordIncorrect.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không chính xác. Vui lòng thử lại.'**
  String get settingsDeletePasswordIncorrect;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
