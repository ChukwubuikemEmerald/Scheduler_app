import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app_project/core/database/database_helper.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});
