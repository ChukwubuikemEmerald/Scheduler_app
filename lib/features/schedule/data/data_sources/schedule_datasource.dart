import 'package:sqflite/sqflite.dart';
import 'package:student_app_project/features/schedule/data/models/schedule.dart';
import 'package:student_app_project/core/sync/data/sync_outbox_data_source.dart';

class ScheduleDataSource {
  final Database db;
  final SyncOutboxDataSource outbox;

  ScheduleDataSource(
    this.db, {
    SyncOutboxDataSource? outbox,
  }) : outbox = outbox ?? SyncOutboxDataSource();

  Future<List<Schedule>> getSchedules() async {
    final result = await db.query('schedules');

    return result.map(Schedule.fromMap).toList();
  }

  Future<Schedule?> getScheduleById(int id) async {
    final result = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Schedule.fromMap(result.first);
  }

  Future<String?> _resolveCourseSyncId(
    DatabaseExecutor executor,
    int? courseId,
  ) async {
    if (courseId == null) return null;

    final courses = await executor.query(
      'courses',
      columns: ['sync_id'],
      where: 'id = ?',
      whereArgs: [courseId],
      limit: 1,
    );

    if (courses.isEmpty) {
      throw StateError('Cannot save schedule: course not found.');
    }

    return courses.first['sync_id'] as String;
  }

  Map<String, dynamic> _schedulePayload(
    Schedule schedule,
    String stableSyncId,
    String? courseSyncId,
  ) {
    return {
      'sync_id': stableSyncId,
      'course_sync_id': courseSyncId,
      'title': schedule.title,
      'description': schedule.description,
      'day_of_week': schedule.dayOfWeek,
      'start_time': schedule.startTime,
      'end_time': schedule.endTime,
      'location': schedule.location,
      'type': schedule.type.name,
    };
  }

  Future<int> insertSchedule(Schedule schedule) async {
    return db.transaction<int>((txn) async {
      final courseSyncId = await _resolveCourseSyncId(
        txn,
        schedule.courseId,
      );

      final id = await txn.insert(
        'schedules',
        schedule.toMap(),
      );

      await outbox.enqueue(
        executor: txn,
        entityType: SyncEntityType.schedule,
        syncId: schedule.syncId,
        operation: SyncOperation.upsert,
        payload: _schedulePayload(
          schedule,
          schedule.syncId,
          courseSyncId,
        ),
      );

      return id;
    });
  }

  Future<int> updateSchedule(Schedule schedule) async {
    if (schedule.id == null) {
      throw ArgumentError(
        'Cannot update a schedule without an ID.',
      );
    }

    return db.transaction<int>((txn) async {
      final existing = await txn.query(
        'schedules',
        columns: ['sync_id'],
        where: 'id = ?',
        whereArgs: [schedule.id],
        limit: 1,
      );

      if (existing.isEmpty) {
        throw StateError('Cannot update schedule: schedule not found.');
      }

      final stableSyncId = existing.first['sync_id'] as String;

      final courseSyncId = await _resolveCourseSyncId(
        txn,
        schedule.courseId,
      );

      final values = schedule.toMap();
      values['sync_id'] = stableSyncId;

      final count = await txn.update(
        'schedules',
        values,
        where: 'id = ?',
        whereArgs: [schedule.id],
      );

      await outbox.enqueue(
        executor: txn,
        entityType: SyncEntityType.schedule,
        syncId: stableSyncId,
        operation: SyncOperation.upsert,
        payload: _schedulePayload(
          schedule,
          stableSyncId,
          courseSyncId,
        ),
      );

      return count;
    });
  }

  Future<int> deleteSchedule(int id) async {
    return db.transaction<int>((txn) async {
      final existing = await txn.query(
        'schedules',
        columns: ['sync_id'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (existing.isEmpty) return 0;

      final stableSyncId = existing.first['sync_id'] as String;

      await outbox.enqueue(
        executor: txn,
        entityType: SyncEntityType.schedule,
        syncId: stableSyncId,
        operation: SyncOperation.delete,
      );

      return txn.delete(
        'schedules',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}