import 'package:sqflite/sqflite.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';

class CourseDataSource {
  final Database database;
  CourseDataSource({required this.database});

  Future<List<Course>> getCourses() async {
    final List<Map<String, dynamic>> courses = await database.query('courses');
    return courses.map((course) => Course.fromMap(course)).toList();
  }

  Future<Course> getCourse(int id) async {
    final courses = await database.query(
      'courses',
      where: 'id =?',
      whereArgs: [id],
    );

    if (courses.isEmpty) {
      throw Exception('Course not found');
    }

    return Course.fromMap(courses.first);
  }

  Future<int> insertCourse(Course course) async {
    return await database.insert('courses', course.toMap());
  }

  Future<void> deleteCourse(int id) async {
    await database.delete('courses', where: 'id = ?', whereArgs: [id]);
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
