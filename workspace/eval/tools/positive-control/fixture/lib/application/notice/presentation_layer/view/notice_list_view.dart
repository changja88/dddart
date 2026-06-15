import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/network/bad_request_response.dart';
import '../../../../design_system/component/feedback/error_feedback.dart';
import '../../../../design_system/component/loading/loading.dart';
import '../../../../design_system/foundation/app_color.dart';
import '../../application_layer/state/notice_list_state.dart';
import '../../application_layer/view_model/notice_list_vm.dart';
import '../../domain_layer/notice/notice.dart';
import '../section/notice_list_content_section.dart';

class NoticeListView extends ConsumerWidget {
  const NoticeListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<NoticeListState> noticeList = ref.watch(noticeListVMProvider);

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(title: const Text('공지사항')),
      body: noticeList.when(
        data: (NoticeListState state) => NoticeListContentSection(
          state: state,
          onNoticeTap: (int index) {
            final Notice notice = state.notices[index];
            ref.read(noticeListVMProvider.notifier).openNotice(notice.id);
          },
        ),
        error: (Object error, StackTrace stackTrace) => ErrorFeedback(
          title: '공지를 불러오지 못했어요',
          message: _messageFor(error),
          onRetry: () => ref.invalidate(noticeListVMProvider),
        ),
        loading: () => const Loading(message: '공지를 불러오는 중'),
      ),
    );
  }

  String _messageFor(Object error) {
    if (error is BadRequestResponse) return error.msg;

    return '잠시 뒤 다시 시도해 주세요.';
  }
}
