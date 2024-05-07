import "package:flutter/material.dart";

class MaterialTheme {
  const MaterialTheme();

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff256a4a),
      surfaceTint: Color(0xff576159),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff4f5951),
      onPrimaryContainer: Color(0xfff4fef4),
      secondary: Color(0xff3a4e41),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5d7364),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff254f5c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4b7481),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff871815),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffb93d34),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfffcf9f7),
      onBackground: Color(0xff1b1c1b),
      surface: Color(0xfffcf9f7),
      onSurface: Color(0xff1b1c1b),
      surfaceVariant: Color(0xffe0e4de),
      onSurfaceVariant: Color(0xff434844),
      outline: Color(0xff747873),
      outlineVariant: Color(0xffc4c8c2),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303030),
      inverseOnSurface: Color(0xfff3f0ee),
      inversePrimary: Color(0xffbfc9c0),
      primaryFixed: Color(0xffdbe5db),
      onPrimaryFixed: Color(0xff151d18),
      primaryFixedDim: Color(0xffbfc9c0),
      onPrimaryFixedVariant: Color(0xff404942),
      secondaryFixed: Color(0xffd1e8d6),
      onSecondaryFixed: Color(0xff0c1f15),
      secondaryFixedDim: Color(0xffb5ccbb),
      onSecondaryFixedVariant: Color(0xff374b3e),
      tertiaryFixed: Color(0xffbfe9f9),
      onTertiaryFixed: Color(0xff001f27),
      tertiaryFixedDim: Color(0xffa3cddc),
      onTertiaryFixedVariant: Color(0xff224c59),
      surfaceDim: Color(0xffdcd9d8),
      surfaceBright: Color(0xfffcf9f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f1),
      surfaceContainer: Color(0xfff0edec),
      surfaceContainerHigh: Color(0xffeae8e6),
      surfaceContainerHighest: Color(0xffe4e2e0),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xff91d5ad),
      surfaceTint: Color(0xffbfc9c0),
      onPrimary: Color(0xff2a322c),
      primaryContainer: Color(0xff373f39),
      onPrimaryContainer: Color(0xffcad3ca),
      secondary: Color(0xffb5ccbb),
      onSecondary: Color(0xff213529),
      secondaryContainer: Color(0xff44594b),
      onSecondaryContainer: Color(0xffe5fdeb),
      tertiary: Color(0xffa3cddc),
      onTertiary: Color(0xff033541),
      tertiaryContainer: Color(0xff315a67),
      onTertiaryContainer: Color(0xffedfaff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690004),
      errorContainer: Color(0xffad342c),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xff131313),
      onBackground: Color(0xffe4e2e0),
      surface: Color(0xff131313),
      onSurface: Color(0xffe4e2e0),
      surfaceVariant: Color(0xff434844),
      onSurfaceVariant: Color(0xffc4c8c2),
      outline: Color(0xff8e928d),
      outlineVariant: Color(0xff434844),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e2e0),
      inverseOnSurface: Color(0xff303030),
      inversePrimary: Color(0xff576159),
      primaryFixed: Color(0xffdbe5db),
      onPrimaryFixed: Color(0xff151d18),
      primaryFixedDim: Color(0xffbfc9c0),
      onPrimaryFixedVariant: Color(0xff404942),
      secondaryFixed: Color(0xffd1e8d6),
      onSecondaryFixed: Color(0xff0c1f15),
      secondaryFixedDim: Color(0xffb5ccbb),
      onSecondaryFixedVariant: Color(0xff374b3e),
      tertiaryFixed: Color(0xffbfe9f9),
      onTertiaryFixed: Color(0xff001f27),
      tertiaryFixedDim: Color(0xffa3cddc),
      onTertiaryFixedVariant: Color(0xff224c59),
      surfaceDim: Color(0xff131313),
      surfaceBright: Color(0xff393938),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1b1c1b),
      surfaceContainer: Color(0xff1f201f),
      surfaceContainerHigh: Color(0xff2a2a29),
      surfaceContainerHighest: Color(0xff353534),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
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

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onPrimaryFixedVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
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
