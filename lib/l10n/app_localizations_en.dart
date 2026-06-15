// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonError => 'Something went wrong, please try again';

  @override
  String get commonOk => 'OK';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonProcessing => 'Processing...';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonDone => 'Done';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonErrorShort => 'An error occurred';

  @override
  String get errBadRequest => 'Invalid request.';

  @override
  String get errMissingParameter => 'Missing required information.';

  @override
  String get errInvalidParameterType => 'The submitted data is invalid.';

  @override
  String get errInvalidParameterValue => 'Invalid value.';

  @override
  String get errMethodNotAllowed => 'This action is not supported.';

  @override
  String get errAccessDenied =>
      'You don\'t have permission to perform this action.';

  @override
  String get errLimitExceeded =>
      'You are already borrowing another device; please return it before borrowing more.';

  @override
  String get errOtpIncorrect => 'Incorrect OTP code.';

  @override
  String get errOtpExpired => 'The OTP code has expired.';

  @override
  String get errUserExists => 'Account already exists.';

  @override
  String get errUserNotFound => 'Account not found.';

  @override
  String get errPasswordIncorrect => 'Incorrect password.';

  @override
  String get errMapNotFound => 'No matching information found in the system.';

  @override
  String get errInvalidStart => 'Invalid starting location.';

  @override
  String get errInvalidDestination => 'Invalid destination.';

  @override
  String get errPathNotFound => 'No suitable route found.';

  @override
  String get errInvalidLocationData => 'Invalid location data.';

  @override
  String get errDensityUnavailable =>
      'Density data is temporarily unavailable.';

  @override
  String get errTaskNotFound => 'Task not found.';

  @override
  String get errAssetNotFound => 'Device not found.';

  @override
  String get errAssetNotAvailable => 'The device is currently unavailable.';

  @override
  String get errServer =>
      'The server is experiencing issues, please try again later.';

  @override
  String get errHisUnavailable =>
      'The hospital system is temporarily unresponsive, please try again later.';

  @override
  String get errAccountElsewhere =>
      'Your account is logged in on another device. Please sign in again.';

  @override
  String get errSessionEnded => 'Your session has ended. Please sign in again.';

  @override
  String get errTimeout =>
      'Connection to the server timed out, please try again.';

  @override
  String get errCancelled => 'The request was cancelled.';

  @override
  String get errNoNetwork => 'No network connection.';

  @override
  String get errDataNotFound => 'Data not found.';

  @override
  String get daConfirmBody =>
      'Are you sure you want to delete your account?\nThis action cannot be undone.\nAll your data will be permanently deleted.';

  @override
  String get daPasswordTitle => 'Confirm account deletion';

  @override
  String get daPasswordHint => 'Enter your password';

  @override
  String get daSuccessTitle => 'Account deleted successfully';

  @override
  String get daSuccessBody => 'Your account has been deleted successfully.';

  @override
  String get daErrorTitle => 'Error';

  @override
  String get vgUpdateTitle => 'A new update is available';

  @override
  String vgNewVersion(Object version) {
    return 'New version: $version';
  }

  @override
  String get vgLater => 'Later';

  @override
  String get vgUpdate => 'Update';

  @override
  String get assetInUseOrNoPermission =>
      'This device is in use by another user, or you don\'t have permission to track it.';

  @override
  String get assetGenericError => 'Something went wrong, please try again.';

  @override
  String get chatImagePlaceholder => '[Image]';

  @override
  String get chatVoicePlaceholder => '[Voice message]';

  @override
  String get chatSupportDefault => 'Patient support';

  @override
  String get chatRoomsTitle => 'Messages';

  @override
  String get chatNoConversations => 'No conversations yet';

  @override
  String get chatLoadError => 'Could not load messages';

  @override
  String get chatRoomDefault => 'Chat room';

  @override
  String get chatNoMessages => 'No messages yet';

  @override
  String get chatYesterday => 'Yesterday';

  @override
  String get chatNoMessagesYet => 'No messages yet';

  @override
  String get chatLoadOlder => 'Load older messages';

  @override
  String get chatSendImage => 'Send image';

  @override
  String get chatInputHint => 'Type a message...';

  @override
  String get chatNewMessages => 'New messages';

  @override
  String get chatMsgRead => '✓✓ Read';

  @override
  String get chatMsgSent => '✓ Sent';

  @override
  String get chatImageLoadError => 'Could not load image';

  @override
  String get chatVoiceMessage => 'Voice message';

  @override
  String get senderPatient => 'Patient';

  @override
  String get senderAdmin => 'Administrator';

  @override
  String get senderCoordinator => 'Coordinator';

  @override
  String get senderStaff => 'Support staff';

  @override
  String get chatEmptyContent => 'Message content cannot be empty';

  @override
  String get sosSentMessage => 'SOS signal sent. Staff are on the way!';

  @override
  String get authPhone => 'Phone number';

  @override
  String get authPassword => 'Password';

  @override
  String get authHide => 'Hide';

  @override
  String get authShow => 'Show';

  @override
  String get welcomeLogoutSuccess => 'Logged out successfully.';

  @override
  String get welcomeTitle => 'Welcome back!';

  @override
  String get welcomeSubtitle =>
      'Your session has been saved securely. Continue using the app or log out when you\'re done.';

  @override
  String get welcomeContinue => 'Continue to the app';

  @override
  String get loginErrorEmptyFields =>
      'Please enter your phone number and password.';

  @override
  String get loginSuccess => 'Signed in successfully.';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue caring for your health';

  @override
  String get loginCredentials => 'Sign-in details';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginRegisterNow => 'Register now';

  @override
  String get authLogin => 'Sign in';

  @override
  String get authRememberedPassword => 'Remembered your password?';

  @override
  String get authPasswordNew => 'New password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get forgotErrorEmptyPhone => 'Please enter your phone number.';

  @override
  String get forgotOtpSent => 'Verification code sent.';

  @override
  String get forgotSubtitle =>
      'Enter your phone number to receive a verification code';

  @override
  String get forgotVerifyAccount => 'Verify account';

  @override
  String get forgotSendOtp => 'Send verification code';

  @override
  String get resetErrorEmptyFields => 'Please fill in all fields.';

  @override
  String get resetErrorShortPassword =>
      'Password must be at least 6 characters.';

  @override
  String get resetErrorMismatch => 'Passwords do not match.';

  @override
  String get resetSuccess => 'Password reset successfully.';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get resetSubtitle => 'Create a new password for your account';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get registerErrorSelectDob => 'Please select your date of birth.';

  @override
  String get registerErrorMinAge => 'You must be at least 13 to register.';

  @override
  String get registerSelectDob => 'Select date of birth';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Join us for the best support';

  @override
  String get registerPersonalInfo => 'Personal information';

  @override
  String get registerFullName => 'Full name';

  @override
  String get registerFullNameError => 'Enter your full name';

  @override
  String get registerPhoneInvalid => 'Invalid phone number';

  @override
  String get registerSecurityInfo => 'Security information';

  @override
  String get registerPasswordMin => 'Password must be at least 6 characters';

  @override
  String get registerConfirmPasswordError => 'Please confirm your password';

  @override
  String get registerPasswordMismatch => 'Passwords do not match';

  @override
  String get registerButton => 'Register';

  @override
  String get registerHaveAccount => 'Already have an account?';

  @override
  String get registerLoginNow => 'Sign in now';

  @override
  String get otpResent => 'Code resent';

  @override
  String get otpErrorIncomplete => 'Please enter the full OTP code.';

  @override
  String get otpContinueReset => 'Continue resetting your password.';

  @override
  String get otpVerifySuccess => 'Verified successfully!';

  @override
  String get otpTitle => 'OTP verification';

  @override
  String otpSentTo(String phone) {
    return 'An OTP code has been sent to $phone';
  }

  @override
  String get otpFilled => 'OTP code filled in';

  @override
  String get otpMockLabel => 'OTP code (mock)';

  @override
  String get otpResendButton => 'Resend code';

  @override
  String get otpResendError => 'Could not resend the code. Please try again.';

  @override
  String get changePwdErrorShortNew =>
      'New password must be at least 6 characters.';

  @override
  String get changePwdErrorMismatch => 'New passwords do not match.';

  @override
  String get changePwdErrorSameAsOld =>
      'New password must differ from the old one.';

  @override
  String get changePwdSuccess => 'Password changed successfully.';

  @override
  String get changePwdSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get changePwdTitle => 'Change password';

  @override
  String get changePwdSubtitle => 'Update your password to secure your account';

  @override
  String get changePwdVerifySection => 'Verify password';

  @override
  String get changePwdCurrentHint => 'Current password';

  @override
  String get changePwdConfirmHint => 'Confirm new password';

  @override
  String get deviceRefresh => 'Refresh';

  @override
  String get mwTitle => 'My wheelchair';

  @override
  String get mwReleaseSuccess => 'Device returned successfully!';

  @override
  String get mwNoBookingFound => 'No borrow found for you.';

  @override
  String mwRecovered(Object id) {
    return 'Booking recovered: $id';
  }

  @override
  String get mwPickTitle => 'Select your wheelchair';

  @override
  String get mwPickContent =>
      'Several wheelchairs are in use. Choose the one that\'s yours:';

  @override
  String mwAdopted(Object id) {
    return 'Booking selected: $id';
  }

  @override
  String mwBorrowing(Object id) {
    return 'In use · $id';
  }

  @override
  String mwStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String mwBattery(Object level) {
    return 'Battery $level';
  }

  @override
  String get mwTrackLocation => 'Track location';

  @override
  String get mwReportBroken => 'Report damage';

  @override
  String get mwChecking => 'Checking your bookings...';

  @override
  String get mwEmptyTitle => 'You haven\'t borrowed a wheelchair';

  @override
  String get mwEmptySubtitle =>
      'If you borrowed it on another device, recover the booking.';

  @override
  String get mwRecoverBooking => 'Recover booking';

  @override
  String get wsPickLocationTitle => 'Select your location';

  @override
  String get wsYourLocation => 'Your location';

  @override
  String get wsYourLocationHint =>
      'Select a location to find nearby wheelchairs...';

  @override
  String get wsEnterLocationPrompt =>
      'Enter a location code to find nearby wheelchairs';

  @override
  String get wsNoWheelchairs => 'No free wheelchairs near this location.';

  @override
  String get wsAvailable => 'Available';

  @override
  String get wsUnavailable => 'Unavailable';

  @override
  String wsBatteryPercent(Object level) {
    return 'Battery: $level%';
  }

  @override
  String wsDistance(Object distance) {
    return '${distance}m away';
  }

  @override
  String get wsBorrow => 'Borrow';

  @override
  String trackTitle(Object id) {
    return 'Location $id';
  }

  @override
  String get trackInfoTitle => 'Tracking information';

  @override
  String get trackAssetCode => 'Device code';

  @override
  String get trackStatus => 'Status';

  @override
  String get trackMoving => 'Movement';

  @override
  String get trackCurrentPos => 'Current location';

  @override
  String get trackCondition => 'Condition';

  @override
  String get trackBattery => 'Battery';

  @override
  String abTitle(Object id) {
    return 'Device $id';
  }

  @override
  String abBookSuccess(Object id) {
    return 'Borrowed device $id successfully!';
  }

  @override
  String get abDeviceInfo => 'Device information';

  @override
  String get abBookDevice => 'Borrow device';

  @override
  String get abMaintenanceTitle => 'Device under maintenance';

  @override
  String get abMaintenanceBody =>
      'This device is temporarily unavailable to borrow. Please choose another one.';

  @override
  String get abInUseTitle => 'Device in use';

  @override
  String get abInUseBody =>
      'This device is currently borrowed by another user. Please choose another one.';

  @override
  String get baTitle => 'Report damaged device';

  @override
  String get baCardTitle => 'Report a damaged device';

  @override
  String get baErrorNoAssetId => 'Please enter the device code.';

  @override
  String get baErrorNoReason => 'Please describe the damage.';

  @override
  String get baSuccess => 'Damage reported successfully!';

  @override
  String get baAssetCodeLabel => 'Device code *';

  @override
  String get baReasonLabel => 'Damage description *';

  @override
  String get baReasonHint => 'Describe the issue in detail...';

  @override
  String get baSubmit => 'Submit report';

  @override
  String get baSuccessTitle => 'Reported successfully!';

  @override
  String get baSuccessSubtitle =>
      'Our technical team will resolve the issue as soon as possible.';

  @override
  String get stationsEmpty => 'No device stations available.';

  @override
  String stationAvailable(int count) {
    return '$count available';
  }

  @override
  String stationCapacity(int count) {
    return 'Capacity: $count';
  }

  @override
  String get releaseAtStation => 'Return device at a station';

  @override
  String stationSlotFull(int available, int capacity) {
    return '$available/$capacity (full)';
  }

  @override
  String stationSlotFree(int available, int capacity) {
    return '$available/$capacity free';
  }

  @override
  String get feedbackErrorNoRating => 'Please select a star rating.';

  @override
  String get feedbackThanks => 'Thank you for your feedback!';

  @override
  String feedbackSummary(int count, String rating) {
    return '$count ratings so far • $rating★';
  }

  @override
  String get feedbackHowSatisfied => 'How satisfied are you?';

  @override
  String feedbackStars(int count) {
    return '$count stars';
  }

  @override
  String get feedbackCommentLabel => 'Comment';

  @override
  String get feedbackCommentHint => 'Enter your thoughts';

  @override
  String get feedbackImageTooltip => 'Image attachment is coming soon';

  @override
  String get feedbackPickImage => 'Pick image (Coming soon)';

  @override
  String get feedbackSubmit => 'Submit rating';

  @override
  String get feedbackLoading => 'Loading ratings...';

  @override
  String get queuePickRoom => 'Select clinic room';

  @override
  String queueOpenHours(Object hours) {
    return 'Opening hours: $hours';
  }

  @override
  String get queueUnknown => 'Unknown';

  @override
  String get queueOpen => 'Open';

  @override
  String get queueClosed => 'Closed';

  @override
  String get queueRoomLabel => 'Clinic room';

  @override
  String get queueRoomHint => 'Select a clinic room...';

  @override
  String get queueSelectPrompt =>
      'Select a clinic room to see queue status and opening hours.';

  @override
  String get queueNoRoomData => 'No room data';

  @override
  String get queueNoQueueData => 'No queue data';

  @override
  String queuePoi(Object id) {
    return 'POI #$id';
  }

  @override
  String get queueCurrentNumber => 'Current number';

  @override
  String get queueWaiting => 'Waiting';

  @override
  String get queueAvgWait => 'Avg wait (min)';

  @override
  String get presEmpty => 'No prescription yet';

  @override
  String get presPharmacy => 'Pharmacy';

  @override
  String presStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String presIssuedAt(Object date) {
    return 'Issued: $date';
  }

  @override
  String get presMedList => 'Medication list';

  @override
  String get mlTitle => 'Medical orders';

  @override
  String get mlEmptyTasks => 'No orders yet';

  @override
  String get mlHistoryToday => 'Today\'s history';

  @override
  String get mlNoHistory => 'No history yet';

  @override
  String get mlQueueSubtitle => 'View queue number';

  @override
  String get mlPrescriptionSubtitle => 'Prescription history';

  @override
  String get mlStationsTitle => 'Wheelchair stations';

  @override
  String get mlStationsSubtitle => 'Wheelchair stations';

  @override
  String get mlFindNearbyTitle => 'Find nearby wheelchairs';

  @override
  String get mlFindNearbySubtitle => 'Available wheelchairs';

  @override
  String get mlStaffTitle => 'Staff assistance';

  @override
  String get mlObstacleTitle => 'Report obstacle';

  @override
  String get mlObstacleSubtitle => 'Report a blocked path';

  @override
  String get mlInfoTitle => 'Info & FAQ';

  @override
  String get mlInfoSubtitle => 'Guides, questions';

  @override
  String get mlSyncSuccess => 'HIS synced';

  @override
  String get mlSyncTooltip => 'Sync HIS';

  @override
  String get tdDetailTitle => 'Order details';

  @override
  String get tdActions => 'Actions';

  @override
  String get tdNoResultData => 'No result data';

  @override
  String get tdResultTitle => 'Result';

  @override
  String tdResultBody(Object id, Object status, Object hasResult) {
    return 'Treatment: $id\nStatus: $status\nHas result: $hasResult';
  }

  @override
  String get tdResultHas => 'Yes';

  @override
  String get tdResultNotYet => 'Not yet';

  @override
  String get tdCancelTitle => 'Cancel order';

  @override
  String get tdCancelConfirm => 'Are you sure you want to cancel?';

  @override
  String get tdCancelled => 'Order cancelled';

  @override
  String get tdCheckin => 'Check-in';

  @override
  String get tdCheckinSuccess => 'Checked in successfully';

  @override
  String get tdCheckout => 'Check-out';

  @override
  String get tdCheckoutSuccess => 'Checked out successfully';

  @override
  String tcRoom(Object name) {
    return 'Room: $name';
  }

  @override
  String tcWard(Object name) {
    return 'Ward: $name';
  }

  @override
  String tcPriority(Object priority) {
    return 'Priority: $priority';
  }

  @override
  String tcSequence(Object number) {
    return 'No.: $number';
  }

  @override
  String get tcHasResult => 'Has result';

  @override
  String get tcNoResult => 'No result yet';

  @override
  String tcCheckinCompleted(Object checkin, Object completed) {
    return 'Check-in: $checkin\nCompleted: $completed';
  }

  @override
  String presDosage(Object dosage) {
    return 'Dosage: $dosage';
  }

  @override
  String presQuantity(Object quantity) {
    return 'Quantity: $quantity';
  }

  @override
  String presInstructions(Object instructions) {
    return 'Instructions: $instructions';
  }

  @override
  String get staffTitle => 'Request assistance';

  @override
  String get staffTypeMove => 'Mobility assistance';

  @override
  String get staffTypeWheelchair => 'Wheelchair assistance';

  @override
  String get staffTypeMedical => 'Medical assistance';

  @override
  String get staffTypeOther => 'Other assistance';

  @override
  String get staffPickLocationTitle => 'Select current location';

  @override
  String get staffErrorSelectLocation => 'Please select your location.';

  @override
  String get staffTypeLabel => 'Assistance type';

  @override
  String get staffCurrentLocationLabel => 'Current location *';

  @override
  String get staffCurrentLocationHint => 'Select your location...';

  @override
  String get staffAssetCodeLabel => 'Device code (if any)';

  @override
  String get staffAssetCodeHint => 'e.g. WL-001';

  @override
  String get staffNoteLabel => 'Additional note';

  @override
  String get staffNoteHint => 'Describe the situation you need help with...';

  @override
  String get staffSubmit => 'Submit request';

  @override
  String get staffSuccessTitle => 'Your request has been sent!';

  @override
  String get staffSuccessSubtitle =>
      'Staff will come to assist you as soon as possible.';

  @override
  String get sosTitle => 'SOS — Emergency';

  @override
  String get sosNote => 'Note';

  @override
  String get sosNoteContent =>
      '• Use only in a genuine emergency.\n• Medical staff will arrive as soon as possible.\n• If you need help right now, call the reception desk.';

  @override
  String get sosHelperActive => 'Emergency request active';

  @override
  String get sosHelperSending => 'Sending signal...';

  @override
  String get sosHelperIdle => 'Press and hold to send the signal';

  @override
  String get sosSemanticsSend => 'Send SOS signal';

  @override
  String get sosSemanticsHint => 'Press and hold for 1.2 seconds to confirm';

  @override
  String get sosSemanticsSending => 'Sending SOS signal';

  @override
  String get sosSemanticsActive =>
      'Emergency request active, staff are being dispatched';

  @override
  String get sosStatusProcessing => 'In progress';

  @override
  String get sosStatusResolved => 'Resolved';

  @override
  String get sosStatusTitle => 'Request status';

  @override
  String sosSentAt(Object time) {
    return 'Sent at: $time';
  }

  @override
  String get sosNoRequest => 'No emergency request';

  @override
  String get sosNoRequestSubtitle =>
      'Press the SOS button above if you need urgent medical help.';

  @override
  String get notifMarkAllRead => 'Mark all as read';

  @override
  String get notifAllRead => 'All notifications marked as read';

  @override
  String get notifSettings => 'Notification settings';

  @override
  String get notifEmpty => 'No notifications';

  @override
  String get notifDeleted => 'Notification deleted';

  @override
  String get notifAllLoaded => 'All notifications loaded';

  @override
  String get notifLoadError => 'Could not load notifications';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to log out?';

  @override
  String get profileRemoveAvatarTitle => 'Remove profile photo';

  @override
  String get profileRemoveAvatarConfirm =>
      'Are you sure you want to remove your profile photo?';

  @override
  String get profileAvatarRemoved => 'Profile photo removed.';

  @override
  String get profileAvatarRemoveError => 'Could not remove the profile photo.';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileImageTooLarge =>
      'Image exceeds 10MB. Please choose a smaller one.';

  @override
  String profileUploadError(Object error) {
    return 'Could not upload image: $error';
  }

  @override
  String get profileAvatarUpdated => 'Profile photo updated successfully.';

  @override
  String get profileAvatarUpdateError => 'Could not update the profile photo.';

  @override
  String get profileUpdated => 'Profile updated successfully.';

  @override
  String get profileUpdateError => 'Could not update the profile.';

  @override
  String get profileLoadError => 'Could not load profile';

  @override
  String get profileDob => 'Date of birth';

  @override
  String get profileNotUpdated => 'Not updated';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileRateApp => 'Rate the app';

  @override
  String get profilePickGallery => 'Gallery';

  @override
  String get profilePickCamera => 'Camera';

  @override
  String get profileFullNameRequired => 'Please enter your full name';

  @override
  String get profileInvalidDob => 'Invalid date of birth.';

  @override
  String get infoTitle => 'Information';

  @override
  String get infoHelpSection => 'Help & About';

  @override
  String get infoAbout => 'About';

  @override
  String get infoContact => 'Contact';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqAll => 'All';

  @override
  String get faqEmpty => 'No frequently asked questions yet.';

  @override
  String get faqError => 'Could not load FAQs. Please try again.';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get aboutKeyFeatures => 'Key features';

  @override
  String get aboutFeatureMedical => 'Medical management';

  @override
  String get aboutFeatureProfile => 'User profile';

  @override
  String get aboutError => 'Could not load information. Please try again.';

  @override
  String get contactHospitalName => 'Central Hospital';

  @override
  String get contactError =>
      'Could not load contact information. Please try again.';

  @override
  String get voiceGoStraight => 'Go straight';

  @override
  String get voiceTurnLeft => 'Turn left';

  @override
  String get voiceTurnRight => 'Turn right';

  @override
  String get voiceArrived => 'You have arrived';

  @override
  String get voiceElevatorUp => 'Take the elevator up';

  @override
  String get voiceElevatorDown => 'Take the elevator down';

  @override
  String get voiceStairsUp => 'Take the stairs up';

  @override
  String get voiceStairsDown => 'Take the stairs down';

  @override
  String get poiPickerDefaultTitle => 'Select location';

  @override
  String get poiFieldLabel => 'Location';

  @override
  String get poiFieldHint => 'Select location...';

  @override
  String get poiLoadError => 'Could not load the location list.';

  @override
  String get poiNoMap => 'No map available.';

  @override
  String get poiEmpty => 'No locations yet.';

  @override
  String poiNotFound(Object query) {
    return 'No results for \"$query\".';
  }

  @override
  String get poiSearchHint => 'Search by name or code...';

  @override
  String get mapSemanticIdle => 'Hospital map. Select a destination to start.';

  @override
  String mapSemanticNavigating(Object dest, int steps, int distance) {
    return 'Navigating to $dest. $steps steps, about $distance meters.';
  }

  @override
  String get rhRateRoute => 'Rate route';

  @override
  String get obTypeLabel => 'Obstacle type';

  @override
  String get obstacleTypeObstacle => 'Obstacle';

  @override
  String get obstacleTypeWetFloor => 'Wet floor';

  @override
  String get obstacleTypeConstruction => 'Under construction';

  @override
  String get obstacleTypeCrowd => 'Crowded';

  @override
  String get obErrorNoLocation => 'Please enter the grid location code.';

  @override
  String get obErrorNotInteger => 'The location code must be an integer.';

  @override
  String get obSuccess => 'Obstacle reported successfully!';

  @override
  String get obLocationLabel => 'Location code *';

  @override
  String get obLocationHint => 'Enter the grid location number (e.g. 342)';

  @override
  String get obLocationHelper =>
      'Find the location code on the map or ask staff';

  @override
  String get obNoteLabel => 'Additional description';

  @override
  String get obNoteHint => 'Describe the obstacle...';

  @override
  String get obSuccessTitle => 'Report sent!';

  @override
  String get obSuccessSubtitle =>
      'Thank you for reporting the obstacle. Our team will handle it soon.';

  @override
  String get rrTitle => 'Rate route';

  @override
  String get rrThanks => 'Thank you for rating this route!';

  @override
  String rrRouteId(Object id) {
    return 'Route ID: $id';
  }

  @override
  String get rrQuality => 'Route quality';

  @override
  String get rrCommentLabel => 'Comment (optional)';

  @override
  String get rrCommentHint => 'Share your thoughts about the route...';

  @override
  String get rrAccurateQuestion => 'Was the route accurate?';

  @override
  String get rrSuccessTitle => 'Rating sent!';

  @override
  String get rrSuccessSubtitle =>
      'Thank you for helping us improve guidance quality.';

  @override
  String get navHome => 'Home';

  @override
  String get navUtilities => 'Utilities';

  @override
  String get navMap => 'Map';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeLoggedOut => 'Logged out';

  @override
  String get homeOpenNotifications => 'Open notifications';

  @override
  String get homeNotificationsTitle => 'Notifications';

  @override
  String get homeOpenMenu => 'Open home menu';

  @override
  String get homeMenu => 'Menu';

  @override
  String get homeReloadHome => 'Reload home';

  @override
  String get homeReload => 'Reload';

  @override
  String get homeOpenSettings => 'Open settings';

  @override
  String get homeLogoutAccount => 'Log out of your account';

  @override
  String get homeQuickAccess => 'Quick access';

  @override
  String get homeActionQueue => 'Queue';

  @override
  String get homeActionFindWheelchair => 'Find wheelchair';

  @override
  String get homeActionSupport => 'Support';

  @override
  String get homeActionPrescription => 'Prescription';

  @override
  String get homeActionReportObstacle => 'Report obstacle';

  @override
  String get homeActionDeviceStations => 'Device stations';

  @override
  String get homeOverview => 'Overview';

  @override
  String get homeCurrentTasks => 'Current tasks';

  @override
  String homeTasksActive(int count) {
    return '$count active';
  }

  @override
  String get homeLoadingWeather => 'Loading weather...';

  @override
  String get homeWeatherCurrent => 'Current weather';

  @override
  String homeWeatherDetail(String description, int humidity, int wind) {
    return '$description • Humidity $humidity% • Wind $wind km/h';
  }

  @override
  String get homeNotificationsLoading => 'Loading notifications...';

  @override
  String homeNotificationsUnread(int count) {
    return 'You have $count new notifications';
  }

  @override
  String get homeNotificationsNone => 'No new notifications';

  @override
  String get homeNotificationsTapToView => 'Tap to view the notification list';

  @override
  String get homeNoBooking => 'No wheelchair borrowed yet';

  @override
  String get homeNoBookingSubtitle => 'Tap to find or restore a borrow';

  @override
  String homeActiveBooking(Object assetId) {
    return 'Wheelchair in use · $assetId';
  }

  @override
  String get homeTrack => 'Track';

  @override
  String get homeReturnDevice => 'Return device';

  @override
  String get logoutSheetMessage =>
      'You will need to sign in again to continue.';

  @override
  String get mapPreviewOpen => 'Open hospital map';

  @override
  String get mapPreviewTitle => 'Hospital map';

  @override
  String get mapPreviewSubtitle => 'Find your way to departments';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLoadError => 'Unable to load settings';

  @override
  String get settingsSaveError => 'Unable to save settings';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutConfirmTitle => 'Log out';

  @override
  String get settingsLogoutConfirmMessage =>
      'Are you sure you want to log out of the app?';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Permanently delete your account and data';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSectionNotification => 'Notifications';

  @override
  String get settingsEnableNotification => 'Enable notifications';

  @override
  String get settingsEnableNotificationSubtitle =>
      'Receive notifications from the system';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsDisplayLanguage => 'Display language';

  @override
  String get settingsLanguageVietnamese => 'Tiếng Việt';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsSectionOffline => 'Offline data';

  @override
  String get settingsClearMapCache => 'Clear map cache';

  @override
  String get settingsClearMapCacheSubtitle =>
      'Remove downloaded map and route data from this device';

  @override
  String get settingsClearMapCacheConfirm =>
      'This removes downloaded map and route data from this device. The app will reload them when needed.';

  @override
  String get settingsClearMapCacheSuccess => 'Map cache cleared';

  @override
  String get settingsSectionAppInfo => 'App information';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsAboutDescription =>
      'An app that helps patients look up information, navigate inside the hospital and manage their appointments.';

  @override
  String get settingsDeletePasswordIncorrect =>
      'Incorrect password. Please try again.';
}
