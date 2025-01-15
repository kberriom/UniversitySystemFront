import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Widget/navigation/leading_widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'go_router_routes.dart';

///Builds a [GoRoute] sub route that is compatible with the [uniSystemAppBarLeadingProvider].
///
/// Use for building new sub routes on top of a sub route.
///
/// E.g: edit route that returns to a detail route.
///
/// has [state.extra] in [widgetBuilder]
///
///Includes a [UniSystemCustomBackButton] if [leadingBuilder] is null
///
/// [T] _MUST_ be a [MappableClass] implementation and have its mapper initialized.
///
/// All fields in [T] _MUST_ also comply with the former requirement.
GoRoute buildChildSubRoute<T extends Object?>({
  required Ref ref,
  required GoRouterRoutes childSubRoute,
  required GoRouterRoutes parentSubRoute,
  required Widget Function(T? item) widgetBuilder,
  UniSystemSmartLeadButton Function(T? item)? leadingBuilder,
}) {
  assert(childSubRoute.parent == parentSubRoute, "parentSubRoute must be the parent of childSubRoute");
  assert(parentSubRoute.parent != null, "parentSubRoute must have a root '/' parent defined");
  return GoRoute(
    path: childSubRoute.routeName,
    name: childSubRoute.routeName,
    onExit: (context, state) {
      if (PlatformUtil.isWindows) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ref.invalidate(uniSystemAppBarLeadingProvider));
        VisibilityDetectorController.instance.notifyNow();
      }
      return true;
    },
    pageBuilder: (context, state) {
      T? item;
      if (null is! T) {
        item = getExtra<T>(state, errorMsg: "invalid extra arg in ${T.toString()} edit route builder");
      }
      UniSystemSmartLeadButton? leadingButton;
      if (leadingBuilder != null) {
        leadingButton = leadingBuilder(item);
      }
      return NoTransitionPage(
        child: setLeadingOnWindows(
          leading: leadingButton ?? UniSystemCustomBackButton(
            route: '${parentSubRoute.parent!.routeName}/${parentSubRoute.routeName}',
            extra: item,
          ),
          state.pageKey,
          widgetBuilder(item),
        ),
      );
    },
  );
}

///Builds a [GoRoute] sub route that is compatible with the [uniSystemAppBarLeadingProvider].
///
/// Use for building new sub routes on top of a [StatefulShellBranch] root.
/// has [state.extra] in [widgetBuilder]
///
///Includes the default leading in the appbar [UniSystemBackButton]
///
/// [T] _MUST_ be a [MappableClass] implementation and have its mapper initialized.
///
/// All fields in [T] _MUST_ also comply with the former requirement.
GoRoute buildRootChildRouteWithExtra<T>({
  required Ref ref,
  required GoRouterRoutes route,
  required Widget Function(T item) widgetBuilder,
  required List<GoRoute> routes,
}) {
  assert(route.parent != null, "RootChildRoute must have a parent");
  assert(route.parent!.parent == null, "The parent of RootChildRoute must be a root");
  return GoRoute(
    path: route.routeName,
    name: route.routeName,
    onExit: (context, state) {
      if (PlatformUtil.isWindows) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ref.invalidate(uniSystemAppBarLeadingProvider));
      }
      return true;
    },
    pageBuilder: (context, state) {
      final T item = getExtra<T>(state, errorMsg: "invalid extra arg in ${T.toString()} detail route builder");
      return NoTransitionPage(child: setLeadingOnWindows(state.pageKey, widgetBuilder(item)));
    },
    routes: routes,
  );
}

///Builds a [GoRoute] sub route that is compatible with the [uniSystemAppBarLeadingProvider].
///
/// Use for building new sub routes on top of a [StatefulShellBranch] root.
///
///Includes the default leading in the appbar [UniSystemBackButton]
GoRoute buildRootChildRoute({
  required Ref ref,
  required GoRouterRoutes route,
  required Widget Function() widgetBuilder,
  List<GoRoute> routes = const <GoRoute>[],
}) {
  assert(route.parent != null, "RootChildRoute must have a parent");
  assert(route.parent!.parent == null, "The parent of RootChildRoute must be a root");
  return GoRoute(
    path: route.routeName,
    name: route.routeName,
    onExit: (context, state) {
      if (PlatformUtil.isWindows) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ref.invalidate(uniSystemAppBarLeadingProvider));
      }
      return true;
    },
    pageBuilder: (context, state) {
      return NoTransitionPage(child: setLeadingOnWindows(state.pageKey, widgetBuilder()));
    },
    routes: routes,
  );
}

///Extracts the extra argument from a [GoRouterState] provided by a pageBuilder.
///
/// [GoRouter] can pass [state.extra] as a Json that needs to be parsed
///
/// If [GoRouter] fails to serialize extra it will be return as [_null_] even if it was passed in the navigation request, so
///
/// [T] _MUST_ be a [MappableClass] implementation and have its mapper initialized.
///
/// All fields in [T] _MUST_ also comply with the former requirement.
T getExtra<T>(GoRouterState state, {required String errorMsg}) {
  assert(state.extra != null, """Router did not include extra,
       make sure all posible entry points pass extra correctly and that all fields in extra are FULLY compatible with MappableClass,
        such as enums or other Objects""");
  T item;
  if (state.extra is T) {
    item = state.extra as T;
  } else if (state.extra is String) {
    //Go router serializes extra for state restoration
    item = MapperContainer.globals.fromJson<T>.call(state.extra as String);
  } else {
    throw ArgumentError(errorMsg);
  }
  return item;
}
