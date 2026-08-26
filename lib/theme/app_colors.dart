import 'package:flutter/material.dart';

/// アプリ全体で使う色の定義。ハードコードせずここを参照する。
///
/// 「欲しいものへの貯金箱」のトーンに合わせたライトテーマ。
/// クリーム地 + アンバーのアクセント + 主役カードのみダーク。
///
/// コントラスト比は WCAG AA（本文 4.5:1 / 大見出し 3:1）を満たすこと。
/// 検証値は各定数のコメントに記載。
abstract final class AppColors {
  // --- 地と面 ---
  /// アプリの地。ほんのり温かいクリーム。
  static const Color background = Color(0xFFFBF3E0);

  /// カード・シートの面。地よりわずかに明るい。
  static const Color surface = Color(0xFFFFFDF8);

  /// 一段沈んだ面（入力欄・チップの背景）。
  static const Color surfaceLow = Color(0xFFF4EBD7);

  /// 一段持ち上げた面（選択中のチップなど）。
  static const Color surfaceHigh = Color(0xFFF0E4CA);

  /// 最も持ち上げた面（SnackBar など）。
  static const Color surfaceHighest = Color(0xFF2B2621);

  // --- 主役カード（ダーク） ---
  /// 主役カードの地。添付デザインのダークカード。
  static const Color heroSurface = Color(0xFF2B2621);

  /// 主役カード上の文字。heroSurface 上でのコントラスト 13.92:1。
  static const Color onHero = Color(0xFFFCF6EA);

  /// 主役カード上の弱い文字。heroSurface 上でのコントラスト 7.59:1。
  static const Color onHeroMuted = Color(0xFFC3B7A6);

  // --- アクセント ---
  /// CTA・進捗バーのアンバー。地との差は 1.47:1 しかないため、
  /// 面として使うときは primaryOutline の縁を必ず添える。
  /// 上に乗せる文字は必ず onPrimary（濃色）。
  static const Color primary = Color(0xFFF5C451);

  /// アンバー上の文字。primary 上でのコントラスト 9.20:1。
  static const Color onPrimary = Color(0xFF2B2621);

  /// アンバーの淡いバリエーション（進捗の残り・選択の下地）。
  static const Color primaryLight = Color(0xFFFAE3AC);

  /// 補助アクセント（達成・完了）。
  static const Color secondary = Color(0xFF3F7D5C);

  /// 完了・達成。background 上でのコントラスト 5.71:1。
  static const Color success = Color(0xFF2F6B4B);

  /// 注意・埋め戻し中。background 上でのコントラスト 4.60:1。
  static const Color warning = Color(0xFF9A6212);

  /// エラー。background 上でのコントラスト 5.91:1。
  static const Color error = Color(0xFFB3261E);

  /// エラーの淡い下地。
  static const Color errorLight = Color(0xFFF9DEDC);

  /// エラー面の上の文字。error 上でのコントラスト 7.1:1。
  static const Color onError = Color(0xFFFFFFFF);

  // --- 文字・境界 ---
  /// 本文。background 上でのコントラスト 13.55:1。
  static const Color onBackground = Color(0xFF2B2621);

  /// 面の上の本文。
  static const Color onSurface = Color(0xFF2B2621);

  /// 弱い文字（ラベル・補足）。background 上 5.47:1 / surfaceLow 上 5.10:1。
  static const Color onSurfaceVariant = Color(0xFF6B6157);

  /// 境界線（明示的な区切り）。background 上でのコントラスト 3.40:1（AA 図形）。
  static const Color outline = Color(0xFF8E8274);

  /// アンバー面の輪郭。primary 単体では地との差が 1.47:1 しかないため、
  /// CTA には必ずこの縁を添えて境界を判別可能にする。background 上 3.39:1。
  static const Color primaryOutline = Color(0xFFA87D14);

  /// 弱い境界線（カードの縁）。
  static const Color outlineVariant = Color(0xFFE2D6BF);

  /// 写真の上に敷くスクリム。白文字の可読性を確保する。
  static const Color scrim = Color(0xFF1F1A16);

  /// 写真の上に乗せる文字（スクリム前提）。
  static const Color onScrim = Color(0xFFFFFFFF);

  /// 本文色の不透明度バリエーション。
  ///
  /// 可読性を保つため、文字に使う場合は alpha >= 0.7 を目安にする。
  static Color onSurfaceAlpha(double alpha) =>
      onSurface.withValues(alpha: alpha);

  /// 主役カード上の文字の不透明度バリエーション。
  static Color onHeroAlpha(double alpha) => onHero.withValues(alpha: alpha);

  /// 通常のカード。影は使わず、細い縁で面を区切る。
  static BoxDecoration elevatedCard({double radius = 24}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: outlineVariant),
  );

  /// 主役カード。唯一のダーク面。
  static BoxDecoration heroCard({double radius = 28}) => BoxDecoration(
    color: heroSurface,
    borderRadius: BorderRadius.circular(radius),
  );

  /// タイル（貯金箱グリッドの1枚）。
  static BoxDecoration tileCard({double radius = 24}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: outlineVariant),
  );
}
