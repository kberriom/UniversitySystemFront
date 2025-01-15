import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Router/go_router_config.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/theme.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

class TokenExpiredWidget extends ConsumerWidget {
  const TokenExpiredWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: MaterialTheme.fixedPrimary.value.withValues(alpha: 0.75),
        appBar: context.isWindows ? const DynamicUniSystemAppBar(isInLogin: true) : null,
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.5, sigmaY: 5.5),
          child: AlertDialog(
            title: Text(AppLocalizations.of(context)!.sessionExpired),
            content: Text(AppLocalizations.of(context)!.sessionExpiredMessage),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(goRouterInstanceProvider).goNamed(GoRouterRoutes.login.routeName);
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
