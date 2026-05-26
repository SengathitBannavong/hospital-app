import 'package:freezed_annotation/freezed_annotation.dart';

part 'util_feedback_response.freezed.dart';
part 'util_feedback_response.g.dart';

@freezed
class UtilFeedbackResponse with _$UtilFeedbackResponse {
  const factory UtilFeedbackResponse({required String message}) =
      _UtilFeedbackResponse;

  factory UtilFeedbackResponse.fromJson(Map<String, dynamic> json) =>
      _$UtilFeedbackResponseFromJson(json);
}
