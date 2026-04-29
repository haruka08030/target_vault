import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../repositories/item_repository.dart';
import '../repositories/transaction_repository.dart';

class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key, required this.item, required this.onAdded});

  final Item item;
  final VoidCallback onAdded;

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  bool _isWithdrawal = false; // false: 入金, true: 出金

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim().replaceAll(',', '');
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正しい金額を入力してください'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }
    final amount = _isWithdrawal ? -parsed : parsed;

    final txRepo = context.read<TransactionRepository>();
    final itemRepo = context.read<ItemRepository>();

    setState(() => _isLoading = true);
    await txRepo.addTransaction(itemId: widget.item.id, amount: amount);
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
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Colors.white.withValues(alpha: 0.3),
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
                        return const Color(0xFF6366F1).withValues(alpha: 0.3);
                      }
                      return Colors.white.withValues(alpha: 0.08);
                    }),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.item.title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              suffixText: _currencySuffix(widget.item.currency),
              suffixStyle: TextStyle(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: const Color(0xFF0D0D0D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _isWithdrawal
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF6366F1),
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
                      color: Colors.white,
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
