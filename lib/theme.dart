import 'package:flutter/material.dart';

/// Canonical visual preset for this app.
/// Preset name: 'WARM_EARTHY' — one of the 10 canonical presets (rule 11b).
/// Only the accent hexes are overridden to the lavender / dusty-rose / sage brief.
class AppPalette {
  const AppPalette._();

  static const String presetName = 'WARM_EARTHY';

  static const Color background = Color(0xFFF8F4FA);
  static const Color backgroundAlt = Color(0xFFEFE7F2);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFF7A5C9E);
  static const Color primaryLight = Color(0xFF9A78BE);
  static const Color secondary = Color(0xFFE08DAC);
  static const Color tertiary = Color(0xFF9BC1BC);

  static const Color textPrimary = Color(0xFF293241);
  static const Color textSecondary = Color(0xFF6E6474);
  static const Color textMuted = Color(0xFF8E7C9B);

  static const Color hairline = Color(0x1A293241);

  static const Color loaderTop = Color(0xFF241832);
  static const Color loaderMid = Color(0xFF3B2A4E);
  static const Color loaderBottom = Color(0xFF1A1022);
  static const Color loaderText = Color(0xFFF6EFF8);
  static const Color loaderSubText = Color(0xFFC9B6D8);
  static const Color loaderCaption = Color(0xFF9B86AE);

  static const Color danger = Color(0xFFC4607F);
}

const List<FontFeature> kTabularFigures = <FontFeature>[
  FontFeature.tabularFigures(),
];

ThemeData buildAppTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: AppPalette.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppPalette.primary,
    secondary: AppPalette.secondary,
    tertiary: AppPalette.tertiary,
    surface: AppPalette.surface,
    onSurface: AppPalette.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppPalette.background,
    splashFactory: InkRipple.splashFactory,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.0,
        height: 1.05,
        color: AppPalette.textPrimary,
        fontFeatures: kTabularFigures,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w300,
        letterSpacing: 4.0,
        color: AppPalette.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.4,
        color: AppPalette.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: AppPalette.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: AppPalette.textMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        height: 24 / 16,
        color: Colors.white,
      ),
    ),
  );
}
