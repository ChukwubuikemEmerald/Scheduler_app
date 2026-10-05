import 'package:student_app_project/features/courses/data/model/course.dart';

abstract interface class CourseApiRepositoryImpl {
  Future<List<Course>> getCourses();

  Future<Course> getCourse(int id);

  Future<int> insertCourse(Course course);

  Future<void> updateCourse(Course course);

  Future<void> deleteCourse(int id);
}
