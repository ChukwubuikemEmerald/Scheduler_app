import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app_project/features/courses/presentation/providers/course_provider.dart';
import 'package:student_app_project/features/semesters/data/datascources/semester_data_source.dart';
import 'package:student_app_project/features/semesters/data/datascources/semester_data_source_interface.dart';
import 'package:student_app_project/features/semesters/data/models/semester.dart';
import 'package:student_app_project/features/semesters/data/repositories/semester_repository_impl.dart';
import 'package:student_app_project/features/semesters/domain/semester_repository.dart';

final semesterDataSourceProvider = Provider<SemesterDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);

  return SemesterDataSourceImpl(databaseHelper);
});

final semesterRepositoryProvider = Provider<SemesterRepository>((ref) {
  final dataSource = ref.watch(semesterDataSourceProvider);

  return SemesterRepositoryImpl(dataSource);
});

final semesterProvider =
    AsyncNotifierProvider<SemesterNotifier, List<Semester>>(
      SemesterNotifier.new,
    );

class SemesterNotifier extends AsyncNotifier<List<Semester>> {
  @override
  Future<List<Semester>> build() async {
    final repository = ref.watch(semesterRepositoryProvider);

    return repository.getSemesters();
  }

  Future<void> addSemester(Semester semester) async {
    final repository = ref.read(semesterRepositoryProvider);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await repository.insertSemester(semester);
      return repository.getSemesters();
    });
  }

  Future<void> updateSemester(Semester semester) async {
    final repository = ref.read(semesterRepositoryProvider);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await repository.updateSemester(semester);
      return repository.getSemesters();
    });
  }

  Future<void> deleteSemester(int id) async {
    final repository = ref.read(semesterRepositoryProvider);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await repository.deleteSemester(id);
      return repository.getSemesters();
    });
  }
}
