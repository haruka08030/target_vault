import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/item_status.dart';
import '../models/vault_item.dart';
import '../repositories/item_repository.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../utils/item_image_ref.dart';
import '../widgets/item_cover_image.dart';
import 'item_detail_screen.dart';

/// 棚から下ろした貯金箱の一覧。
///
/// 「完了（買い終えた）」と「アーカイブ（やめた）」を2セクションで並べる。
/// 意味の違うものを混ぜないが、画面は分けない。
class CompletedItemsScreen extends StatelessWidget {
  const CompletedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.shelfTitle)),
      body: StreamBuilder<List<VaultItem>>(
        stream: context.read<ItemRepository>().watchAllItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!;
          final completed = all
              .where((i) => i.status == ItemStatus.completed)
              .toList();
          final archived = all
              .where((i) => i.status == ItemStatus.archived)
              .toList();

          if (completed.isEmpty && archived.isEmpty) {
            return _Empty(l10n: l10n);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (completed.isNotEmpty) ...[
                _SectionLabel(text: l10n.sectionCompleted),
                for (final item in completed)
                  _ShelfCard(item: item, isArchived: false),
              ],
              if (archived.isNotEmpty) ...[
                _SectionLabel(text: l10n.sectionArchived),
                for (final item in archived)
                  _ShelfCard(item: item, isArchived: true),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onBackground,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: AppColors.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.emptyOffShelf,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.emptyOffShelfBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// 棚から下ろした箱1件。アーカイブはその場で戻せる。
class _ShelfCard extends StatelessWidget {
  const _ShelfCard({required this.item, required this.isArchived});

  final VaultItem item;
  final bool isArchived;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: itemImageRefIsDisplayable(item.imagePath)
                        ? ItemCoverImage(
                            imageRef: item.imagePath!,
                            fit: BoxFit.cover,
                          )
                        : ColoredBox(
                            color: isArchived
                                ? AppColors.surfaceHigh
                                : AppColors.primaryLight,
                            child: Icon(
                              isArchived
                                  ? Icons.inventory_2_outlined
                                  : Icons.check_circle,
                              size: 26,
                              color: isArchived
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.onPrimary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArchived
                            ? formatCurrencyByCode(
                                item.targetAmount,
                                item.currency,
                              )
                            : l10n.purchasedFor(
                                formatCurrencyByCode(
                                  item.targetAmount,
                                  item.currency,
                                ),
                              ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isArchived)
                  TextButton(
                    onPressed: () async {
                      final repo = context.read<ItemRepository>();
                      final messenger = ScaffoldMessenger.of(context);
                      await repo.unarchiveItem(item.id);
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.unarchivedSnack)),
                      );
                    },
                    child: Text(l10n.unarchiveItem),
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
