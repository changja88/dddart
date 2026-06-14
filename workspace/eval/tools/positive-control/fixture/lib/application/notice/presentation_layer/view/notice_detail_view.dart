import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/network/bad_request_response.dart';
import '../../../../design_system/component/feedback/error_feedback.dart';
import '../../../../design_system/component/loading/loading.dart';
import '../../../../design_system/foundation/app_color.dart';
import '../../application_layer/view_model/notice_detail_vm.dart';
import '../section/notice_detail_section.dart';

class NoticeDetailView extends ConsumerWidget {
  const NoticeDetailView({super.key, required this.noticeId});

  final String noticeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticeDetail = ref.watch(noticeDetailVMProvider(noticeId));

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: '뒤로가기',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('공지 상세'),
      ),
      body: noticeDetail.when(
        data: (state) => NoticeDetailSection(notice: state.notice),
        error: (error, stackTrace) => ErrorFeedback(
          title: '공지를 불러오지 못했어요',
          message: _messageFor(error),
          onRetry: () => ref.invalidate(noticeDetailVMProvider(noticeId)),
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
