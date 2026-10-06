import 'package:student_app_project/api/api_interface.dart';
import 'package:student_app_project/api/data/api_data_source.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';

class CourseAPIRepository implements CourseApiRepositoryImpl {
  final CourseApiDataSource apiDataSource;

  CourseAPIRepository({required this.apiDataSource});

  @override
  Future<List<Course>> getCourses() {
    return apiDataSource.getCourses();
  }

  @override
  Future<Course> getCourse(int id) {
    return apiDataSource.getCourse(id);
  }

  @override
  Future<int> insertCourse(Course course) {
    return apiDataSource.insertCourse(course);
  }

  @override
  Future<void> updateCourse(Course course) {
    return apiDataSource.updateCourse(course);
  }

  @override
  Future<void> deleteCourse(int id) {
    return apiDataSource.deleteCourse(id);
  }
}
