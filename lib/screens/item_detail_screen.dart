import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/item_status.dart';
import '../models/vault_item.dart';
import '../models/vault_transaction.dart';
import '../repositories/item_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/aggregation_service.dart';
import '../theme/app_colors.dart';
import '../utils/confirm_dialog.dart';
import '../utils/format.dart';
import '../utils/item_image_ref.dart';
import '../widgets/item_cover_image.dart';
import 'add_item_screen.dart';
import 'edit_transaction_sheet.dart';
import 'quick_add_sheet.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.item});

  final VaultItem item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late VaultItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ItemRepository>().getItem(widget.item.id).then((updated) {
      if (updated != null && mounted) setState(() => _item = updated);
    });
  }

  Future<void> _onPurchase() async {
    final txRepo = context.read<TransactionRepository>();
    final itemRepo = context.read<ItemRepository>();
    final amount = await txRepo.getCurrentAmount(_item.id);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    bool? confirmed;
    if (amount >= _item.targetAmount) {
      confirmed = await showAppConfirmDialog(
        context,
        title: l10n.detailPurchaseTitle,
        content: Text(l10n.detailPurchaseConfirm),
        confirmLabel: l10n.detailPurchaseDone,
        confirmColor: AppColors.success,
      );
    } else {
      confirmed = await showAppConfirmDialog(
        context,
        title: l10n.detailBuyOnCreditTitle,
        content: Text(
          l10n.detailBuyOnCreditConfirm(
            formatCurrencyByCode(_item.targetAmount - amount, _item.currency),
          ),
        ),
        confirmLabel: l10n.detailBuyOnCreditConfirmLabel,
        confirmColor: AppColors.warning,
      );
    }
    if (confirmed != true || !mounted) return;

    if (amount >= _item.targetAmount) {
      await itemRepo.updateItemStatus(_item.id, ItemStatus.completed);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.detailPurchasedSnack),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      final diff = _item.targetAmount - amount;
      await txRepo.addTransaction(
        itemId: _item.id,
        amount: -_item.targetAmount,
        date: DateTime.now(),
      );
      await itemRepo.updateItemStatus(_item.id, ItemStatus.repaying);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.detailOnCreditSnack(
                formatCurrencyByCode(diff, _item.currency),
              ),
            ),
            backgroundColor: AppColors.warning,
          ),
        );
        setState(() {});
      }
    }
  }

  Future<void> _onDeleteItem() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.deleteItemTitle,
      content: Text(l10n.deleteItemConfirm(_item.title)),
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    await context.read<ItemRepository>().deleteItem(_item.id);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.itemDeleted)));
  }

  /// ホームの主役カードに固定する / 解除する。固定は最大1件。
  Future<void> _onTogglePinned() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final next = !_item.isPinned;
    await context.read<ItemRepository>().setPinned(_item.id, next);
    if (!mounted) return;
    setState(() => _item = _item.copyWith(isPinned: next));
    messenger.showSnackBar(
      SnackBar(content: Text(next ? l10n.pinnedToHome : l10n.unpinnedFromHome)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_item.title),
        actions: [
          IconButton(
            onPressed: _onTogglePinned,
            tooltip: l10n.pinToHome,
            isSelected: _item.isPinned,
            icon: const Icon(Icons.push_pin_outlined),
            selectedIcon: const Icon(
              Icons.push_pin,
              color: AppColors.primaryOutline,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddItemScreen(editItem: _item)),
            ).then((_) => setState(() {})),
            tooltip: l10n.editItem,
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') _onDeleteItem();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.deleteThisItem,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<double>(
        future: context.read<TransactionRepository>().getCurrentAmount(
          _item.id,
        ),
        builder: (context, amountSnapshot) {
          final isLoading =
              amountSnapshot.connectionState == ConnectionState.waiting;
          final amount = amountSnapshot.data ?? 0;
          final progress = _item.targetAmount > 0
              ? (amount / _item.targetAmount).clamp(0.0, 1.0)
              : 0.0;
          final isRepaying = _item.status == ItemStatus.repaying || amount < 0;
          final canPurchase = _item.status == ItemStatus.saving && amount > 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (itemImageRefIsDisplayable(_item.imagePath))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 240,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ItemCoverImage(
                            imageRef: _item.imagePath!,
                            fit: BoxFit.cover,
                            color: Color.fromRGBO(
                              255,
                              255,
                              255,
                              isLoading
                                  ? 0.5
                                  : (isRepaying ? 0.5 : (0.5 + progress * 0.5)),
                            ),
                            colorBlendMode: BlendMode.saturation,
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.scrim.withValues(alpha: 0.25),
                                  AppColors.scrim.withValues(alpha: 0.82),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    height: 160,
                    decoration: AppColors.elevatedCard(radius: 24),
                    child: Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 24),
                if (isLoading) ...[
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 140,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                      const Positioned(
                        left: 0,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatCurrencyByCode(amount, _item.currency),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Manrope',
                              color: isRepaying
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '/ ${formatCurrencyByCode(_item.targetAmount, _item.currency)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.surfaceHigh,
                      valueColor: AlwaysStoppedAnimation(
                        isRepaying ? AppColors.warning : AppColors.primary,
                      ),
                    ),
                  ),
                ],
                if (!isLoading && _item.targetDate != null) ...[
                  const SizedBox(height: 20),
                  _PredictionSection(item: _item, currentAmount: amount),
                ],
                if (!isLoading && canPurchase) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _onPurchase,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: Text(l10n.detailBuyAction),
                  ),
                ],
                if (!isLoading && isRepaying) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.detailRepayingHint,
                            style: TextStyle(
                              color: AppColors.onSurfaceAlpha(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.detailHistoryTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceAlpha(0.9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => showQuickAddSheet(
                        context,
                        _item,
                        onAdded: () => setState(() {}),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(l10n.detailRecord),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TransactionList(itemId: _item.id, currency: _item.currency),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PredictionSection extends StatelessWidget {
  const _PredictionSection({required this.item, required this.currentAmount});

  final VaultItem item;
  final double currentAmount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<VaultTransaction>>(
      stream: context.read<TransactionRepository>().watchByItem(item.id),
      builder: (context, txSnapshot) {
        final txs = txSnapshot.data ?? [];
        final deposits = txs
            .where((t) => t.amount > 0)
            .map((t) => (date: t.date, amount: t.amount))
            .toList();
        final predicted = AggregationService.computePredictedDate(
          currentAmount: currentAmount,
          targetAmount: item.targetAmount,
          deposits: deposits,
          now: DateTime.now(),
        );
        final targetDate = item.targetDate!;
        final isLate = predicted != null && predicted.isAfter(targetDate);
        final dateFormat = DateFormat('M/d');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      l10n.detailTargetDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      dateFormat.format(targetDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              if (predicted != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.detailPredictedDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLate) ...[
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            dateFormat.format(predicted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: isLate
                                  ? AppColors.warning
                                  : AppColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isLate) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.detailDaysLate(
                      predicted.difference(targetDate).inDays,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.itemId, required this.currency});

  final String itemId;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<VaultTransaction>>(
      stream: context.read<TransactionRepository>().watchByItem(itemId),
      builder: (context, snapshot) {
        final txs = snapshot.data ?? [];
        if (txs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: AppColors.elevatedCard(radius: 16),
            child: Center(
              child: Text(
                l10n.detailNoTransactions,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }
        return Column(
          children: txs
              .map((t) => _TransactionTile(transaction: t, currency: currency))
              .toList(),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.currency});

  final VaultTransaction transaction;

  final String currency;

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.amount > 0;
    final dateFormat = DateFormat('M/d HH:mm');

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: AppColors.onSurface),
      ),
      confirmDismiss: (_) async {
        final result = await showAppConfirmDialog(
          context,
          title: '削除',
          content: Text(AppLocalizations.of(context)!.deleteTransactionConfirm),
          confirmLabel: '削除',
          isDestructive: true,
        );
        return result == true;
      },
      onDismissed: (_) => context
          .read<TransactionRepository>()
          .deleteTransaction(transaction.id),
      child: InkWell(
        onTap: () {
          // モーダルは Navigator 直下に作られるため、Provider を明示的に渡す。
          final repo = context.read<TransactionRepository>();
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => InheritedTheme.captureAll(
              context,
              Provider<TransactionRepository>.value(
                value: repo,
                child: EditTransactionSheet(
                  transaction: transaction,
                  currency: currency,
                  onSaved: () {},
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: AppColors.elevatedCard(radius: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(transaction.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (transaction.note != null &&
                        transaction.note!.isNotEmpty)
                      Text(
                        transaction.note!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${isDeposit ? '+' : ''}${formatCurrencyByCode(transaction.amount, currency)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDeposit ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
