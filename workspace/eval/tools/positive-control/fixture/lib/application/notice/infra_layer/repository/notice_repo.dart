import 'package:dartz/dartz.dart';

import '../../../../common/network/bad_request_response.dart';
import '../../../../common/network/dio_client.dart';
import '../../../../common/network/safe_api_call.dart';
import '../../domain_layer/notice/notice.dart';
import '../data_source/notice_data_source.dart';

class NoticeRepo {
  final NoticeDataSource _dataSource = NoticeDataSource(DioClient.instance);

  Future<Either<BadRequestResponse, List<Notice>>> getNotices() {
    return safeApiCall(_dataSource.getNotices);
  }

  Future<Either<BadRequestResponse, Notice>> getNotice(int id) {
    return safeApiCall(() => _dataSource.getNotice(id));
  }
}
