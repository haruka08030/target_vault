import 'package:flutter/cupertino.dart';

/// アプリ共通の確認ダイアログ。
///
/// 重要な操作・破壊的操作の前に必ずこれを使い、画面ごとに AlertDialog を
/// コピペしない。
///
/// iOS 標準の [CupertinoAlertDialog] を使う。Material の AlertDialog は
/// 左寄せタイトル + 塗りつぶしボタンで、iOS では明らかに異物に見えるため。
/// 破壊的な操作は赤字（[isDestructiveAction]）で示し、キャンセルを既定にする。
///
/// アクションの文字色はテーマの primary を継がせない。アンバーは白地の
/// ダイアログ上で 1.45:1 しかなく、押せないボタンに見えるため。
Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  required String confirmLabel,
  String cancelLabel = 'キャンセル',
  bool isDestructive = false,
}) async {
  return showCupertinoDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 13,
            height: 18 / 13,
            color: CupertinoColors.label,
          ),
          textAlign: TextAlign.center,
          child: content,
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, false),
          // 取り消しを既定にして、誤爆したときに戻れるようにする。
          isDefaultAction: true,
          textStyle: const TextStyle(color: _actionColor),
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, true),
          isDestructiveAction: isDestructive,
          textStyle: isDestructive
              ? null
              : const TextStyle(color: _actionColor),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// 下から出す選択肢シート（iOS の Action Sheet）。
///
/// 「アーカイブする / 削除する」のように、破壊度の違う操作を並べるときに使う。
/// ダイアログと違い、選択肢が3つ以上でも窮屈にならない。
/// ダイアログ・シートのアクション文字色。白地で 13.4:1。
const Color _actionColor = Color(0xFF2B2621);

Future<T?> showAppActionSheet<T>(
  BuildContext context, {
  String? title,
  String? message,
  required List<AppSheetAction<T>> actions,
  String cancelLabel = 'キャンセル',
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: title == null ? null : Text(title),
      message: message == null ? null : Text(message),
      actions: [
        for (final a in actions)
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, a.value),
            isDestructiveAction: a.isDestructive,
            child: DefaultTextStyle.merge(
              style: a.isDestructive
                  ? null
                  : const TextStyle(color: _actionColor),
              child: Text(a.label),
            ),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        isDefaultAction: true,
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: _actionColor),
          child: Text(cancelLabel),
        ),
      ),
    ),
  );
}

/// [showAppActionSheet] の選択肢1つ。
class AppSheetAction<T> {
  const AppSheetAction({
    required this.value,
    required this.label,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final bool isDestructive;
}
