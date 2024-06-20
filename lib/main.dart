import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Theme/theme.dart' as theme;
import 'package:window_manager/window_manager.dart';

import 'Provider/login_provider.dart';
import 'Router/go_router_config.dart';
import 'Util/provider_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    await WindowManager.instance.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(384, 782));
  }
  runApp(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));
}

class UniversitySystemUi extends StatelessWidget {
  const UniversitySystemUi({super.key});

  @override
  Widget build(BuildContext context) {
    return _LoginInitialization(
      child: MaterialApp.router(
        title: 'University System UI',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
        ],
        theme: const theme.MaterialTheme().light(),
        darkTheme: const theme.MaterialTheme().dark(),
        routerConfig: GoRouterConfig().router,
      ),
    );
  }
}

///This class initializes the login controller which checks secure storage for a previous JWT,
///and sets up the redirection to login for expired or invalid jwt
class _LoginInitialization extends ConsumerWidget {
  final Widget child;

  const _LoginInitialization({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(loginProvider);
    ref.watch(loginRedirectionProvider);
    return child;
  }
}
