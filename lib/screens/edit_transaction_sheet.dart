import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/vault_transaction.dart';
import '../repositories/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../utils/thousands_separator_input_formatter.dart';

class EditTransactionSheet extends StatefulWidget {
  const EditTransactionSheet({
    super.key,
    required this.transaction,
    required this.currency,
    required this.onSaved,
  });

  final VaultTransaction transaction;
  final String currency;
  final VoidCallback onSaved;

  @override
  State<EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<EditTransactionSheet> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _date;
  late bool _isWithdrawal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController = TextEditingController(
      text: t.amount.abs().toStringAsFixed(
        t.amount == t.amount.roundToDouble() ? 0 : 2,
      ),
    );
    _noteController = TextEditingController(text: t.note ?? '');
    _date = t.date;
    _isWithdrawal = t.amount < 0;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final combined = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      );
      setState(() => _date = combined);
    }
  }

  Future<void> _save() async {
    final text = _amountController.text.trim().replaceAll(',', '');
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
    final note = _noteController.text.trim();

    setState(() => _isLoading = true);
    await context.read<TransactionRepository>().updateTransaction(
      widget.transaction.id,
      amount: amount,
      date: _date,
      note: note.isEmpty ? null : note,
    );
    widget.onSaved();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M/d (E)', 'ja');
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          Text(
            '入出金を編集',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
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
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ThousandsSeparatorInputFormatter(
                decimalAllowed: widget.currency != 'JPY',
              ),
            ],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
              suffixText: _currencySuffix(widget.currency),
              suffixStyle: TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _isLoading ? null : _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppColors.onSurfaceAlpha(0.7),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    dateFormat.format(_date),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onSurfaceAlpha(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'メモ（任意）',
              hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
            onPressed: _isLoading ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: _isWithdrawal
                  ? AppColors.warning
                  : AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                : const Text('保存'),
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
