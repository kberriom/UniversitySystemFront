import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Theme/theme.dart' as theme;
import 'package:university_system_front/Theme/theme_mode_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'Provider/login_provider.dart';
import 'Router/go_router_config.dart';
import 'Util/provider_logger.dart';

final class _UniversitySystemUiGoRouter extends GoRouterConfig {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.instance.registerSingleton<GoRouter>(_UniversitySystemUiGoRouter().router);
  if (Platform.isWindows) {
    await WindowManager.instance.ensureInitialized();
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    appWindow.minSize = const Size(384, 782);
  }
  runApp(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));
}

class UniversitySystemUi extends ConsumerWidget {
  const UniversitySystemUi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _LoginInitialization(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'University System UI',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
        ],
        theme: const theme.MaterialTheme().light(),
        darkTheme: const theme.MaterialTheme().dark(),
        themeMode: ref.watch(currentThemeModeProvider),
        routerConfig: GetIt.instance.get<GoRouter>(),
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
