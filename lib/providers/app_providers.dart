import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../database/app_database.dart';
import '../database/settings_store.dart';
import '../repositories/item_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/aggregation_service.dart';
import '../services/exchange_rate_service.dart';
import '../services/notification_service.dart';

List<SingleChildWidget> appProviders() {
  return [
    Provider<AppDatabase>(
      create: (_) => AppDatabase(),
      dispose: (_, db) => db.close(),
    ),
    ProxyProvider<AppDatabase, SettingsStore>(
      update: (_, db, previous) => SettingsStore(db),
    ),
    ProxyProvider<AppDatabase, ItemRepository>(
      update: (_, db, previous) => ItemRepository(db),
    ),
    ProxyProvider<AppDatabase, TransactionRepository>(
      update: (_, db, previous) => TransactionRepository(db),
    ),
    ProxyProvider<SettingsStore, ExchangeRateService>(
      update: (_, settings, previous) => ExchangeRateService(settings),
    ),
    ProxyProvider<TransactionRepository, AggregationService>(
      update: (_, tx, previous) => AggregationService(tx),
    ),
    Provider<NotificationService>(create: (_) => NotificationService()),
  ];
}
