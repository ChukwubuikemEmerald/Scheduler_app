import 'package:student_app_project/features/courses/data/data_sources/course_data_source.dart';
import 'package:student_app_project/features/courses/data/data_sources/datasource_interface.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseDataSource dataSource;

  CourseRepositoryImpl({required this.dataSource});

  @override
  Future<List<Course>> getCourses() {
    return dataSource.getCourses();
  }

  @override
  Future<Course> getCourse(int id) {
    return dataSource.getCourse(id);
  }

  @override
  Future<int> insertCourse(Course course) {
    return dataSource.insertCourse(course);
  }

  @override
  Future<void> updateCourse(Course course) {
    return dataSource.updateCourse(course);
  }

  @override
  Future<void> deleteCourse(int id) {
    return dataSource.deleteCourse(id);
  }
}
