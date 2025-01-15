import "package:flutter/material.dart";

class MaterialTheme {
  const MaterialTheme();

  ThemeData light() {
    return theme(
      const ColorScheme(
        //dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        brightness: Brightness.light,
        //seedColor: Color(0xff0c5535),
        primary: Color(0xff0c5535),
        secondary: Color(0xFF4E6355),
        tertiary: Color(0xFF3B6471),
        error: Color(0xFFBA1A1A),
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onTertiary: Color(0xFFFFFFFF),
        onError: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFADF2C6),
        secondaryContainer: Color(0xFFD1E8D6),
        tertiaryContainer: Color(0xFFBFE9F8),
        errorContainer: Color(0xFFFFDAD6),
        onPrimaryContainer: Color(0xFF002111),
        onSecondaryContainer: Color(0xFF0C1F14),
        onTertiaryContainer: Color(0xFF001F27),
        onErrorContainer: Color(0xFF410002),
        primaryFixed: Color(0xFFADF2C6),
        primaryFixedDim: Color(0xFF92D5AB),
        secondaryFixed: Color(0xFFD1E8D6),
        secondaryFixedDim: Color(0xFFB5CCBA),
        tertiaryFixed: Color(0xFFBFE9F8),
        tertiaryFixedDim: Color(0xFFA3CDDC),
        onPrimaryFixed: Color(0xFF002111),
        onSecondaryFixed: Color(0xFF0C1F14),
        onTertiaryFixed: Color(0xFF001F27),
        onPrimaryFixedVariant: Color(0xFF075232),
        onSecondaryFixedVariant: Color(0xFF374B3E),
        onTertiaryFixedVariant: Color(0xFF224C58),
        surfaceDim: Color(0xFFD6DBD5),
        surface: Color(0xFFF6FBF4),
        surfaceBright: Color(0xFFF6FBF4),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFF0F5EE),
        surfaceContainer: Color(0xFFEAEFE8),
        surfaceContainerHigh: Color(0xFFE4EAE3),
        surfaceContainerHighest: Color(0xFFDFE4DD),
        onSurface: Color(0xFF171D19),
        onSurfaceVariant: Color(0xFF404942),
        outline: Color(0xFF717972),
        outlineVariant: Color(0xFFC0C9C0),
        inverseSurface: Color(0xFF2C322D),
        onInverseSurface: Color(0xFFEDF2EB),
        inversePrimary: Color(0xFF92D5AB),
        scrim: Color(0xFF000000),
        shadow: Color(0xFF000000),
      ),
    );
  }

  ThemeData dark() {
    return theme(
      const ColorScheme(
        //dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        brightness: Brightness.dark,
        //seedColor: Color(0xff0c5535),
        primary: Color(0xFF92D5AB),
        secondary: Color(0xFFB5CCBA),
        tertiary: Color(0xFFA3CDDC),
        error: Color(0xFFFFB4AB),
        onPrimary: Color(0xFF003920),
        onSecondary: Color(0xFF213528),
        onTertiary: Color(0xFF043541),
        onError: Color(0xFF690005),
        primaryContainer: Color(0xFF075232),
        secondaryContainer: Color(0xFF374B3E),
        tertiaryContainer: Color(0xFF224C58),
        errorContainer: Color(0xFF93000A),
        onPrimaryContainer: Color(0xFFADF2C6),
        onSecondaryContainer: Color(0xFFD1E8D6),
        onTertiaryContainer: Color(0xFFBFE9F8),
        onErrorContainer: Color(0xFFFFDAD6),
        primaryFixed: Color(0xFFADF2C6),
        primaryFixedDim: Color(0xFF92D5AB),
        secondaryFixed: Color(0xFFD1E8D6),
        secondaryFixedDim: Color(0xFFB5CCBA),
        tertiaryFixed: Color(0xFFBFE9F8),
        tertiaryFixedDim: Color(0xFFA3CDDC),
        onPrimaryFixed: Color(0xFF002111),
        onSecondaryFixed: Color(0xFF0C1F14),
        onTertiaryFixed: Color(0xFF001F27),
        onPrimaryFixedVariant: Color(0xFF075232),
        onSecondaryFixedVariant: Color(0xFF374B3E),
        onTertiaryFixedVariant: Color(0xFF224C58),
        surfaceDim: Color(0xFF0F1511),
        surface: Color(0xFF0F1511),
        surfaceBright: Color(0xFF353B36),
        surfaceContainerLowest: Color(0xFF0A0F0C),
        surfaceContainerLow: Color(0xFF171D19),
        surfaceContainer: Color(0xFF1B211D),
        surfaceContainerHigh: Color(0xFF262B27),
        surfaceContainerHighest: Color(0xFF313632),
        onSurface: Color(0xFFDFE4DD),
        onSurfaceVariant: Color(0xFFC0C9C0),
        outline: Color(0xFF8A938B),
        outlineVariant: Color(0xFF404942),
        inverseSurface: Color(0xFFDFE4DD),
        onInverseSurface: Color(0xFF2C322D),
        inversePrimary: Color(0xFF286A48),
        scrim: Color(0xFF000000),
        shadow: Color(0xFF000000),
      ),
    );
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
        navigationBarTheme: NavigationBarThemeData(backgroundColor: colorScheme.surfaceContainer),
        appBarTheme: AppBarTheme(backgroundColor: colorScheme.surfaceBright),
        navigationRailTheme: NavigationRailThemeData(backgroundColor: colorScheme.surface),
        searchBarTheme:
            SearchBarThemeData(elevation: WidgetStateProperty.all(0), constraints: const BoxConstraints(maxWidth: 1000)),
      );

  ///Color used in the login TextField background
  static const darkTextField = ExtendedColor(
    seed: Color(0xff35352d),
    value: Color(0xff35352d),
    light: ColorFamily(
      color: Color(0xff23231c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff44443b),
      onColorContainer: Color(0xffdddbcf),
    ),
    dark: ColorFamily(
      color: Color(0xffc9c7bb),
      onColor: Color(0xff313129),
      colorContainer: Color(0xff2c2c24),
      onColorContainer: Color(0xffbab8ad),
    ),
  );

  ///Color used in the login FilledButton background
  static const darkFilledButton = ExtendedColor(
      seed: Color(0xffc2cd7c),
      value: Color(0xffc2cd7c),
      light: ColorFamily(
        color: Color(0xff5a631f),
        onColor: Color(0xffffffff),
        colorContainer: Color(0xffcad583),
        onColorContainer: Color(0xff373f00),
      ),
      dark: ColorFamily(
        color: Color(0xffe7f29d),
        onColor: Color(0xff2d3400),
        colorContainer: Color(0xffbdc777),
        onColorContainer: Color(0xff2f3600),
      ));

  ///[onPrimaryFixedVariant] color for general use
  static const fixedPrimary = ExtendedColor(
    seed: Color(0xff404942),
    value: Color(0xff404942),
    light: ColorFamily(
      color: Color(0xff2d3630),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff4f5951),
      onColorContainer: Color(0xfff4fef4),
    ),
    dark: ColorFamily(
      color: Color(0xffbfc9c0),
      onColor: Color(0xff2a322c),
      colorContainer: Color(0xff373f39),
      onColorContainer: Color(0xffcad3ca),
    ),
  );

  List<ExtendedColor> get extendedColors => [
        darkTextField,
        darkFilledButton,
        fixedPrimary,
      ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily dark;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.dark,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
