import 'package:flutter/material.dart';

/// Palette Cinemax : fond noir, rouge d'accent, or pour les notes.
class AppColors {
  AppColors._();

  // Identité
  static const Color primary = Color(0xFFE5383B);
  static const Color primaryDeep = Color(0xFFB21E35);
  static const Color gold = Color(0xFFF5C518);

  // Notes
  static const Color ratingHigh = Color(0xFF21D07A);
  static const Color ratingMid = Color(0xFFF5C518);
  static const Color ratingLow = Color(0xFFDB2360);

  // Variante sombre (par défaut)
  static const Color darkBackground = Color(0xFF0B0B10);
  static const Color darkSurface = Color(0xFF16161E);
  static const Color darkSurfaceHigh = Color(0xFF23232E);
  static const Color darkText = Color(0xFFF4F4F7);
  static const Color darkTextMuted = Color(0xFFA1A1B3);

  // Variante claire
  static const Color lightBackground = Color(0xFFF7F5F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceHigh = Color(0xFFEDE9E4);
  static const Color lightText = Color(0xFF15151C);
  static const Color lightTextMuted = Color(0xFF5E5E6E);

  static Color forRating(double rating) => rating >= 7
      ? ratingHigh
      : rating >= 5
          ? ratingMid
          : ratingLow;
}

/// Couleurs propres à l'application, accessibles via `Theme.of(context).extension<CinemaxColors>()`.
@immutable
class CinemaxColors extends ThemeExtension<CinemaxColors> {
  const CinemaxColors({
    required this.textMuted,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.posterShadow,
  });

  final Color textMuted;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color posterShadow;

  static const dark = CinemaxColors(
    textMuted: AppColors.darkTextMuted,
    skeletonBase: Color(0xFF1C1C25),
    skeletonHighlight: Color(0xFF2C2C38),
    posterShadow: Color(0xCC000000),
  );

  static const light = CinemaxColors(
    textMuted: AppColors.lightTextMuted,
    skeletonBase: Color(0xFFE6E2DC),
    skeletonHighlight: Color(0xFFF4F1EC),
    posterShadow: Color(0x40000000),
  );

  static CinemaxColors of(BuildContext context) =>
      Theme.of(context).extension<CinemaxColors>() ?? dark;

  @override
  CinemaxColors copyWith({
    Color? textMuted,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? posterShadow,
  }) =>
      CinemaxColors(
        textMuted: textMuted ?? this.textMuted,
        skeletonBase: skeletonBase ?? this.skeletonBase,
        skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
        posterShadow: posterShadow ?? this.posterShadow,
      );

  @override
  CinemaxColors lerp(CinemaxColors? other, double t) {
    if (other == null) return this;
    return CinemaxColors(
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
      posterShadow: Color.lerp(posterShadow, other.posterShadow, t)!,
    );
  }
}
