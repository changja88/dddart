enum NoticeCategory {
  notice('notice'),
  event('event'),
  emergency('emergency');

  const NoticeCategory(this.serverCode);

  final String serverCode;

  factory NoticeCategory.fromJson(String value) {
    return switch (value) {
      'notice' => NoticeCategory.notice,
      'event' => NoticeCategory.event,
      'emergency' => NoticeCategory.emergency,
      _ => throw FormatException('Unknown notice category', value),
    };
  }

  String toJson() => serverCode;
}

NoticeCategory noticeCategoryFromJson(String value) =>
    NoticeCategory.fromJson(value);

String noticeCategoryToJson(NoticeCategory category) => category.toJson();
