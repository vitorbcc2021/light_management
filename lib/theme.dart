import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LightManagementTheme {
  static const bg = Color(0xFF0E0E10);
  static const surface = Color(0xFF1A1A1F);
  static const surfaceHigh = Color(0xFF242429);
  static const border = Color(0xFF2E2E35);
  static const amber = Color(0xFFFFB340);
  static const amberDim = Color(0xFF3D2A00);
  static const amberGlow = Color(0x33FFB340);
  static const textPrimary = Color(0xFFF0EDE8);
  static const textSecondary = Color(0xFF8A8880);
  static const textTertiary = Color(0xFF4A4A52);
  static const success = Color(0xFF3DD68C);
  static const error = Color(0xFFFF5C5C);
  static const warn = Color(0xFFFFB340);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: amber,
      surface: surface,
      error: error,
    ),
    fontFamily: 'sans-serif',
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      bodySmall: TextStyle(color: textTertiary, fontSize: 12),
    ),
    dividerColor: border,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
    ),
  );
}
