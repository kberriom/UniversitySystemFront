import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/theme.dart';

class TokenExpiredWidget extends StatelessWidget {
  const TokenExpiredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: MaterialTheme.fixedPrimary.value.withOpacity(0.75),
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.5, sigmaY: 5.5),
          child: AlertDialog(
            title: Text(AppLocalizations.of(context)!.sessionExpired),
            content: Text(AppLocalizations.of(context)!.sessionExpiredMessage),
            actions: [
              TextButton(
                onPressed: () {
                  context.goNamed(GoRouterRoutes.login.routeName);
                },
                child: Text(
                  AppLocalizations.of(context)!.sessionExpiredConfirmation,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
