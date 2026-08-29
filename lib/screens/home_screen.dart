import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/item_status.dart';
import '../models/vault_item.dart';
import '../repositories/item_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/vault_selection.dart';
import '../theme/app_colors.dart';
import '../widgets/vault_hero_card.dart';
import '../widgets/vault_tile.dart';
import 'add_item_screen.dart';
import 'completed_items_screen.dart';
import 'item_detail_screen.dart';
import 'onboarding_view.dart';
import 'quick_add_sheet.dart';
import 'settings_screen.dart';

/// ホーム。「いま一番近い貯金箱」を主役に置き、その下に他の貯金箱を並べる。
///
/// 合計や純資産は出さない。貯金箱アプリなので、見たいのは個々の箱の進み具合。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// カテゴリフィルタ: null=すべて, ''=カテゴリなし, それ以外=カテゴリ名
  String? _categoryFilter;

  /// 主役カードでいま表示している貯金箱。スワイプで変わる。
  String? _heroItemId;

  Future<void> _openAddItem() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddItemScreen()),
    );
  }

  void _openItem(VaultItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
    );
  }

  Future<void> _addMoney(VaultItem item) async {
    await showQuickAddSheet(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<VaultItem>>(
          stream: context.read<ItemRepository>().watchAllItems(),
          builder: (context, itemsSnap) {
            if (!itemsSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = itemsSnap.data!;
            final active = all
                .where((i) => i.status != ItemStatus.completed)
                .toList();

            // 残高は1本のクエリでまとめて取る（カードごとに引かない）。
            return StreamBuilder<Map<String, double>>(
              stream: context.read<TransactionRepository>().watchAllBalances(),
              builder: (context, balanceSnap) {
                final balances = balanceSnap.data ?? const <String, double>{};
                final snapshots = [
                  for (final item in active)
                    VaultSnapshot(item: item, balance: balances[item.id] ?? 0),
                ];

                if (active.isEmpty) {
                  return _EmptyHome(
                    hasCompleted: all.isNotEmpty,
                    onStart: _openAddItem,
                  );
                }

                return _Content(
                  snapshots: snapshots,
                  categoryFilter: _categoryFilter,
                  heroItemId: _heroItemId,
                  onHeroChanged: (id) => setState(() => _heroItemId = id),
                  onCategoryChanged: (c) => setState(() => _categoryFilter = c),
                  onOpenItem: _openItem,
                  onAddMoney: _addMoney,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItem,
        tooltip: l10n.addItem,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

/// 上部のアプリ名と、設定・完了への導線。
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Target Vault',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onBackground,
                letterSpacing: -0.2,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompletedItemsScreen()),
            ),
            tooltip: l10n.homeViewCompleted,
            icon: const Icon(Icons.inventory_2_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}

/// 貯金箱が1件も無いとき。説明を並べず、次の一手だけ置く。
class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.hasCompleted, required this.onStart});

  /// 完了した貯金箱だけが残っている場合は、そこへの導線を残す。
  final bool hasCompleted;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (hasCompleted) const _HomeHeader(),
        Expanded(child: OnboardingView(onStart: onStart)),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.snapshots,
    required this.categoryFilter,
    required this.heroItemId,
    required this.onHeroChanged,
    required this.onCategoryChanged,
    required this.onOpenItem,
    required this.onAddMoney,
  });

  final List<VaultSnapshot> snapshots;
  final String? categoryFilter;
  final String? heroItemId;
  final ValueChanged<String> onHeroChanged;
  final ValueChanged<String?> onCategoryChanged;
  final void Function(VaultItem) onOpenItem;
  final Future<void> Function(VaultItem) onAddMoney;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 主役は「スワイプで選んだもの」→ 無ければ自動選定。
    //
    // 主役はピックアップとして上に浮いているだけで、棚（タイル）からは
    // 抜かない。抜くとスワイプのたびに並びが組み替わり、探しづらくなる。
    final hero = _resolveHero();

    final categories = _categoryOptions();
    final filtered = _applyFilter(snapshots);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _HomeHeader()),
        if (hero != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _SwipeableHero(
                snapshots: snapshots,
                current: hero,
                onChanged: onHeroChanged,
                onOpen: () => onOpenItem(hero.item),
                onAddMoney: () => onAddMoney(hero.item),
              ),
            ),
          ),
        if (snapshots.length > 1)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                l10n.homeAllVaults,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.onBackground,
                ),
              ),
            ),
          ),
        if (categories.isNotEmpty)
          SliverToBoxAdapter(
            child: _CategoryFilters(
              options: categories,
              selected: categoryFilter,
              onChanged: onCategoryChanged,
            ),
          ),
        if (snapshots.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            // 高さは中身に合わせる。固定比にすると文字サイズ最大で溢れる。
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 224,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final s = filtered[index];
                return VaultTile(
                  snapshot: s,
                  isHero: s.item.id == hero?.item.id,
                  onTap: () => onOpenItem(s.item),
                );
              }, childCount: filtered.length),
            ),
          ),
        if (snapshots.isNotEmpty && filtered.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: Text(
                l10n.emptyVaultsTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  VaultSnapshot? _resolveHero() {
    if (heroItemId != null) {
      for (final s in snapshots) {
        if (s.item.id == heroItemId) return s;
      }
    }
    return selectHeroVault(snapshots);
  }

  List<String> _categoryOptions() {
    final set = snapshots.map((s) => s.item.category).toSet();
    final named = set.whereType<String>().toList()..sort();
    final options = [if (set.contains(null)) '', ...named];
    // 選択肢が1つだけなら絞り込む意味がないので出さない。
    return options.length < 2 ? const [] : options;
  }

  List<VaultSnapshot> _applyFilter(List<VaultSnapshot> list) {
    if (categoryFilter == null) return list;
    if (categoryFilter!.isEmpty) {
      return list.where((s) => s.item.category == null).toList();
    }
    return list.where((s) => s.item.category == categoryFilter).toList();
  }
}

/// 主役カードを左右スワイプで切り替える。設定を増やさずに「他も見たい」を satisfy する。
class _SwipeableHero extends StatefulWidget {
  const _SwipeableHero({
    required this.snapshots,
    required this.current,
    required this.onChanged,
    required this.onOpen,
    required this.onAddMoney,
  });

  final List<VaultSnapshot> snapshots;
  final VaultSnapshot current;
  final ValueChanged<String> onChanged;
  final VoidCallback onOpen;
  final VoidCallback onAddMoney;

  @override
  State<_SwipeableHero> createState() => _SwipeableHeroState();
}

class _SwipeableHeroState extends State<_SwipeableHero> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = widget.snapshots;
    final index = items.indexWhere((s) => s.item.id == widget.current.item.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onHorizontalDragEnd: items.length < 2
              ? null
              : (details) {
                  final v = details.primaryVelocity ?? 0;
                  if (v == 0) return;
                  final next = v < 0 ? index + 1 : index - 1;
                  final wrapped = (next + items.length) % items.length;
                  widget.onChanged(items[wrapped].item.id);
                },
          child: VaultHeroCard(
            snapshot: widget.current,
            onAddMoney: widget.onAddMoney,
            onOpen: widget.onOpen,
          ),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 12),
          Semantics(
            label: l10n.homeSwipeHint,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < items.length; i++)
                  Container(
                    width: i == index ? 20 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == index
                          ? AppColors.primaryOutline
                          : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// カテゴリの絞り込み。未選択でも枠が見えるようにして押しやすくする。
class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = options[index];
          final isSelected = selected == value;
          return FilterChip(
            label: Text(value.isEmpty ? l10n.categoryUnset : value),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onChanged(isSelected ? null : value),
            side: BorderSide(
              color: isSelected ? AppColors.primaryOutline : AppColors.outline,
            ),
          );
        },
      ),
    );
  }
}
