import 'package:sqflite/sqflite.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';
import 'package:student_app_project/core/sync/data/sync_outbox_data_source.dart';

class CourseDataSource {
  final Database database;
  final SyncOutboxDataSource outbox;

  CourseDataSource({
    required this.database,
    SyncOutboxDataSource? outbox,
  }) : outbox = outbox ?? SyncOutboxDataSource();

  Future<List<Course>> getCourses() async {
    final courses = await database.query('courses');
    return courses.map((row) => Course.fromMap(row)).toList();
  }

  Future<Course> getCourse(int id) async {
    final courses = await database.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (courses.isEmpty) {
      throw Exception('Course not found');
    }

    return Course.fromMap(courses.first);
  }

  Future<String?> _resolveSemesterSyncId(
    DatabaseExecutor executor,
    int? semesterId,
  ) async {
    if (semesterId == null) return null;

    final semesters = await executor.query(
      'semesters',
      columns: ['sync_id'],
      where: 'id = ?',
      whereArgs: [semesterId],
      limit: 1,
    );

    if (semesters.isEmpty) {
      throw StateError('Cannot save course: semester not found.');
    }

    return semesters.first['sync_id'] as String;
  }

  Future<void> _queueCourseUpsert(
    DatabaseExecutor executor,
    Course course,
    String courseSyncId,
    String? semesterSyncId,
  ) async {
    await outbox.enqueue(
      executor: executor,
      entityType: SyncEntityType.course,
      syncId: courseSyncId,
      operation: SyncOperation.upsert,
      payload: {
        'sync_id': courseSyncId,
        'code': course.code,
        'name': course.name,
        'semester_sync_id': semesterSyncId,
      },
    );
  }

  Future<int> insertCourse(Course course) async {
    return database.transaction<int>((txn) async {
      final semesterSyncId = await _resolveSemesterSyncId(
        txn,
        course.semesterId,
      );

      final courseId = await txn.insert(
        'courses',
        course.toMap(),
      );

      await _queueCourseUpsert(
        txn,
        course,
        course.syncId,
        semesterSyncId,
      );

      return courseId;
    });
  }

  Future<void> updateCourse(Course course) async {
    if (course.id == null) {
      throw ArgumentError('Cannot update a course without an ID.');
    }

    await database.transaction<void>((txn) async {
      final existing = await txn.query(
        'courses',
        columns: ['sync_id'],
        where: 'id = ?',
        whereArgs: [course.id],
        limit: 1,
      );

      if (existing.isEmpty) {
        throw StateError('Cannot update course: course not found.');
      }

      // Preserve the stable ID already stored in the database.
      final courseSyncId = existing.first['sync_id'] as String;

      final semesterSyncId = await _resolveSemesterSyncId(
        txn,
        course.semesterId,
      );

      final values = course.toMap();
      values['sync_id'] = courseSyncId;

      await txn.update(
        'courses',
        values,
        where: 'id = ?',
        whereArgs: [course.id],
      );

      await _queueCourseUpsert(
        txn,
        course,
        courseSyncId,
        semesterSyncId,
      );
    });
  }

  Future<void> deleteCourse(int id) async {
    await database.transaction<void>((txn) async {
      final existing = await txn.query(
        'courses',
        columns: ['sync_id'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      // Preserve the previous delete behaviour if the course is absent.
      if (existing.isEmpty) return;

      final courseSyncId = existing.first['sync_id'] as String;

      // Queue the remote deletion before deleting the local record.
      // Both changes commit or roll back together.
      await outbox.enqueue(
        executor: txn,
        entityType: SyncEntityType.course,
        syncId: courseSyncId,
        operation: SyncOperation.delete,
      );

      await txn.delete(
        'courses',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}