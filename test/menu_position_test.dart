import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:target_vault/theme/app_theme.dart';
import 'package:target_vault/utils/confirm_dialog.dart';

void main() {
  testWidgets('メニューは画面内に収まり、… の近くに開く', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('カメラ'),
            actions: [
              AppMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                onSelected: (_) {},
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

    final button = tester.getRect(find.byIcon(Icons.more_horiz));
    final item = tester.getRect(find.text('アーカイブ'));

    // 画面からはみ出さない
    expect(item.left, greaterThanOrEqualTo(0));
    expect(item.right, lessThanOrEqualTo(390));

    // ボタンの下に、近く開く
    expect(item.top, greaterThan(button.bottom));
    expect(item.top - button.bottom, lessThan(60));

    // 右寄せ（画面の右半分にある）
    expect(item.right, greaterThan(195));
  });
}
