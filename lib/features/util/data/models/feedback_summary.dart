// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_summary.freezed.dart';
part 'feedback_summary.g.dart';

@freezed
class FeedbackSummary with _$FeedbackSummary {
  const factory FeedbackSummary({
    @JsonKey(name: 'total_feedbacks') required int totalFeedbacks,
    @JsonKey(name: 'average_rating') required double averageRating,
  }) = _FeedbackSummary;

  factory FeedbackSummary.fromJson(Map<String, dynamic> json) =>
      _$FeedbackSummaryFromJson(json);
}
