import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../common/network/bad_request_response.dart';
import '../../domain_layer/notice/notice.dart';

part 'notice_list_state.freezed.dart';

@freezed
abstract class NoticeListState with _$NoticeListState {
  const factory NoticeListState({
    @Default(<Notice>[]) List<Notice> notices,
    BadRequestResponse? error,
  }) = _NoticeListState;
}
