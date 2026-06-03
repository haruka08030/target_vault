import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
      confirmColor ?? (isDestructive ? AppColors.error : AppColors.primary);
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        title,
        style: TextStyle(color: AppColors.onSurfaceAlpha(0.95)),
      ),
      content: DefaultTextStyle(
        style: TextStyle(color: AppColors.onSurfaceAlpha(0.7)),
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
