import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Adapter/secure_storage_adapter.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Router/go_router_config.dart';
import 'package:university_system_front/Util/provider_utils.dart';
import 'package:university_system_front/main.dart';

Future<void> freshLoggedInInstanceHelper(WidgetTester widgetTester,
    {bool newJwt = true, bool keepJwt = false, bool autoLogin = true}) async {
  if (newJwt) {
    await SecureStorageAdapter().deleteValue(BearerTokenType.jwt.name);
  }

  if (!keepJwt) {
    addTearDown(() async => await SecureStorageAdapter().deleteValue(BearerTokenType.jwt.name));
  }

  await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

  if (autoLogin) {
    await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

    final textFormFieldFinder = find.byType(TextFormField);
    final filledButtonFinder = find.byType(FilledButton);

    final textFormFieldEmailFinder = find.ancestor(
        of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginEmailHint),
        matching: textFormFieldFinder);
    final textFormFieldPasswordFinder = find.ancestor(
        of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginPasswordHint),
        matching: textFormFieldFinder);

    const testUserEmail = String.fromEnvironment("INTEG_TEST_USER_MAIL");
    const testUserPassword = String.fromEnvironment("INTEG_TEST_USER_PASSWORD");
    expect(testUserEmail, isNotEmpty, reason: 'Set up env vars using --dart-define=INTEG_TEST_USER_MAIL=');
    expect(testUserPassword, isNotEmpty, reason: 'Set up env vars using --dart-define=INTEG_TEST_USER_PASSWORD=');
    
    await widgetTester.enterText(textFormFieldEmailFinder, testUserEmail);
    await widgetTester.enterText(textFormFieldPasswordFinder, testUserPassword);

    await widgetTester.tap(filledButtonFinder);
    await widgetTester.pumpAndSettle();
  }
}

GoRouter getGoRouter(WidgetTester widgetTester, Finder finder) {
  return ProviderScope.containerOf(widgetTester.element(finder)).read(goRouterInstanceProvider);
}
