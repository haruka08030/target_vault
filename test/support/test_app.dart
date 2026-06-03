import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:target_vault/app_locale_controller.dart';
import 'package:target_vault/l10n/app_localizations.dart';
import 'package:target_vault/theme/app_theme.dart';

MaterialApp _materialApp({required Widget home, Locale? locale}) {
  return MaterialApp(
    theme: AppTheme.theme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

/// Widget tests 用の [MaterialApp]（ローカライズ付き）。
Widget testMaterialApp({
  required Widget home,
  Locale? locale,
  AppLocaleController? localeController,
}) {
  if (localeController == null) {
    return _materialApp(home: home, locale: locale ?? const Locale('ja'));
  }
  return ChangeNotifierProvider<AppLocaleController>.value(
    value: localeController,
    child: ListenableBuilder(
      listenable: localeController,
      builder: (context, _) => _materialApp(
        home: home,
        locale: locale ?? localeController.locale ?? const Locale('ja'),
      ),
    ),
  );
}

/// [MultiProvider] + 保存済み言語設定に追従する [MaterialApp]。
Widget testMaterialAppWithProviders({
  required List<SingleChildWidget> providers,
  required Widget child,
  Locale? localeOverride,
}) {
  return MultiProvider(
    providers: providers,
    child: Builder(
      builder: (context) {
        final localeController = context.read<AppLocaleController>();
        return ListenableBuilder(
          listenable: localeController,
          builder: (context, _) {
            final locale =
                localeOverride ??
                localeController.locale ??
                const Locale('ja');
            return _materialApp(home: child, locale: locale);
          },
        );
      },
    ),
  );
}
