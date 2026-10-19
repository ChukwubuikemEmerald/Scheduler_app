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

  final db = await openDatabase(path);

  try {
    debugPrint('Database version: ${await db.getVersion()}');

    // Inspect the existing entity tables.
    for (final table in ['semesters', 'courses', 'schedules']) {
      final columns = await db.rawQuery('PRAGMA table_info($table)');

      debugPrint(
        '$table columns: '
        '${columns.map((column) => column['name']).join(', ')}',
      );
    }

    // List every table in the database.
    final tables = await db.rawQuery('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      ORDER BY name
    ''');

    debugPrint('All tables: ${tables.map((row) => row['name']).join(', ')}');

    // Inspect the outbox.
    final outboxColumns = await db.rawQuery('PRAGMA table_info(sync_outbox)');

    debugPrint(
      'Outbox columns: '
      '${outboxColumns.map((column) => column['name']).join(', ')}',
    );
  } finally {
    await db.close();
  }
}
