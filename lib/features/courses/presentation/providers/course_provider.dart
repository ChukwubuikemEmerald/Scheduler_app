import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_app_project/features/courses/data/data_sources/course_data_source.dart';
import 'package:student_app_project/core/database/database_helper.dart';
import 'package:student_app_project/features/courses/data/data_sources/datasource_interface.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';
import 'package:student_app_project/features/courses/data/repositories/course_repository_impl.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final databaseProvider = FutureProvider<Database>((ref) {
  final helper = ref.watch(databaseHelperProvider);

  return helper.database;
});

final courseDataSourceProvider = FutureProvider<CourseDataSource>((ref) async {
  final database = await ref.watch(databaseProvider.future);

  return CourseDataSource(database: database);
});

final courseRepositoryProvider = FutureProvider<CourseRepository>((ref) async {
  final dataSource = await ref.watch(courseDataSourceProvider.future);

  return CourseRepositoryImpl(dataSource: dataSource);
});

final courseProvider = AsyncNotifierProvider<CourseNotifier, List<Course>>(
  CourseNotifier.new,
);

class CourseNotifier extends AsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() async {
    final repository = await ref.watch(courseRepositoryProvider.future);

    return repository.getCourses();
  }

  Future<void> addCourse(Course course) async {
    try {
      final repository = await ref.read(courseRepositoryProvider.future);
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
      final repository = await ref.read(courseRepositoryProvider.future);
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

      final repository = await ref.read(courseRepositoryProvider.future);
      await repository.deleteCourse(course.id!);
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      debugPrint('The Error: $error');
      debugPrint('The Stack Trace: $stackTrace');
      rethrow;
    }
  }
}
