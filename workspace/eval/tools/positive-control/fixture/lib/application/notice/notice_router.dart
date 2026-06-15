import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation_layer/view/notice_detail_view.dart';
import 'presentation_layer/view/notice_list_view.dart';

abstract final class NoticeRoutes {
  static const String listName = 'noticeList';
  static const String listPath = '/notices';

  static const String idPathParameter = 'id';
  static const String detailName = 'noticeDetail';
  static const String detailRelativePath = ':$idPathParameter';
  static const String detailPath = '$listPath/$detailRelativePath';
}

final GoRoute noticeRouter = GoRoute(
  path: NoticeRoutes.listPath,
  name: NoticeRoutes.listName,
  builder: (BuildContext context, GoRouterState state) => const NoticeListView(),
  routes: <RouteBase>[
    GoRoute(
      path: NoticeRoutes.detailRelativePath,
      name: NoticeRoutes.detailName,
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters[NoticeRoutes.idPathParameter]!;

        return NoticeDetailView(noticeId: id);
      },
    ),
  ],
);
