import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../common/service/app_navigator_service.dart';
import 'notice_router.dart';

abstract final class NoticeNavigator {
  static void openDetail(int id) {
    final BuildContext? context = appNavigatorKey.currentContext;
    if (context == null) return;

    context.pushNamed(
      NoticeRoutes.detailName,
      pathParameters: <String, String>{NoticeRoutes.idPathParameter: '$id'},
    );
  }
}
