import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../common/network/bad_request_response.dart';
import '../../domain_layer/notice/notice.dart';
import '../../notice_navigator.dart';
import '../state/notice_list_state.dart';
import '../use_case/notice_use_case.dart';

part 'notice_list_vm.g.dart';

@riverpod
class NoticeListVM extends _$NoticeListVM {
  @override
  FutureOr<NoticeListState> build() async {
    final Either<BadRequestResponse, List<Notice>> result =
        await NoticeUseCase().getNotices();

    return result.fold(
      (BadRequestResponse error) => throw error,
      (List<Notice> notices) =>
          NoticeListState(notices: _sortedForDisplay(notices)),
    );
  }

  void openNotice(int id) {
    NoticeNavigator.openDetail(id);
  }

  /// 표시 정렬(VM 변환 — architecture-ddd §5): 고정 공지를 상단에, 그다음 최신 게시순.
  List<Notice> _sortedForDisplay(List<Notice> notices) {
    final List<Notice> sorted = <Notice>[...notices];
    sorted.sort((Notice a, Notice b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }

      return b.publishedAt.compareTo(a.publishedAt);
    });

    return sorted;
  }
}
