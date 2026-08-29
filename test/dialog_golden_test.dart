import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:target_vault/theme/app_theme.dart';
import 'package:target_vault/utils/confirm_dialog.dart';

void main() {
  testWidgets('削除の確認は iOS 標準の見た目で出る', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showAppConfirmDialog(
                  context,
                  title: '貯金箱を削除',
                  content: const Text(
                    '「カメラ」を削除しますか？ 入出金の履歴も一緒に消えます。',
                  ),
                  confirmLabel: '削除',
                  isDestructive: true,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Material の AlertDialog ではなく Cupertino になっていること
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    // 取り消せること（G2）
    expect(find.text('キャンセル'), findsOneWidget);

    await expectLater(
      find.byType(CupertinoAlertDialog),
      matchesGoldenFile('goldens/confirm_dialog.png'),
    );
  });

  testWidgets('その他の操作は … の近くにメニューで出す', (tester) async {
    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          appBar: AppBar(
            actions: [
              AppMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                onSelected: (v) => picked = v,
                actions: const [
                  AppSheetAction(
                    value: 'archive',
                    label: 'アーカイブ',
                    icon: Icons.inventory_2_outlined,
                  ),
                  AppSheetAction(
                    value: 'delete',
                    label: 'この貯金箱を削除',
                    isDestructive: true,
                    icon: Icons.delete_outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    // 下から出るシートではなく、その場に開くメニュー
    expect(find.byType(CupertinoActionSheet), findsNothing);
    expect(find.text('アーカイブ'), findsOneWidget);
    expect(find.text('この貯金箱を削除'), findsOneWidget);

    // メニューはボタン（画面右上）の近くに開く
    final button = tester.getRect(find.byIcon(Icons.more_horiz));
    final menuItem = tester.getRect(find.text('アーカイブ'));
    expect(menuItem.top, greaterThan(button.top));
    expect(menuItem.top - button.bottom, lessThan(80));
    expect(menuItem.right, greaterThan(tester.getSize(find.byType(Scaffold)).width / 2));

    await tester.tap(find.text('アーカイブ'));
    await tester.pumpAndSettle();
    expect(picked, 'archive');
  });
}
