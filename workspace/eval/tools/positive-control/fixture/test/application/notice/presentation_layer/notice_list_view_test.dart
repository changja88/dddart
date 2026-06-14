import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:smaple/application/notice/application_layer/state/notice_list_state.dart';
import 'package:smaple/application/notice/application_layer/view_model/notice_list_vm.dart';
import 'package:smaple/application/notice/domain_layer/notice/enum/notice_category.dart';
import 'package:smaple/application/notice/domain_layer/notice/notice.dart';
import 'package:smaple/application/notice/notice_router.dart';
import 'package:smaple/common/network/bad_request_response.dart';
import 'package:smaple/common/service/app_navigator_service.dart';

void main() {
  group('NoticeListView', () {
    testWidgets('shows loading branch while notices are pending', (tester) async {
      final completer = Completer<NoticeListState>();

      await tester.pumpWidget(
        _appWithOverrides([
          noticeListVMProvider.overrideWithBuild(
            (ref, notifier) => completer.future,
          ),
        ]),
      );

      expect(find.text('공지를 불러오는 중'), findsOneWidget);
      completer.complete(const NoticeListState());
    });

    testWidgets('shows error branch and retry invalidates list provider', (
      tester,
    ) async {
      var attempts = 0;

      await tester.pumpWidget(
        _appWithOverrides([
          noticeListVMProvider.overrideWithBuild((ref, notifier) async {
            attempts++;
            throw const BadRequestResponse(
              errorType: 'network',
              msg: 'network failed',
              isShow: true,
            );
          }),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('공지를 불러오지 못했어요'), findsOneWidget);
      expect(find.text('network failed'), findsOneWidget);

      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
    });

    testWidgets('shows empty branch when there are no notices', (tester) async {
      await tester.pumpWidget(
        _appWithOverrides([
          noticeListVMProvider.overrideWithBuild(
            (ref, notifier) async => const NoticeListState(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('공지가 없어요'), findsOneWidget);
    });

    testWidgets('renders notice with category label and highlight badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        _appWithOverrides([
          noticeListVMProvider.overrideWithBuild(
            (ref, notifier) async => NoticeListState(notices: _notices()),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('긴급'), findsOneWidget);
      expect(find.text('점검 안내'), findsOneWidget);
      // emergency → isHighlighted → 강조 표지(push_pin) 노출.
      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });
  });
}

Widget _appWithOverrides(List<Object?> overrides) {
  final router = GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: NoticeRoutes.listPath,
    routes: [noticeRouter],
  );
  addTearDown(router.dispose);

  return ProviderScope(
    retry: _disableProviderRetry,
    overrides: overrides.cast(),
    child: MaterialApp.router(routerConfig: router),
  );
}

Duration? _disableProviderRetry(int retryCount, Object error) => null;

List<Notice> _notices() {
  return [
    Notice(
      id: 1,
      title: '점검 안내',
      category: NoticeCategory.emergency,
      pinned: false,
      publishedAt: DateTime(2026, 6, 14),
    ),
  ];
}
