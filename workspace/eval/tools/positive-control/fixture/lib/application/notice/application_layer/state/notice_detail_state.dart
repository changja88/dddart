import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../common/network/bad_request_response.dart';
import '../../domain_layer/notice/notice.dart';

part 'notice_detail_state.freezed.dart';

@freezed
abstract class NoticeDetailState with _$NoticeDetailState {
  const factory NoticeDetailState({
    required Notice notice,
    BadRequestResponse? error,
  }) = _NoticeDetailState;
}
