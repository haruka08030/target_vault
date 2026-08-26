import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:target_vault/app_locale_controller.dart';
import 'package:target_vault/database/settings_store.dart';
import 'package:target_vault/repositories/item_repository.dart';
import 'package:target_vault/repositories/transaction_repository.dart';
import 'package:target_vault/services/notification_service.dart';

import 'in_memory_backend.dart';

List<SingleChildWidget> testWidgetProviders(ItemTxTestBackend backend) {
  final settings = MemorySettingsStore();
  final items = FakeItemRepository(backend);
  final txs = FakeTransactionRepository(backend);
  final localeController = AppLocaleController(settings);
  localeController.initialize();
  return [
    Provider<ItemTxTestBackend>.value(value: backend),
    Provider<SettingsStore>.value(value: settings),
    ChangeNotifierProvider<AppLocaleController>.value(
      value: localeController,
    ),
    Provider<ItemRepository>.value(value: items),
    Provider<TransactionRepository>.value(value: txs),
    Provider<NotificationService>(create: (_) => NotificationService()),
  ];
}
