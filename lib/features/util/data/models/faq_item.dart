import 'package:freezed_annotation/freezed_annotation.dart';

part 'faq_item.freezed.dart';
part 'faq_item.g.dart';

@freezed
class FaqItem with _$FaqItem {
  const factory FaqItem({
    required String question,
    required String answer,
    required String category,
  }) = _FaqItem;

  factory FaqItem.fromJson(Map<String, dynamic> json) =>
      _$FaqItemFromJson(json);
}
