import 'package:student_app_project/features/semesters/data/datascources/semester_data_source_interface.dart';
import 'package:student_app_project/features/semesters/data/models/semester.dart';
import 'package:student_app_project/features/semesters/domain/semester_repository.dart';

class SemesterRepositoryImpl implements SemesterRepository {
  final SemesterDataSource dataSource;

  SemesterRepositoryImpl(this.dataSource);

  @override
  Future<List<Semester>> getSemesters() {
    return dataSource.getSemesters();
  }

  @override
  Future<int> insertSemester(Semester semester) {
    return dataSource.insertSemester(semester);
  }

  @override
  Future<void> updateSemester(Semester semester) {
    return dataSource.updateSemester(semester);
  }

  @override
  Future<void> deleteSemester(int id) {
    return dataSource.deleteSemester(id);
  }
}
