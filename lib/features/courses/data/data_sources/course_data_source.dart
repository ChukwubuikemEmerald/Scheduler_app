
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
    return courses.map((course) => Course.fromMap(course)).toList();
  }

  Future<Course> getCourse(int id) async {
    final courses = await database.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (courses.isEmpty) {
      throw Exception('Course not found');
    }

    return Course.fromMap(courses.first);
  }

  Future<int> insertCourse(Course course) async {
    return database.transaction<int>((txn) async {
      String? semesterSyncId;

      // Resolve the semester's stable ID instead of sending
      // the device-specific SQLite integer ID to the server.
      if (course.semesterId != null) {
        final semesters = await txn.query(
          'semesters',
          columns: ['sync_id'],
          where: 'id = ?',
          whereArgs: [course.semesterId],
          limit: 1,
        );

        if (semesters.isEmpty) {
          throw StateError(
            'Cannot insert course: semester not found.',
          );
        }

        semesterSyncId = semesters.first['sync_id'] as String;
      }

      // 1. Save the course locally.
      final courseId = await txn.insert(
        'courses',
        course.toMap(),
      );

      // 2. Queue the corresponding remote operation.
      await outbox.enqueue(
        executor: txn,
        entityType: SyncEntityType.course,
        syncId: course.syncId,
        operation: SyncOperation.upsert,
        payload: {
          'sync_id': course.syncId,
          'code': course.code,
          'name': course.name,
          'semester_sync_id': semesterSyncId,
        },
      );

      // The transaction commits only if both operations succeed.
      return courseId;
    });
  }

  Future<void> deleteCourse(int id) async {
    await database.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCourse(Course course) async {
    if (course.id == null) {
      throw ArgumentError('Cannot update a course without an ID.');
    }

    await database.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }
}
