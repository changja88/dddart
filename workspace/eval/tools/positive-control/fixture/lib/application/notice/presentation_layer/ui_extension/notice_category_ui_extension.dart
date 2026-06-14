import 'package:flutter/material.dart';

import '../../../../design_system/foundation/app_color.dart';
import '../../domain_layer/notice/enum/notice_category.dart';

extension NoticeCategoryUiExtension on NoticeCategory {
  String get label {
    return switch (this) {
      NoticeCategory.notice => '공지',
      NoticeCategory.event => '이벤트',
      NoticeCategory.emergency => '긴급',
    };
  }

  Color get color {
    return switch (this) {
      NoticeCategory.notice => AppColor.primary,
      NoticeCategory.event => AppColor.sunny,
      NoticeCategory.emergency => AppColor.error,
    };
  }

  IconData get icon {
    return switch (this) {
      NoticeCategory.notice => Icons.campaign_outlined,
      NoticeCategory.event => Icons.celebration_outlined,
      NoticeCategory.emergency => Icons.warning_amber_outlined,
    };
  }
}
