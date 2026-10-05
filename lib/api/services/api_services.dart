import 'package:student_app_project/api/api_interface.dart';
import 'package:student_app_project/api/data/api_data_source.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';

class CourseApiRepoimpl extends CourseApiDataSource {
  final ApiService apiService;

  CourseApiRepoimpl({required this.apiService});

  @override
  Future<List<Course>> getCourses() {
    return apiService.getCourses();
  }

  @override
  Future<int> insertCourse(Course course){
    return apiService.getCourse(course.id!);
  }

    @override
  Future<void> 
}
