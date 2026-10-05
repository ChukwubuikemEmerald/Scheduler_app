import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:student_app_project/features/courses/data/model/course.dart';

class CourseApiDataSource {
  CourseApiDataSource();

  final URL = 'http://10.223.21.123:8000/api/courses';

  //get courses
  Future<List<Course>> getCourses() async {
    final url = Uri.parse(URL);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data as List).map((course) => Course.fromMap(course)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  //get course
  Future<Course> getCourse(int id) async {
    final url = Uri.parse('$URL/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Course.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get course');
    }
  }

  //Create course
  Future<int> insertCourse(Course course) async {
    final url = Uri.parse(URL);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toMap()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    }
    throw Exception('Failed to insert course');
  }

  //update course
  Future<void> updateCourse(Course course) async {
    final url = Uri.parse('$URL/$course.id');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toMap()),
    );

    if (response.statusCode == 200) {
      return;
    }
    throw Exception('Failed to update coursea');
  }

  Future<void> deleteCourse(int id) async {
    final url = Uri.parse('$URL/$id');

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      return;
    }
    throw Exception('Failed to delete course');
  }
}
