import 'package:student_app_project/features/semesters/data/models/semester.dart';

abstract interface class SemesterRepository {
  Future<List<Semester>> getSemesters();

  Future<int> insertSemester(Semester semester);

  Future<void> updateSemester(Semester semester);

  Future<void> deleteSemester(int id);
}
