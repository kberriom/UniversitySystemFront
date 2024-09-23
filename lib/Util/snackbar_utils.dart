import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Service/login_service.dart';
import 'package:university_system_front/Widget/navigation/base_scaffold_navigation/admin_scaffold_navigation_widget.dart';

///Shows a SnackBar in a local Scaffold that has a [ScaffoldMessenger] parent.
///Clears any existing SnackBars
void showLocalSnackBar(GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, String content) {
  final snackBar = SnackBar(content: Text(content));
  scaffoldMessengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(snackBar);
}

///Shows a SnackBar the closest [ScaffoldMessenger] of context
///Clears any existing SnackBars
extension GetContextSnackbar on BuildContext {
  void showSnackBar(String content) {
    final snackBar = SnackBar(content: Text(content));
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }
}

extension GetGlobalSnackBar on WidgetRef {
  ///Shows a SnackBar in the main Scaffold for the current [UserRole] in [LoginService], on top of existing ui if present.
  ///
  ///Must be logged in.
  ///
  ///Clears any existing SnackBars
  void showGlobalSnackBar(String content) async {
    final snackBar = SnackBar(content: Text(content));
    BearerToken bearerToken = await read(loginServiceProvider.future);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      switch (bearerToken.role) {
        case UserRole.admin:
          adminScaffoldMessengerKey.currentState
            ?..clearSnackBars()
            ..showSnackBar(snackBar);
        case UserRole.teacher:
          // TODO: Handle this case.
          throw UnimplementedError();
        case UserRole.student:
          // TODO: Handle this case.
          throw UnimplementedError();
        case null:
      }
    });
  }
}
