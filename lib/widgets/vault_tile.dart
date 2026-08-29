import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/vault_selection.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../utils/item_image_ref.dart';
import 'item_cover_image.dart';

/// 貯金箱グリッドの1枚。写真・名前・残高・進捗を出す。
///
/// 棚に並んだ瓶のイメージ。タップでアイテム詳細へ。
class VaultTile extends StatelessWidget {
  const VaultTile({
    super.key,
    required this.snapshot,
    required this.onTap,
    this.isHero = false,
  });

  final VaultSnapshot snapshot;
  final VoidCallback onTap;

  /// いま主役カードに出ている貯金箱か。棚の中での対応をわかるようにする。
  final bool isHero;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = snapshot.item;
    final hasPhoto = itemImageRefIsDisplayable(item.imagePath);

    final String statusLabel;
    if (snapshot.isRepaying) {
      statusLabel = l10n.homeHeroRepaying(
        formatCurrencyByCode(snapshot.balance.abs(), item.currency),
      );
    } else if (snapshot.isReached) {
      statusLabel = l10n.homeHeroReached;
    } else {
      statusLabel = l10n.homeHeroRemaining(
        formatCurrencyByCode(snapshot.remaining, item.currency),
      );
    }

    return Semantics(
      container: true,
      button: true,
      label: '${item.title}, $statusLabel',
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isHero
                      ? AppColors.primaryOutline
                      : AppColors.outlineVariant,
                  width: isHero ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 余った高さは写真側が吸う。文字の下に空きを作らない。
                  Expanded(
                    child: _Thumb(imageRef: hasPhoto ? item.imagePath : null),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (item.isPinned) ...[
                        const Icon(
                          Icons.push_pin,
                          size: 14,
                          color: AppColors.primaryOutline,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: snapshot.isRepaying
                          ? AppColors.warning
                          : AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: snapshot.isRepaying ? 0.0 : snapshot.progress,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceHigh,
                      valueColor: AlwaysStoppedAnimation(
                        snapshot.isRepaying
                            ? AppColors.warning
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 写真、無ければアンバーの下地にアイコン。
class _Thumb extends StatelessWidget {
  const _Thumb({this.imageRef});

  final String? imageRef;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageRef != null
            ? ItemCoverImage(imageRef: imageRef!, fit: BoxFit.cover)
            : Container(
                color: AppColors.primaryLight,
                child: const Center(
                  child: Icon(
                    Icons.savings_outlined,
                    size: 28,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
      ),
    );
  }
}
