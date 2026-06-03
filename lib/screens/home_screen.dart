import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_status.dart';
import '../models/vault_item.dart';
import '../database/settings_store.dart';
import '../repositories/item_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/aggregation_service.dart';
import '../services/exchange_rate_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../utils/item_image_ref.dart';
import '../widgets/item_cover_image.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _GoalsView { active, completed }

class _HomeScreenState extends State<HomeScreen> {
  _GoalsView _goalsView = _GoalsView.active;

  /// カテゴリフィルタ（進行中のみ）: null=すべて, ''=カテゴリなし, それ以外=カテゴリ名
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
          content: Text(AppLocalizations.of(context)!.exchangeRateFetchFailed),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemScreen()),
        ),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primaryTextOnLight,
        elevation: 6,
        highlightElevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                child: Text(
                  AppLocalizations.of(context)!.goalsSectionTitle,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceAlpha(0.9),
                  ),
                ),
              ),
            ),
            StreamBuilder<List<VaultItem>>(
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

                if (_goalsView == _GoalsView.completed) {
                  return _buildCompletedGoalsSliver(completed);
                }

                final categorySet = items.map((i) => i.category).toSet();
                final nonNullCategories =
                    categorySet.whereType<String>().toList()..sort();
                final categoryFilterOptions = <String>[
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

                if (items.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildGoalsFiltersArea(
                              categoryFilterOptions: const [],
                            ),
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
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
                                    AppLocalizations.of(
                                      context,
                                    )!.emptyGoalsPrompt,
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
                                    label: Text(
                                      AppLocalizations.of(context)!.addItem,
                                    ),
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
                        ),
                      ],
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
                          child: _buildGoalsFiltersArea(
                            categoryFilterOptions: categoryFilterOptions,
                          ),
                        ),
                      ),
                      _buildItemListSliver(
                        filteredItems: filteredItems,
                        isReorderable: _selectedCategoryFilter == null,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),
    );
  }

  static const double _goalsSegmentHeight = 44;

  /// 進行中/完了セグメント＋カテゴリ行。完了タブでも高さを揃える。
  Widget _buildGoalsFiltersArea({required List<String> categoryFilterOptions}) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _goalsSegmentHeight,
          child: SegmentedButton<_GoalsView>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _GoalsView.active,
                label: Text(l10n.goalsViewActive),
              ),
              ButtonSegment(
                value: _GoalsView.completed,
                label: Text(l10n.goalsViewCompleted),
              ),
            ],
            selected: {_goalsView},
            onSelectionChanged: (selected) {
              setState(() {
                _goalsView = selected.first;
                if (_goalsView == _GoalsView.completed) {
                  _selectedCategoryFilter = null;
                }
              });
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.secondary,
              selectedForegroundColor: AppColors.primaryTextOnLight,
              backgroundColor: AppColors.surfaceLow,
              foregroundColor: AppColors.onSurfaceAlpha(0.85),
              side: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              minimumSize: const Size(0, _goalsSegmentHeight),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.standard,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: categoryFilterOptions.isEmpty
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...categoryFilterOptions.map((cat) {
                          final label = cat.isEmpty ? l10n.categoryUnset : cat;
                          final selected = _selectedCategoryFilter == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(label),
                              selected: selected,
                              onSelected: (_) => setState(
                                () => _selectedCategoryFilter = selected
                                    ? null
                                    : cat,
                              ),
                              selectedColor: AppColors.secondary.withValues(
                                alpha: 0.35,
                              ),
                              backgroundColor: AppColors.surfaceLow,
                              side: BorderSide(
                                color: AppColors.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              checkmarkColor: AppColors.secondary,
                              labelStyle: TextStyle(
                                color: selected
                                    ? AppColors.onSurfaceAlpha(1)
                                    : AppColors.onSurfaceAlpha(0.8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCompletedGoalsSliver(List<VaultItem> completed) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGoalsFiltersArea(categoryFilterOptions: const []),
            ),
          ),
          if (completed.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: AppColors.onSurfaceAlpha(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noCompletedGoalsYet,
                      style: TextStyle(
                        color: AppColors.onSurfaceAlpha(0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _CompletedGoalCard(item: completed[index]);
              }, childCount: completed.length),
            ),
        ],
      ),
    );
  }

  Widget _buildItemListSliver({
    required List<VaultItem> filteredItems,
    required bool isReorderable,
  }) {
    if (isReorderable && filteredItems.isNotEmpty) {
      return SliverReorderableList(
        itemCount: filteredItems.length,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) newIndex--;
          final newOrder = List<VaultItem>.from(filteredItems);
          final item = newOrder.removeAt(oldIndex);
          newOrder.insert(newIndex, item);
          context.read<ItemRepository>().updateItemsOrder(
            newOrder.map((i) => i.id).toList(),
          );
        },
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return _ItemCard(
            key: ValueKey(item.id),
            item: item,
            overlayTopRight: _ItemCardTopActions(
              item: item,
              listReorderIndex: index,
            ),
          );
        },
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = filteredItems[index];
        return _ItemCard(
          item: item,
          overlayTopRight: _ItemCardTopActions(item: item),
        );
      }, childCount: filteredItems.length),
    );
  }
}

