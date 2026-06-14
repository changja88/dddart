import 'package:dartz/dartz.dart';

import '../../../../common/network/bad_request_response.dart';
import '../../domain_layer/notice/notice.dart';
import '../../infra_layer/repository/notice_repo.dart';

class NoticeUseCase {
  final NoticeRepo _repo = NoticeRepo();

  Future<Either<BadRequestResponse, List<Notice>>> getNotices() {
    return _repo.getNotices();
  }

  Future<Either<BadRequestResponse, Notice>> getNotice(int id) {
    return _repo.getNotice(id);
  }
}
