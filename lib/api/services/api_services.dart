import 'package:student_app_project/api/api_interface.dart';
import 'package:student_app_project/api/data/api_data_source.dart';

class CourseApiRepoimpl extends CourseApiDataSource {
  final ApiService apiService;

  CourseApiRepoimpl({required this.apiService});
  
}
