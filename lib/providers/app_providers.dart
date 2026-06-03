import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../app_locale_controller.dart';
import '../database/app_database.dart';
import '../database/settings_store.dart';
import '../repositories/item_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/aggregation_service.dart';
import '../services/exchange_rate_service.dart';
import '../services/notification_service.dart';

List<SingleChildWidget> appProviders({AppDatabase? database}) {
  return [
    database != null
        ? Provider<AppDatabase>.value(value: database)
        : Provider<AppDatabase>(
            create: (_) => AppDatabase(),
            dispose: (_, db) => db.close(),
          ),
    ProxyProvider<AppDatabase, TransactionRepository>(
      update: (_, db, _) => DriftTransactionRepository(db),
    ),
    ProxyProvider2<AppDatabase, TransactionRepository, ItemRepository>(
      update: (_, db, tx, _) => DriftItemRepository(db, tx),
    ),
    ProxyProvider<AppDatabase, SettingsStore>(
      update: (_, db, _) => DriftSettingsStore(db),
    ),
    ChangeNotifierProvider<AppLocaleController>(
      create: (context) {
        final controller = AppLocaleController(
          context.read<SettingsStore>(),
        );
        controller.initialize();
        return controller;
      },
    ),
    ProxyProvider<SettingsStore, ExchangeRateService>(
      update: (_, settings, _) => ExchangeRateService(settings),
    ),
    ProxyProvider<TransactionRepository, AggregationService>(
      update: (_, tx, _) => AggregationService(tx),
    ),
    Provider<NotificationService>(create: (_) => NotificationService()),
  ];
}
