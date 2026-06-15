import 'package:flutter/material.dart';

import '../../../../design_system/component/feedback/empty_feedback.dart';
import '../../../../design_system/foundation/app_spacing.dart';
import '../../application_layer/state/notice_list_state.dart';
import '../../domain_layer/notice/notice.dart';
import '../widget/notice_row_widget.dart';

class NoticeListContentSection extends StatelessWidget {
  const NoticeListContentSection({
    super.key,
    required this.state,
    required this.onNoticeTap,
  });

  final NoticeListState state;
  final void Function(int index) onNoticeTap;

  @override
  Widget build(BuildContext context) {
    if (state.notices.isEmpty) {
      return const EmptyFeedback(
        title: '공지가 없어요',
        message: '등록된 공지가 없습니다. 잠시 뒤 다시 확인해 주세요.',
        icon: Icons.campaign_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.screen,
      ),
      itemBuilder: (BuildContext context, int index) {
        final Notice notice = state.notices[index];

        return NoticeRowWidget(notice: notice, onTap: () => onNoticeTap(index));
      },
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AppSpacing.md),
      itemCount: state.notices.length,
    );
  }
}
