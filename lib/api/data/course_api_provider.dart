import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app_project/api/data/api_data_source.dart';
import 'package:student_app_project/api/services/api_repo.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';

final apiDataSourceProvider = Provider<CourseApiDataSource>((ref) {
  return CourseApiDataSource();
});

final courseAPIRepositoryProvider = FutureProvider<CourseAPIRepository>((
  ref,
) async {
  final apiDataSource = ref.watch(apiDataSourceProvider);

  return CourseAPIRepository(apiDataSource: apiDataSource);
});

final courseProvider = AsyncNotifierProvider<CourseNotifier, List<Course>>(
  CourseNotifier.new,
);

class CourseNotifier extends AsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() async {
    final repository = await ref.watch(courseAPIRepositoryProvider.future);

    return repository.getCourses();
  }

  Future<Course> getCourse(int id) async {
    final repository = await ref.read(courseAPIRepositoryProvider.future);

    return repository.getCourse(id);
  }

  Future<void> addCourse(Course course) async {
    try {
      final repository = await ref.read(courseAPIRepositoryProvider.future);
      await repository.insertCourse(course);
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      debugPrint('The Error: $error');
      debugPrint('The Stack Trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateCourse(Course course) async {
    try {
      final repository = await ref.read(courseAPIRepositoryProvider.future);
      await repository.updateCourse(course);
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      debugPrint('The Error: $error');
      debugPrint('The Stack Trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteCourse(Course course) async {
    try {
      if (course.id == null) {
        throw ArgumentError('Cannot delete a course without an ID.');
      }

      final repository = await ref.read(courseAPIRepositoryProvider.future);
      await repository.deleteCourse(course.id!);
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      debugPrint('The Error: $error');
      debugPrint('The Stack Trace: $stackTrace');
      rethrow;
    }
  }
}
