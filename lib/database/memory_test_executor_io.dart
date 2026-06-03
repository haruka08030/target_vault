import 'package:drift/drift.dart';
import 'package:drift/native.dart';

QueryExecutor memoryTestExecutor() => DatabaseConnection(
  NativeDatabase.memory(),
  closeStreamsSynchronously: true,
);
