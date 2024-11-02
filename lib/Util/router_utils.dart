import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Router/go_router_routes.dart';

extension PopFromDialog on BuildContext {
  void goEditPage(GoRouterRoutes editPage, Object extra) {
    assert(editPage.parent != null && editPage.parent?.parent != null);
    GoRouter.of(this).pushReplacement('${editPage.parent!.parent!.routeName}/${editPage.parent!.routeName}/${editPage.routeName}',
        extra: extra);
  }

  void goDetailPage(GoRouterRoutes detailPage, Object extra) {
    assert(detailPage.parent != null);
    GoRouter.of(this).go('${detailPage.parent!.routeName}/${detailPage.routeName}', extra: extra);
  }

  void popFromDialog() {
    Navigator.of(this, rootNavigator: true).pop();
  }

  ///Used for going to parent from edit page with opened modal
  void popFromModalDialogToParent(GoRouterRoutes editPage) {
    assert(editPage.parent != null && editPage.parent?.parent != null);
    GoRouter.of(this).pop();
    GoRouter.of(this).go(editPage.parent!.parent!.routeName);
  }
}
