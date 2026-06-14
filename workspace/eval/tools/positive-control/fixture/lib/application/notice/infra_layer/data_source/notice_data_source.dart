import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../domain_layer/notice/notice.dart';

part 'notice_data_source.g.dart';

@RestApi()
abstract class NoticeDataSource {
  factory NoticeDataSource(Dio dio, {String? baseUrl}) = _NoticeDataSource;

  @GET('/api/v1/notices/')
  Future<List<Notice>> getNotices();

  @GET('/api/v1/notices/{id}/')
  Future<Notice> getNotice(@Path('id') int id);
}
