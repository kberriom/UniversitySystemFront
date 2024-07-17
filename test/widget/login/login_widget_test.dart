import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:university_system_front/Provider/login_provider.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Widget/login/login_widget.dart';

import 'login_widget_test_provider_mocks.dart';
import 'login_widget_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GoRouter>()])
void main() {
  group('Basic Login widget test', () {
    testWidgets('Must render and login with correct credentials', (widgetTester) async {
      widgetTester.view.physicalSize = const Size(360, 640);
      widgetTester.view.devicePixelRatio = 1.0;
      final mockGoRouter = MockGoRouter();
      GetIt.instance.registerSingleton<GoRouter>(mockGoRouter);
      await widgetTester.pumpWidget(
        ProviderScope(
          overrides: [loginProvider.overrideWith(() => MockOkLogin())],
          child: const MaterialApp(
            home: LoginWidget(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );
      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);
      final textFormFieldEmailFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginEmailHint),
          matching: textFormFieldFinder);
      final textFormFieldPasswordFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginPasswordHint),
          matching: textFormFieldFinder);

      await widgetTester.enterText(textFormFieldEmailFinder, "test@test.com");
      await widgetTester.enterText(textFormFieldPasswordFinder, "testPassword");
      await widgetTester.tap(filledButtonFinder);
      await widgetTester.pumpAndSettle();

      verify(mockGoRouter.goNamed(GoRouterRoutes.adminHome.routeName)).called(1);
      await GetIt.instance.reset();
    });

    testWidgets('Must render and display basic "Invalid email" error', (widgetTester) async {
      widgetTester.view.physicalSize = const Size(360, 640);
      widgetTester.view.devicePixelRatio = 1.0;
      await widgetTester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginWidget(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );
      final imageFinder = find.byType(Image);
      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      await widgetTester.tap(filledButtonFinder);
      await widgetTester.pumpAndSettle();
      final invalidEmailTextFinder = find.text(AppLocalizations.of(widgetTester.element(filledButtonFinder))!.loginEmailError);

      expect(imageFinder, findsOne);
      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);
      expect(invalidEmailTextFinder, findsOne);
    });

    testWidgets('Must render and display basic "Incorrect email or password" error', (widgetTester) async {
      widgetTester.view.physicalSize = const Size(360, 640);
      widgetTester.view.devicePixelRatio = 1.0;
      await widgetTester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginWidget(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );
      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);
      final textFormFieldEmailFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginEmailHint),
          matching: textFormFieldFinder);

      await widgetTester.enterText(textFormFieldEmailFinder, "test@test.com");
      await widgetTester.tap(filledButtonFinder);
      await widgetTester.pumpAndSettle();
      final invalidEmailTextFinder = find.text(AppLocalizations.of(widgetTester.element(filledButtonFinder))!.loginError);

      expect(invalidEmailTextFinder, findsOne);
    });

    testWidgets('Must render and display loading spinner', (widgetTester) async {
      widgetTester.view.physicalSize = const Size(360, 640);
      widgetTester.view.devicePixelRatio = 1.0;
      MaterialApp app = const MaterialApp(
        home: LoginWidget(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      );
      await widgetTester.pumpWidget(ProviderScope(
        overrides: [loginProvider.overrideWith(() => MockLongLogin())],
        child: app,
      ));
      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);
      final textFormFieldEmailFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginEmailHint),
          matching: textFormFieldFinder);
      final textFormFieldPasswordFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginPasswordHint),
          matching: textFormFieldFinder);

      await widgetTester.enterText(textFormFieldEmailFinder, "test@test.com");
      await widgetTester.enterText(textFormFieldPasswordFinder, "testPassword");
      await widgetTester.tap(filledButtonFinder);
      await widgetTester.pump();
      final loadingSpinnerFinder = find.byType(CircularProgressIndicator);

      expect(loadingSpinnerFinder, findsOne);
      await widgetTester.pumpAndSettle();
    });

    testWidgets('Must render and display SnackBar after error', (widgetTester) async {
      widgetTester.view.physicalSize = const Size(360, 640);
      widgetTester.view.devicePixelRatio = 1.0;
      await widgetTester.pumpWidget(
        ProviderScope(
          overrides: [loginProvider.overrideWith(() => MockServerErrorLogin())],
          child: const MaterialApp(
            home: LoginWidget(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );
      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);
      final textFormFieldEmailFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginEmailHint),
          matching: textFormFieldFinder);
      final textFormFieldPasswordFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginPasswordHint),
          matching: textFormFieldFinder);

      await widgetTester.enterText(textFormFieldEmailFinder, "test@test.com");
      await widgetTester.enterText(textFormFieldPasswordFinder, "testPassword");
      await widgetTester.tap(filledButtonFinder);
      final snackBarFinder =
          find.widgetWithText(SnackBar, AppLocalizations.of(widgetTester.element(filledButtonFinder))!.loginServerError);
      while (snackBarFinder.evaluate().isEmpty) {
        await widgetTester.pump();
      }

      expect(snackBarFinder, findsOne);
    });
  });
}
