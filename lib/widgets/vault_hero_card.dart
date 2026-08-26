import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/vault_selection.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../utils/item_image_ref.dart';
import 'item_cover_image.dart';

/// ホームの主役カード。いま一番近い貯金箱を大きく見せ、入金へ直行させる。
///
/// 唯一のダーク面。写真があれば背景に敷き、スクリムで文字の可読性を確保する。
class VaultHeroCard extends StatelessWidget {
  const VaultHeroCard({
    super.key,
    required this.snapshot,
    required this.onAddMoney,
    required this.onOpen,
  });

  final VaultSnapshot snapshot;
  final VoidCallback onAddMoney;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = snapshot.item;
    final hasPhoto = itemImageRefIsDisplayable(item.imagePath);

    return Semantics(
      container: true,
      label: item.title,
      child: Material(
        color: AppColors.heroSurface,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Stack(
            children: [
              if (hasPhoto)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.45,
                    child: ItemCoverImage(
                      imageRef: item.imagePath!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (hasPhoto)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.scrim.withValues(alpha: 0.55),
                          AppColors.scrim.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TopRow(snapshot: snapshot),
                    const SizedBox(height: 18),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onHeroMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _HeadlineAmount(snapshot: snapshot),
                    const SizedBox(height: 14),
                    _Progress(snapshot: snapshot),
                    const SizedBox(height: 10),
                    Text(
                      l10n.homeHeroOf(
                        formatCurrencyByCode(snapshot.balance, item.currency),
                        formatCurrencyByCode(
                          snapshot.item.targetAmount,
                          item.currency,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onHeroMuted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onAddMoney,
                        child: Text(l10n.homeAddMoney),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 目標日・予測、そしてピン留めの表示。
class _TopRow extends StatelessWidget {
  const _TopRow({required this.snapshot});

  final VaultSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = snapshot.daysUntilTarget();

    final String label;
    final IconData icon;
    if (days == null) {
      label = l10n.homeHeroNoDate;
      icon = Icons.savings_outlined;
    } else if (days == 0) {
      label = l10n.homeHeroDueToday;
      icon = Icons.schedule;
    } else if (days < 0) {
      label = l10n.homeHeroOverdue(-days);
      icon = Icons.schedule;
    } else {
      label = l10n.homeHeroDueInDays(days);
      icon = Icons.schedule;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onHeroMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onHeroMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (snapshot.item.isPinned)
          Semantics(
            label: l10n.pinnedToHome,
            child: const Icon(
              Icons.push_pin,
              size: 16,
              color: AppColors.onHeroMuted,
            ),
          ),
      ],
    );
  }
}

/// 「あと ¥32,000」。この画面で一番大きい文字。
class _HeadlineAmount extends StatelessWidget {
  const _HeadlineAmount({required this.snapshot});

  final VaultSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = snapshot.item.currency;

    final String text;
    if (snapshot.isRepaying) {
      text = l10n.homeHeroRepaying(
        formatCurrencyByCode(snapshot.balance.abs(), currency),
      );
    } else if (snapshot.isReached) {
      text = l10n.homeHeroReached;
    } else {
      text = l10n.homeHeroRemaining(
        formatCurrencyByCode(snapshot.remaining, currency),
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: AppColors.onHero,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.snapshot});

  final VaultSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final value = snapshot.isRepaying ? 0.0 : snapshot.progress;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
        backgroundColor: AppColors.onHeroAlpha(0.16),
        valueColor: AlwaysStoppedAnimation(
          snapshot.isRepaying ? AppColors.warning : AppColors.primary,
        ),
      ),
    );
  }
}
