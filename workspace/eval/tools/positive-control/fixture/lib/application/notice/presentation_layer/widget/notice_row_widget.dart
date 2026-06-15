import 'package:flutter/material.dart';

import '../../../../design_system/foundation/app_color.dart';
import '../../../../design_system/foundation/app_radius.dart';
import '../../../../design_system/foundation/app_spacing.dart';
import '../../../../design_system/foundation/app_typography.dart';
import '../../domain_layer/notice/notice.dart';
import '../ui_extension/notice_category_ui_extension.dart';

class NoticeRowWidget extends StatelessWidget {
  const NoticeRowWidget({super.key, required this.notice, required this.onTap});

  final Notice notice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(
              color: notice.isHighlighted
                  ? notice.category.color
                  : AppColor.outline,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: <Widget>[
                Icon(notice.category.icon, color: notice.category.color),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (notice.isHighlighted) ...<Widget>[
                            const Icon(
                              Icons.push_pin,
                              size: 14,
                              color: AppColor.error,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          Text(
                            notice.category.label,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(notice.title, style: AppTypography.subtitle),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColor.textVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
