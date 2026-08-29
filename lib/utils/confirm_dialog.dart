import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ダイアログ・メニューのアクション文字色。白地で 13.4:1。
///
/// テーマの primary（アンバー）は白地で 1.45:1 しかなく、押せないボタンに
/// 見えるため継がせない。
const Color _actionColor = Color(0xFF2B2621);

/// 破壊的な操作の色。白地で 4.6:1。
const Color _destructiveColor = Color(0xFFD32F2F);

/// メニューの地。iOS のプルダウンに近い、ごく淡い面。
const Color _menuSurface = Color(0xFFFBF9F4);

/// メニューの幅。右端をそろえる計算に使うため固定する。
const double _menuWidth = 232;

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

/// ボタンの近くに出す選択肢メニュー（iOS のプルダウンメニュー）。
///
/// 下から出すアクションシートではなく、押したボタンの直下に開く。
/// 「その他」の中身のように、どこから来たかが分かるほうが良い操作に使う。
///
/// Flutter 3.41 に CupertinoMenuAnchor は無いため、[MenuAnchor] を
/// iOS の見た目（角丸・淡い地・破壊的操作は赤字）に寄せて使う。
class AppMenuButton<T> extends StatelessWidget {
  const AppMenuButton({
    super.key,
    required this.icon,
    required this.actions,
    required this.onSelected,
    this.tooltip,
  });

  final Widget icon;
  final List<AppSheetAction<T>> actions;
  final ValueChanged<T> onSelected;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      // ボタンの直下に、右端をそろえて開く。
      //
      // MenuAnchor は既定でアンカーの左端から右へ伸びるため、画面右上の
      // ボタンに付けると右にはみ出す。アンカーの左下を起点にし、メニューの
      // 幅ぶん左へ戻して右端をそろえる。
      alignmentOffset: const Offset(-_menuWidth + 44, 4),
      style: MenuStyle(
        alignment: Alignment.bottomLeft,
        maximumSize: const WidgetStatePropertyAll(
          Size(_menuWidth, double.infinity),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(_menuWidth, 0)),
        backgroundColor: const WidgetStatePropertyAll(_menuSurface),
        surfaceTintColor: const WidgetStatePropertyAll(Color(0x00000000)),
        elevation: const WidgetStatePropertyAll(8),
        shadowColor: WidgetStatePropertyAll(
          const Color(0xFF1F1A16).withValues(alpha: 0.18),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 6),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      builder: (context, controller, child) => IconButton(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        tooltip: tooltip,
        icon: icon,
      ),
      menuChildren: [
        for (final a in actions)
          MenuItemButton(
            onPressed: () => onSelected(a.value),
            trailingIcon: a.icon == null
                ? null
                : Icon(
                    a.icon,
                    size: 19,
                    color: a.isDestructive ? _destructiveColor : _actionColor,
                  ),
            style: MenuItemButton.styleFrom(
              foregroundColor: a.isDestructive
                  ? _destructiveColor
                  : _actionColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(_menuWidth, 44),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            child: Text(a.label),
          ),
      ],
    );
  }
}

/// [AppMenuButton] の選択肢1つ。
class AppSheetAction<T> {
  const AppSheetAction({
    required this.value,
    required this.label,
    this.isDestructive = false,
    this.icon,
  });

  final T value;
  final String label;
  final bool isDestructive;

  /// 行の右に置くアイコン。iOS のプルダウンメニューに倣う。
  final IconData? icon;
}
