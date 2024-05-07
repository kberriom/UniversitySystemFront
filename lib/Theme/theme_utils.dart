import "package:flutter/material.dart";
import "package:university_system_front/Theme/theme.dart";

final class ThemeUtils {
  ///Utility method to get the correct color of a extended color declared in [extendedColors] given a [Brightness] value
  static Color extendedColorByBrightness(BuildContext context, ExtendedColor extendedColor) {
    if (MediaQuery.platformBrightnessOf(context) == Brightness.dark) {
      return extendedColor.dark.color;
    } else {
      return extendedColor.light.color;
    }
  }

  ///Utility method to switch colors given a [Brightness] value
  static Color colorByBrightness(BuildContext context, Color light, Color dark) {
    if (MediaQuery.platformBrightnessOf(context) == Brightness.dark) {
      return dark;
    } else {
      return light;
    }
  }
}
