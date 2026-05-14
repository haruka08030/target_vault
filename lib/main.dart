import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'database/app_database.dart';
import 'providers/app_providers.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlay);
  runApp(const TargetVaultApp());
}

class TargetVaultApp extends StatelessWidget {
  const TargetVaultApp({super.key, this.database});

  /// 指定時はこの DB で Provider を構成する（Widget テスト用）。
  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders(database: database),
      child: MaterialApp(
        title: 'Target Vault',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
}
