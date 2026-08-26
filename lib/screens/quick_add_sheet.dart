import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/item_status.dart';
import '../l10n/app_localizations.dart';
import '../models/vault_item.dart';
import '../repositories/item_repository.dart';
import '../repositories/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../utils/thousands_separator_input_formatter.dart';

/// 入出金シートを開く。ホームと詳細で同じ出し方をするための入口。
///
/// モーダルは Navigator 直下に作られるため、そのままでは呼び出し元の
/// Provider に届かない。`InheritedTheme`/`Provider` を明示的に引き継ぐ。
Future<void> showQuickAddSheet(
  BuildContext context,
  VaultItem item, {
  VoidCallback? onAdded,
}) {
  final sheet = QuickAddSheet(item: item, onAdded: onAdded ?? () {});
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => InheritedTheme.captureAll(
      context,
      Provider<TransactionRepository>.value(
        value: context.read<TransactionRepository>(),
        child: Provider<ItemRepository>.value(
          value: context.read<ItemRepository>(),
          child: sheet,
        ),
      ),
    ),
  );
}

class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key, required this.item, required this.onAdded});

  final VaultItem item;
  final VoidCallback onAdded;

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _controller = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  bool _isWithdrawal = false; // false: 入金, true: 出金

  @override
  void dispose() {
    _controller.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim().replaceAll(',', '');
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidAmount),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    final amount = _isWithdrawal ? -parsed : parsed;

    final txRepo = context.read<TransactionRepository>();
    final itemRepo = context.read<ItemRepository>();

    final note = _noteController.text.trim();
    setState(() => _isLoading = true);
    await txRepo.addTransaction(
      itemId: widget.item.id,
      amount: amount,
      note: note.isEmpty ? null : note,
    );
    final newBalance = await txRepo.getCurrentAmount(widget.item.id);
    if (widget.item.status == ItemStatus.repaying && newBalance >= 0) {
      await itemRepo.updateItemStatus(widget.item.id, ItemStatus.completed);
    }
    widget.onAdded();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('入金'),
                      icon: Icon(Icons.add_circle_outline, size: 18),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('出金'),
                      icon: Icon(Icons.remove_circle_outline, size: 18),
                    ),
                  ],
                  selected: {_isWithdrawal},
                  onSelectionChanged: (Set<bool> selected) {
                    setState(() => _isWithdrawal = selected.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary.withValues(alpha: 0.3);
                      }
                      return AppColors.outlineVariant;
                    }),
                    foregroundColor: WidgetStateProperty.all(
                      AppColors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.item.title,
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ThousandsSeparatorInputFormatter(
                decimalAllowed: widget.item.currency != 'JPY',
              ),
            ],
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
              suffixText: _currencySuffix(widget.item.currency),
              suffixStyle: TextStyle(
                fontSize: 18,
                color: AppColors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: AppColors.surfaceLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'メモ（任意）',
              hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surfaceLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceAlpha(0.9),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _isWithdrawal
                  ? AppColors.warning
                  : AppColors.primary,
              foregroundColor: _isWithdrawal
                  ? AppColors.onPrimary
                  : AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(_isWithdrawal ? '出金する' : '入金する'),
          ),
        ],
      ),
    );
  }

  String _currencySuffix(String code) {
    const map = {'JPY': '円', 'USD': '\$', 'EUR': '€', 'GBP': '£'};
    return map[code] ?? code;
  }
}
