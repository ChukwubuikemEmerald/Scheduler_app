import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_app_project/core/sync/data/sync_processor.dart';
import 'package:student_app_project/features/courses/presentation/providers/course_provider.dart';

final syncProcessorProvider = FutureProvider<SyncProcessor>((ref) async {
  final databaseHelper = ref.watch(databaseHelperProvider);
  final database = await databaseHelper.database;

  final processor = SyncProcessor(
    database: database,
    baseUrl: 'http://10.223.21.123:8000',
  );

  ref.onDispose(processor.close);

  return processor;
});
