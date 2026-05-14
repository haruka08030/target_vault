import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// VM / ネイティブ向け。Widget テストでタイマー残留を避ける。
QueryExecutor memoryTestExecutor() => DatabaseConnection(
  NativeDatabase.memory(),
  closeStreamsSynchronously: true,
);
