import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Provider/login_provider.dart';
import 'package:university_system_front/Router/go_router_config.dart';
import 'package:university_system_front/Theme/theme.dart' show MaterialTheme;

class BaseLoginWidget extends ConsumerWidget {
  ///The widget list to be placed in a stack created in the logo position
  final List<Widget> logoImageWidgetList;
  final Widget loginWidgetForm;
  final bool canPop;

  const BaseLoginWidget({super.key, required this.logoImageWidgetList, required this.loginWidgetForm, this.canPop = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Listener to redirect to home when user is authenticated
    //will get auto disposed by Riverpod
    ref.listen(loginProvider, (previous, next) {
      switch (next) {
        case AsyncValue<BearerToken>(:final value?):
          {
            if (value.token.isNotEmpty) {
              ref.read(userRoleRedirectionProvider.call(value));
            }
          }
      }
    });

    return PopScope(
      canPop: canPop,
      child: Scaffold(
        backgroundColor: MaterialTheme.fixedPrimary.value,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(disposition: UnfocusDisposition.scope);
          },
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SizedBox(
                  //This SizedBox keeps all widgets on the same place even on keyboard input
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: logoImageWidgetList,
                        ),
                      ),
                      const SizedBox(height: 33),
                      loginWidgetForm,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
