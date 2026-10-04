import 'package:http/http.dart' as http;
import 'package:student_app_project/features/courses/data/model/course.dart';

import 'dart:convert';

Future<List<Course>> getCourses() async {
  final url = Uri.parse('http://10.223.21.123:8000/api/courses');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data as List).map((course) => Course.fromMap(course)).toList();
  } else {
    throw Exception('Failed to load courses');
  }
}
