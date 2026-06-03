import 'package:flutter/material.dart';

/// アプリ全体で使う色の定義。ハードコードせずここを参照する。
abstract final class AppColors {
  // --- Design System base ---
  static const Color background = Color(0xFF131313);
  static const Color surface = Color(0xFF201F1F);
  static const Color surfaceLow = Color(0xFF1C1B1B);
  static const Color surfaceHigh = Color(0xFF2A2A2A);
  static const Color surfaceHighest = Color(0xFF353534);

  // --- Primary / Accent ---
  static const Color primary = Color(0xFFFFFFFF);
  static const Color primaryTextOnLight = Color(0xFF2F3131);
  static const Color primaryLight = Color(0xFFC6C6C7);
  static const Color secondary = Color(0xFF7DFFA2);
  static const Color success = Color(0xFF62FF96);
  static const Color warning = Color(0xFFFBBC00);
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorLight = Color(0xFFFFDAD6);

  // --- Text / Border ---
  static const Color onBackground = Color(0xFFE5E2E1);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFC4C7C8);
  static const Color outline = Color(0xFF8E9192);
  static const Color outlineVariant = Color(0xFF444748);

  // --- オンフォア（白）の不透明度バリエーション ---
  static Color onSurfaceAlpha(double alpha) =>
      onSurface.withValues(alpha: alpha);

  static BoxDecoration elevatedCard({double radius = 20}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
  );

  static BoxDecoration glassCard({double radius = 24}) => BoxDecoration(
    color: surface.withValues(alpha: 0.72),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 30,
        offset: const Offset(0, 14),
      ),
    ],
  );
}
