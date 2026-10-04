import 'package:flutter/material.dart';

/// Styles de texte de l'application.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color text, Color muted) => TextTheme(
        displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.1, color: text),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6, height: 1.15, color: text),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.2, color: text),
        titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: text),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: text),
        bodyLarge: TextStyle(fontSize: 16, height: 1.55, color: text),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: text),
        bodySmall: TextStyle(fontSize: 12.5, height: 1.4, color: muted),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: text),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.3, color: muted),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: muted),
      );
}
