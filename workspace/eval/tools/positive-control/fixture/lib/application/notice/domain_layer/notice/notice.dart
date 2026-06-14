import 'package:freezed_annotation/freezed_annotation.dart';

import 'enum/notice_category.dart';

part 'notice.freezed.dart';
part 'notice.g.dart';

@freezed
abstract class Notice with _$Notice {
  const Notice._();

  const factory Notice({
    required int id,
    required String title,
    @JsonKey(fromJson: noticeCategoryFromJson, toJson: noticeCategoryToJson)
    required NoticeCategory category,
    required bool pinned,
    @JsonKey(name: 'published_at') required DateTime publishedAt,
  }) = _Notice;

  factory Notice.fromJson(Map<String, Object?> json) => _$NoticeFromJson(json);

  /// 강조 노출 판정(도메인 규칙) — 고정 공지이거나 긴급 분류이면 강조한다.
  /// 소비처(presentation)는 이 결과만 표시하고 규칙을 재계산하지 않는다.
  bool get isHighlighted => pinned || category == NoticeCategory.emergency;
}
