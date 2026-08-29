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

  testWidgets('その他の操作はアクションシートで出す', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showAppActionSheet<String>(
                  context,
                  actions: const [
                    AppSheetAction(value: 'archive', label: 'アーカイブ'),
                    AppSheetAction(
                      value: 'delete',
                      label: 'この貯金箱を削除',
                      isDestructive: true,
                    ),
                  ],
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

    expect(find.byType(CupertinoActionSheet), findsOneWidget);
    expect(find.text('アーカイブ'), findsOneWidget);
    expect(find.text('この貯金箱を削除'), findsOneWidget);

    await expectLater(
      find.byType(CupertinoActionSheet),
      matchesGoldenFile('goldens/action_sheet.png'),
    );
  });
}
