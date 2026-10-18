import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

Future<void> inspectDatabase() async {
  final directory = await getDatabasesPath();
  final path = p.join(directory, 'courses.db');

  if (!await databaseExists(path)) {
    debugPrint('Database not found: $path');
    return;
  }

  // Open the existing database without specifying a version
  // or migration callbacks.
  final db = await openDatabase(path);

  try {
    debugPrint('Database version: ${await db.getVersion()}');

    for (final table in ['semesters', 'courses', 'schedules']) {
      final columns = await db.rawQuery(
        'PRAGMA table_info($table)',
      );

      debugPrint(
        '$table columns: '
        '${columns.map((column) => column['name']).join(', ')}',
      );
    }
  } finally {
    await db.close();
  }
}