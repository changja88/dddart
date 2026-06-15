import 'package:flutter/material.dart';

import '../../../../design_system/foundation/app_spacing.dart';
import '../../../../design_system/foundation/app_typography.dart';
import '../../domain_layer/notice/notice.dart';
import '../ui_extension/notice_category_ui_extension.dart';

class NoticeDetailSection extends StatelessWidget {
  const NoticeDetailSection({super.key, required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(notice.category.icon, color: notice.category.color),
              const SizedBox(width: AppSpacing.sm),
              Text(notice.category.label, style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(notice.title, style: AppTypography.title),
        ],
      ),
    );
  }
}
