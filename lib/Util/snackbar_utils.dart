import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

extension GetGlobalSnackBar on WidgetRef {
  ///Shows a SnackBar in the main Scaffold, on top of existing ui.
  ///
  ///Clears any existing SnackBars
  void showGlobalSnackBar(String content) async {
    final snackBar = SnackBar(content: Text(content));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      rootScaffoldMessengerKey.currentState
        ?..clearSnackBars()
        ..showSnackBar(snackBar);
    });
  }
}
