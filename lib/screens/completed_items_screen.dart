import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_status.dart';
import '../models/vault_item.dart';
import '../repositories/item_repository.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../utils/item_image_ref.dart';
import '../widgets/item_cover_image.dart';
import 'item_detail_screen.dart';

class CompletedItemsScreen extends StatelessWidget {
  const CompletedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.onSurfaceAlpha(0.9)),
        ),
        title: Text(
          '完了したアイテム',
          style: TextStyle(
            color: AppColors.onSurfaceAlpha(0.95),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<VaultItem>>(
        stream: context.read<ItemRepository>().watchAllItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final completed = snapshot.data!
              .where((i) => i.status == ItemStatus.completed)
              .toList();
          if (completed.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'まだ完了したアイテムはありません',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: completed.length,
            itemBuilder: (context, index) {
              final item = completed[index];
              return _CompletedItemCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _CompletedItemCard extends StatelessWidget {
  const _CompletedItemCard({required this.item});

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
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 1,
              ),
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
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatCurrencyByCode(item.targetAmount, item.currency)} で購入済み',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
