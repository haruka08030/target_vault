import 'package:drift/drift.dart';

import 'memory_test_executor_io.dart'
    if (dart.library.html) 'memory_test_executor_web.dart'
    as impl;

QueryExecutor memoryTestExecutor() => impl.memoryTestExecutor();
