import 'package:student_app_project/core/database/database_helper.dart';
import 'package:student_app_project/core/sync/data/sync_outbox_data_source.dart';
import 'package:student_app_project/features/semesters/data/models/semester.dart';
import 'package:student_app_project/features/semesters/data/datascources/semester_data_source_interface.dart';

class SemesterDataSourceImpl implements SemesterDataSource {
  final DatabaseHelper databaseHelper;
  final SyncOutboxDataSource outbox;

  SemesterDataSourceImpl(this.databaseHelper, {SyncOutboxDataSource? outbox})
    : outbox = outbox ?? SyncOutboxDataSource();

  @override
  Future<List<Semester>> getSemesters() async {
    final db = await databaseHelper.database;
    final result = await db.query('semesters', orderBy: 'startDate ASC');

    return result.map(Semester.fromMap).toList();
  }

  @override
  Future<int> insertSemester(Semester semester) async {
    final db = await databaseHelper.database;

    return db.transaction<int>((txn) async {
      final id = await txn.insert('semesters', semester.toMap());

      await outbox.enqueue(
        executor: txn,
        entityType: SyncEntityType.semester,
        syncId: semester.syncId,
        operation: SyncOperation.upsert,
        payload: {
          'sync_id': semester.syncId,
          'name': semester.name,
          'start_date': semester.startDate.toIso8601String(),
          'end_date': semester.endDate.toIso8601String(),
        },
      );

      return id;
    });
  }

  @override
  Future<void> updateSemester(Semester semester) async {
    if (semester.id == null) {
      throw ArgumentError('Cannot update a semester without an ID.');
    }

    final db = await databaseHelper.database;

    await db.transaction<void>((txn) async {
      final existing = await txn.query(
        'semesters',
        columns: ['sync_id'],
        where: 'id = ?',
        whereArgs: [semester.id],
        limit: 1,
      );

      if (existing.isEmpty) {
        throw StateError('Cannot update semester: semester not found.');
      }

      final stableSyncId = existing.first['sync_id'] as String;
      final values = semester.toMap();
      values['sync_id'] = stableSyncId;

      await txn.update(
        'semesters',
        values,
        where: 'id = ?',
        whereArgs: [semester.id],
      );

      await outbox.enqueue(
        executor: txn,
        entityType: SyncEntityType.semester,
        syncId: stableSyncId,
        operation: SyncOperation.upsert,
        payload: {
          'sync_id': stableSyncId,
          'name': semester.name,
          'start_date': semester.startDate.toIso8601String(),
          'end_date': semester.endDate.toIso8601String(),
        },
      );
    });
  }

  @override
  Future<void> deleteSemester(int id) async {
    final db = await databaseHelper.database;

    await db.transaction<void>((txn) async {
      final existing = await txn.query(
        'semesters',
        columns: ['sync_id'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (existing.isEmpty) return;

      final stableSyncId = existing.first['sync_id'] as String;

      await outbox.enqueue(
        executor: txn,
        entityType: SyncEntityType.semester,
        syncId: stableSyncId,
        operation: SyncOperation.delete,
      );

      await txn.delete('semesters', where: 'id = ?', whereArgs: [id]);
    });
  }
}
