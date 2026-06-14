import 'package:go_router/go_router.dart';

import '../../common/service/app_navigator_service.dart';
import 'notice_router.dart';

abstract final class NoticeNavigator {
  static void openDetail(int id) {
    final context = appNavigatorKey.currentContext;
    if (context == null) return;

    context.pushNamed(
      NoticeRoutes.detailName,
      pathParameters: {NoticeRoutes.idPathParameter: '$id'},
    );
  }
}
