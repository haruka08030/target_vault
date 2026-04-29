import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../database/settings_store.dart';
import '../repositories/item_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/aggregation_service.dart';
import '../services/exchange_rate_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'add_item_screen.dart';
import 'completed_items_screen.dart';
import 'item_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// カテゴリフィルタ: null=すべて, ''=未設定, それ以外=カテゴリ名
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshRates();
    });
  }

  Future<void> _refreshRates() async {
    final settings = context.read<SettingsStore>();
    final exchange = context.read<ExchangeRateService>();
    final base = await settings.getBaseCurrency();
    final rates = await exchange.fetchRates(base);
    if (!mounted) return;
    if (rates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('為替レートの取得に失敗しました'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: Container(
          height: 64,
          decoration: AppColors.glassCard(radius: 999),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const _BottomNavIcon(
                icon: Icons.account_balance_wallet,
                active: true,
              ),
              _BottomNavIcon(
                icon: Icons.payments_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddItemScreen()),
                ),
              ),
              _BottomNavIcon(
                icon: Icons.receipt_long_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompletedItemsScreen(),
                  ),
                ),
              ),
              _BottomNavIcon(
                icon: Icons.person_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.surfaceHighest,
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: AppColors.onSurfaceAlpha(0.75),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'TARGET VAULT',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                      icon: Icon(
                        Icons.settings,
                        color: AppColors.onSurfaceAlpha(0.9),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _NetWorthHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Goals',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceAlpha(0.9),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddItemScreen(),
                        ),
                      ),
                      icon: Icon(
                        Icons.add,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                      label: Text(
                        'Add',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<List<Item>>(
              stream: context.read<ItemRepository>().watchAllItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }
                final all = snapshot.data!;
                final items = all
                    .where((i) => i.status != ItemStatus.completed)
                    .toList();
                final completed = all
                    .where((i) => i.status == ItemStatus.completed)
                    .toList();
                final showCompletedLink = completed.isNotEmpty;

                final categorySet = items.map((i) => i.category).toSet();
                final nonNullCategories =
                    categorySet.whereType<String>().toList()..sort();
                final filterOptions = <String?>[
                  null,
                  if (categorySet.contains(null)) '',
                  ...nonNullCategories,
                ];
                final filteredItems = _selectedCategoryFilter == null
                    ? items
                    : _selectedCategoryFilter == ''
                    ? items.where((i) => i.category == null).toList()
                    : items
                          .where((i) => i.category == _selectedCategoryFilter)
                          .toList();

                if (items.isEmpty && !showCompletedLink) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.savings_outlined,
                              size: 64,
                              color: AppColors.onSurfaceAlpha(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'アイテムを追加して貯金を始めましょう',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.onSurfaceAlpha(0.5),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddItemScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('アイテムを追加'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: const Text('すべて'),
                                    selected: _selectedCategoryFilter == null,
                                    onSelected: (_) => setState(
                                      () => _selectedCategoryFilter = null,
                                    ),
                                    selectedColor: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    backgroundColor: AppColors.surfaceLow,
                                    side: BorderSide(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                    checkmarkColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: _selectedCategoryFilter == null
                                          ? AppColors.onSurfaceAlpha(1)
                                          : AppColors.onSurfaceAlpha(0.8),
                                    ),
                                  ),
                                ),
                                ...filterOptions.where((v) => v != null).map((
                                  cat,
                                ) {
                                  final label = cat == '' ? '未設定' : cat!;
                                  final selected =
                                      _selectedCategoryFilter == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(label),
                                      selected: selected,
                                      onSelected: (_) => setState(
                                        () => _selectedCategoryFilter = cat,
                                      ),
                                      selectedColor: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      backgroundColor: AppColors.surfaceLow,
                                      side: BorderSide(
                                        color: AppColors.outlineVariant
                                            .withValues(alpha: 0.5),
                                      ),
                                      checkmarkColor: AppColors.primary,
                                      labelStyle: TextStyle(
                                        color: selected
                                            ? AppColors.onSurfaceAlpha(1)
                                            : AppColors.onSurfaceAlpha(0.8),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildItemListSliver(
                        filteredItems: filteredItems,
                        showCompletedLink: showCompletedLink,
                        completedCount: completed.length,
                        isReorderable: _selectedCategoryFilter == null,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemListSliver({
    required List<Item> filteredItems,
    required bool showCompletedLink,
    required int completedCount,
    required bool isReorderable,
  }) {
    final completedLink = showCompletedLink
        ? SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompletedItemsScreen(),
                  ),
                ),
                icon: Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: AppColors.onSurfaceAlpha(0.7),
                ),
                label: Text(
                  '完了したアイテム（$completedCount）を見る',
                  style: TextStyle(
                    color: AppColors.onSurfaceAlpha(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )
        : null;

    if (isReorderable && filteredItems.isNotEmpty) {
      return SliverMainAxisGroup(
        slivers: [
          SliverReorderableList(
            itemCount: filteredItems.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) newIndex--;
              final newOrder = List<Item>.from(filteredItems);
              final item = newOrder.removeAt(oldIndex);
              newOrder.insert(newIndex, item);
              context.read<ItemRepository>().updateItemsOrder(
                newOrder.map((i) => i.id).toList(),
              );
            },
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return ReorderableDragStartListener(
                index: index,
                key: ValueKey(item.id),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Stack(
                    children: [
                      _ItemCard(item: item),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Icon(
                            Icons.drag_indicator,
                            size: 16,
                            color: AppColors.onSurfaceAlpha(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ?completedLink,
        ],
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index < filteredItems.length) {
              return _ItemCard(item: filteredItems[index]);
            }
            return const SizedBox.shrink();
          }, childCount: filteredItems.length),
        ),
        ?completedLink,
      ],
    );
  }
}

class _NetWorthHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: context.read<ItemRepository>().watchAllItems(),
      builder: (context, itemsSnapshot) {
        if (!itemsSnapshot.hasData) {
          return SizedBox(
            height: 160,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        return FutureBuilder<({String baseCurrency, AggregationResult result})>(
          future: _loadData(context, itemsSnapshot.data!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _NetWorthSkeleton(
                isLoading: snapshot.connectionState == ConnectionState.waiting,
              );
            }
            final base = snapshot.data!.baseCurrency;
            final r = snapshot.data!.result;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: AppColors.glassCard(radius: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Available Net Worth',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrencyByCode(r.netWorth, base),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SubStat(
                        label: 'Total Savings',
                        value: formatCurrencyByCode(r.totalSavings, base),
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 24),
                      _SubStat(
                        label: 'Total Debt',
                        value: formatCurrencyByCode(r.totalDebt, base),
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<({String baseCurrency, AggregationResult result})> _loadData(
    BuildContext context,
    List<Item> items,
  ) async {
    final settings = context.read<SettingsStore>();
    final agg = context.read<AggregationService>();
    final exchange = context.read<ExchangeRateService>();
    final base = await settings.getBaseCurrency();
    final result = await agg.computeWithBaseCurrency(items, base, exchange);
    return (baseCurrency: base, result: result);
  }
}

/// 純資産ヘッダー用のスケルトン（金額取得中）
class _NetWorthSkeleton extends StatelessWidget {
  const _NetWorthSkeleton({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.onSurfaceAlpha(0.06)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceAlpha(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 160,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceAlpha(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.onSurfaceAlpha(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    width: 56,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.onSurfaceAlpha(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isLoading)
            Positioned(
              top: 0,
              right: 0,
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
    );
  }
}

class _SubStat extends StatelessWidget {
  const _SubStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, color: color, letterSpacing: 0.8),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  const _BottomNavIcon({required this.icon, this.active = false, this.onTap});

  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = active
        ? Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: AppColors.primaryTextOnLight, size: 20),
          )
        : Icon(icon, color: AppColors.onSurfaceAlpha(0.65), size: 22);

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(padding: const EdgeInsets.all(6), child: child),
      ),
    );
  }
}

/// アイテムカード用のスケルトン（金額取得中）
class _ItemCardSkeleton extends StatelessWidget {
  const _ItemCardSkeleton({required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.onSurfaceAlpha(0.06),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.onSurfaceAlpha(0.08),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceAlpha(1),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.onSurfaceAlpha(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 72,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.onSurfaceAlpha(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.chevron_right,
                        color: AppColors.onSurfaceAlpha(0.4),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: context.read<TransactionRepository>().getCurrentAmount(item.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _ItemCardSkeleton(
            item: item,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
            ),
          );
        }
        final amount = snapshot.data ?? 0;
        final progress = item.targetAmount > 0
            ? (amount / item.targetAmount).clamp(0.0, 1.0)
            : 0.0;
        final isRepaying = item.status == ItemStatus.repaying || amount < 0;
        final saturation = isRepaying ? 0.4 : (0.5 + progress * 0.5);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
              ),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 220,
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.imagePath != null &&
                          File(item.imagePath!).existsSync())
                        Image.file(
                          File(item.imagePath!),
                          fit: BoxFit.cover,
                          color: Color.fromRGBO(
                            255,
                            255,
                            255,
                            saturation.toDouble(),
                          ),
                          colorBlendMode: BlendMode.saturation,
                        )
                      else
                        Container(color: AppColors.surfaceHigh),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.22),
                              Colors.black.withValues(alpha: 0.86),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${formatCurrencyByCode(amount, item.currency)} / ${formatCurrencyByCode(item.targetAmount, item.currency)}',
                              style: TextStyle(
                                color: AppColors.onSurfaceAlpha(0.95),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                valueColor: AlwaysStoppedAnimation(
                                  isRepaying
                                      ? AppColors.warning
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
