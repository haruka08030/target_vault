import 'package:flutter/material.dart';

/// アプリ共通のダークテーマ確認ダイアログ。
/// 重要な操作・破壊的操作の前に必ずこれを使い、画面ごとに AlertDialog をコピペしない。
Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  required String confirmLabel,
  String cancelLabel = 'キャンセル',
  bool isDestructive = false,
  Color? confirmColor,
}) async {
  final color =
      confirmColor ??
      (isDestructive ? const Color(0xFFEF4444) : const Color(0xFF6366F1));
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(
        title,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.95)),
      ),
      content: DefaultTextStyle(
        style: const TextStyle(color: Colors.white70),
        child: content,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: color),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
