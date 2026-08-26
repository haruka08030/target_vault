import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/vault_illustration.dart';

/// 貯金箱が0件のときにホームへ出す画面。
///
/// 初回フラグは持たない。0件ならいつでもこれを出す（全部消したときも同じ導線）。
/// 説明を並べず、選択肢を1つだけ置く。
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Center(
                      child: VaultIllustration(
                        size: constraints.maxWidth.clamp(0, 320) * 0.8,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'Target Vault',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: AppColors.onBackground),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.onboardingTagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.onboardingBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 22 / 15,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: onStart,
                      child: Text(l10n.onboardingStart),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
