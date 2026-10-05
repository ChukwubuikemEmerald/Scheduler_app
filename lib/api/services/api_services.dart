import 'package:student_app_project/api/api_interface.dart';
import 'package:student_app_project/api/data/api_data_source.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';

class CourseApiRepoimpl implements CourseApiDataSource {
  final CourseApiDataSource apiDataSource;

  CourseApiRepoimpl({required this.apiService});

  @override
  Future<List<Course>> getCourses() {
    return apiService.getCourses();
  }

  @override
  Future<Course> getCourse(int id) {
    return apiService.getCourse(id);
  }

  @override
  Future<int> insertCourse(Course course) {
    return apiService.insertCourse(course);
  }

  @override
  Future<void> updateCourse(Course course) {
    return apiService.updateCourse(course);
  }

  @override
  Future<void> deleteCourse(int id) {
    return apiService.deleteCourse(id);
  }
}
