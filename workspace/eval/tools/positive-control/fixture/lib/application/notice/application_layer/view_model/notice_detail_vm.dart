import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../state/notice_detail_state.dart';
import '../use_case/notice_use_case.dart';

part 'notice_detail_vm.g.dart';

@riverpod
class NoticeDetailVM extends _$NoticeDetailVM {
  @override
  FutureOr<NoticeDetailState> build(String noticeId) async {
    final result = await NoticeUseCase().getNotice(int.parse(noticeId));

    return result.fold(
      (error) => throw error,
      (notice) => NoticeDetailState(notice: notice),
    );
  }
}
