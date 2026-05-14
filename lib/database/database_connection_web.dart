import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor connectAppDatabaseExecutor() {
  return LazyDatabase(() async {
    final opened = await WasmDatabase.open(
      databaseName: 'target_vault',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return opened.resolvedExecutor;
  });
}
