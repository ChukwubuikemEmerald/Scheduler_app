import 'package:student_app_project/core/database/database_helper.dart';
import 'package:student_app_project/features/semesters/data/models/semester.dart';

import 'semester_data_source_interface.dart';

class SemesterDataSourceImpl implements SemesterDataSource {
  final DatabaseHelper databaseHelper;

  SemesterDataSourceImpl(this.databaseHelper);

  @override
  Future<List<Semester>> getSemesters() async {
    final db = await databaseHelper.database;

    final result = await db.query('semesters', orderBy: 'startDate ASC');

    return result.map(Semester.fromMap).toList();
  }

  @override
  Future<int> insertSemester(Semester semester) async {
    final db = await databaseHelper.database;

    return db.insert('semesters', semester.toMap());
  }

  @override
  Future<void> updateSemester(Semester semester) async {
    final db = await databaseHelper.database;

    await db.update(
      'semesters',
      semester.toMap(),
      where: 'id = ?',
      whereArgs: [semester.id],
    );
  }

  @override
  Future<void> deleteSemester(int id) async {
    final db = await databaseHelper.database;

    await db.delete('semesters', where: 'id = ?', whereArgs: [id]);
  }
}
