import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_locale_controller.dart';
import 'database/app_database.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_providers.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlay);
  runApp(const TargetVaultApp());
}

class TargetVaultApp extends StatelessWidget {
  const TargetVaultApp({super.key, this.database});

  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders(database: database),
      child: Consumer<AppLocaleController>(
        builder: (context, localeController, _) {
          return MaterialApp(
            title: 'Target Vault',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            locale: localeController.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
