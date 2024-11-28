import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension ShowSnackBar on GlobalKey<ScaffoldMessengerState> {
  ///Shows a SnackBar in a local Scaffold that has a [ScaffoldMessenger] parent.
  ///Clears any existing SnackBars
  void showTextSnackBar(String content) {
    final snackBar = SnackBar(content: Text(content));
    currentState
      ?..clearSnackBars()
      ..showSnackBar(snackBar);
  }
}

///Shows a SnackBar at the closest [ScaffoldMessenger] of context
///Clears any existing SnackBars
extension GetContextSnackbar on BuildContext {
  void showTextSnackBar(String content) {
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
  void showTextSnackBar(String content) async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      rootScaffoldMessengerKey.showTextSnackBar(content);
    });
  }
}
