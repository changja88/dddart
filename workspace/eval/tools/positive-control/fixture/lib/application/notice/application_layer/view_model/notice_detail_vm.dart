import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../common/network/bad_request_response.dart';
import '../../domain_layer/notice/notice.dart';
import '../state/notice_detail_state.dart';
import '../use_case/notice_use_case.dart';

part 'notice_detail_vm.g.dart';

@riverpod
class NoticeDetailVM extends _$NoticeDetailVM {
  @override
  FutureOr<NoticeDetailState> build(String noticeId) async {
    final Either<BadRequestResponse, Notice> result =
        await NoticeUseCase().getNotice(int.parse(noticeId));

    return result.fold(
      (BadRequestResponse error) => throw error,
      (Notice notice) => NoticeDetailState(notice: notice),
    );
  }
}
