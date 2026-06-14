import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smaple/application/notice/application_layer/view_model/notice_list_vm.dart';
import 'package:smaple/common/network/bad_request_response.dart';
import 'package:smaple/common/network/dio_client.dart';

void main() {
  late HttpClientAdapter previousAdapter;

  setUp(() {
    previousAdapter = DioClient.instance.httpClientAdapter;
  });

  tearDown(() {
    DioClient.instance.httpClientAdapter = previousAdapter;
  });

  group('NoticeListVM', () {
    test('sorts pinned first then newest', () async {
      DioClient.instance.httpClientAdapter = _JsonHttpClientAdapter(
        (_) => const _FakeResponse(
          body: '''
[
  {"id": 1, "title": "old-plain", "category": "notice", "pinned": false, "published_at": "2026-06-01T09:00:00.000"},
  {"id": 2, "title": "new-plain", "category": "event", "pinned": false, "published_at": "2026-06-12T09:00:00.000"},
  {"id": 3, "title": "old-pinned", "category": "notice", "pinned": true, "published_at": "2026-06-02T09:00:00.000"}
]
''',
        ),
      );
      final container = ProviderContainer.test(retry: _disableProviderRetry);

      final state = await container.read(noticeListVMProvider.future);

      // 고정 공지(id 3) 최상단, 그다음 미고정 최신순(id 2 → id 1).
      expect(state.notices.map((notice) => notice.id).toList(), [3, 2, 1]);
      expect(state.notices.first.title, 'old-pinned');
    });

    test('throws normalized error into AsyncValue on parsing failure', () async {
      DioClient.instance.httpClientAdapter = _JsonHttpClientAdapter(
        (_) => const _FakeResponse(
          body: '''
[
  {"id": 1, "title": "bad", "category": "spam", "pinned": false, "published_at": "2026-06-01T09:00:00.000"}
]
''',
        ),
      );
      final container = ProviderContainer.test(retry: _disableProviderRetry);

      await expectLater(
        container.read(noticeListVMProvider.future),
        throwsA(isA<BadRequestResponse>()),
      );
    });
  });
}

Duration? _disableProviderRetry(int retryCount, Object error) => null;

class _JsonHttpClientAdapter implements HttpClientAdapter {
  const _JsonHttpClientAdapter(this.respond);

  final _FakeResponse Function(RequestOptions options) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = respond(options);

    return ResponseBody.fromString(
      response.body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeResponse {
  const _FakeResponse({required this.body});

  final String body;
}