class _NetWorthHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VaultItem>>(
      stream: context.read<ItemRepository>().watchAllItems(),
      builder: (context, itemsSnapshot) {
        if (!itemsSnapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _NetWorthSkeleton(),
          );
        }
        return FutureBuilder<({String baseCurrency, AggregationResult result})>(
          future: _loadData(context, itemsSnapshot.data!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: const _NetWorthSkeleton(),
              );
            }
            final base = snapshot.data!.baseCurrency;
            final r = snapshot.data!.result;
            final l10n = AppLocalizations.of(context)!;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: AppColors.glassCard(radius: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _SubStat(
                      label: l10n.totalSavings,
                      value: formatCurrencyByCode(r.totalSavings, base),
                      accentColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SubStat(
                      label: l10n.totalDebt,
                      value: formatCurrencyByCode(r.totalDebt, base),
                      accentColor: AppColors.error,
                    ),
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
    List<VaultItem> items,
  ) async {
    final settings = context.read<SettingsStore>();
    final agg = context.read<AggregationService>();
    final exchange = context.read<ExchangeRateService>();
    final base = await settings.getBaseCurrency();
    final result = await agg.computeWithBaseCurrency(items, base, exchange);
    return (baseCurrency: base, result: result);
  }
}

/// 貯めたお金 / 借りたお金 サマリー用スケルトン
class _NetWorthSkeleton extends StatelessWidget {
  const _NetWorthSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.onSurfaceAlpha(0.06)),
      ),
      child: Row(
        children: [
          Expanded(child: _skeletonStatBox()),
          const SizedBox(width: 12),
          Expanded(child: _skeletonStatBox()),
        ],
      ),
    );
  }

  Widget _skeletonStatBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.onSurfaceAlpha(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 88,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.onSurfaceAlpha(0.18),
              borderRadius: BorderRadius.circular(6),
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
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accentColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.3,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CompletedGoalCard extends StatelessWidget {
  const _CompletedGoalCard({required this.item});

  final VaultItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.onSurfaceAlpha(0.06)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: itemImageRefIsDisplayable(item.imagePath)
                        ? ItemCoverImage(
                            imageRef: item.imagePath!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.success.withValues(alpha: 0.2),
                            child: Icon(
                              Icons.check_circle,
                              size: 28,
                              color: AppColors.onSurfaceAlpha(0.7),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.purchasedFor(
                          formatCurrencyByCode(
                            item.targetAmount,
                            item.currency,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceAlpha(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.onSurfaceAlpha(0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// カード右上: 編集（常時）と、並び替えリスト内ではドラッグハンドル
class _ItemCardTopActions extends StatelessWidget {
  const _ItemCardTopActions({required this.item, this.listReorderIndex});

  final VaultItem item;
  final int? listReorderIndex;

  @override
  Widget build(BuildContext context) {
    final edit = Tooltip(
      message: '編集',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddItemScreen(editItem: item)),
            );
          },
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.onSurfaceAlpha(0.9),
            ),
          ),
        ),
      ),
    );

    final dragHandle = Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 10, 8),
        child: Icon(
          Icons.drag_indicator,
          size: 22,
          color: AppColors.onSurfaceAlpha(0.85),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          edit,
          if (listReorderIndex != null)
            ReorderableDragStartListener(
              index: listReorderIndex!,
              child: dragHandle,
            ),
        ],
      ),
    );
  }
}

/// アイテムカード用のスケルトン（金額取得中）
class _ItemCardSkeleton extends StatelessWidget {
  const _ItemCardSkeleton({
    required this.item,
    required this.onTap,
    this.overlayTopRight,
  });

  final VaultItem item;
  final VoidCallback onTap;
  final Widget? overlayTopRight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.onSurfaceAlpha(0.06), width: 1),
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
              if (overlayTopRight == null)
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
              if (overlayTopRight != null)
                Positioned(top: 10, right: 10, child: overlayTopRight!),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({super.key, required this.item, this.overlayTopRight});

  final VaultItem item;
  final Widget? overlayTopRight;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: context.read<TransactionRepository>().getCurrentAmount(item.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ItemCardSkeleton(
              item: item,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
              ),
              overlayTopRight: overlayTopRight,
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
                    clipBehavior: Clip.none,
                    children: [
                      if (itemImageRefIsDisplayable(item.imagePath))
                        ItemCoverImage(
                          imageRef: item.imagePath!,
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
                      if (overlayTopRight != null)
                        Positioned(top: 10, right: 10, child: overlayTopRight!),
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
