import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Service/login_service.dart';
import 'package:university_system_front/Service/uni_system_client/request_mode_provider.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/modal_widgets.dart';
import 'package:university_system_front/l10n/locale_controller.dart';

class UserMenuButton extends ConsumerWidget {
  const UserMenuButton({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => ref.read(loginServiceProvider.notifier).signOut(),
          child: Text(context.localizations.signOutPopupMenu),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                ref.read(currentLocaleProvider.notifier).changeLocale(UniSystemLocale.en);
              },
              trailingIcon:
                  ref.watch(currentLocaleProvider) == UniSystemLocale.en.locale ? const Icon(Icons.check_rounded) : null,
              child: Text("${UniSystemLocale.en.localeName} (${UniSystemLocale.en.localeString})"),
            ),
            MenuItemButton(
              onPressed: () {
                ref.read(currentLocaleProvider.notifier).changeLocale(UniSystemLocale.es);
              },
              trailingIcon:
                  ref.watch(currentLocaleProvider) == UniSystemLocale.es.locale ? const Icon(Icons.check_rounded) : null,
              child: Text("${UniSystemLocale.es.localeName} (${UniSystemLocale.es.localeString})"),
            ),
          ],
          child: Text(context.localizations.setLang),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                ref.read(requestModeProvider.notifier).changeRequestMode(UniSysApiRequestMethod.rest);
              },
              trailingIcon:
                  ref.watch(requestModeProvider) == UniSysApiRequestMethod.rest ? const Icon(Icons.check_rounded) : null,
              child: Text(context.localizations.requestModeREST),
            ),
            MenuItemButton(
              onPressed: () {
                ref.read(requestModeProvider.notifier).changeRequestMode(UniSysApiRequestMethod.graphQl);
              },
              trailingIcon:
                  ref.watch(requestModeProvider) == UniSysApiRequestMethod.graphQl ? const Icon(Icons.check_rounded) : null,
              child: Text(context.localizations.requestModeGraphQl),
            )
          ],
          child: Text(context.localizations.toggleRequestMode),
        ),
        MenuItemButton(
          onPressed: () => showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const DialogModal(
                canPop: true,
                child: LicensePage(
                  applicationLegalese: "Copyright 2024-2025, Keneth Berrio.",
                ),
              );
            },
          ),
          child: Text(context.localizations.aboutPageButton),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          onPressed: !enabled
              ? null
              : () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
          icon: const Icon(Icons.account_circle_sharp),
          iconSize: 32,
        );
      },
    );
  }
}
