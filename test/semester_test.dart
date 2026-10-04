import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:student_app_project/core/database/database_helper.dart';
import 'package:student_app_project/features/semesters/data/models/semester.dart';
import 'package:student_app_project/features/semesters/data/datascources/semester_data_source.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Semester data source performs CRUD operations', () async {
    const databaseName = 'semester_data_source_test.db';

    await databaseFactory.deleteDatabase(databaseName);

    final databaseHelper = DatabaseHelper(databaseName: databaseName);

    final dataSource = SemesterDataSourceImpl(databaseHelper);

    // CREATE
    final firstSemester = Semester(
      name: '2026 First Semester',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 6, 30),
    );

    final firstId = await dataSource.insertSemester(firstSemester);

    expect(firstId, greaterThan(0));

    // READ
    final semesters = await dataSource.getSemesters();

    expect(semesters, hasLength(1));
    expect(semesters.first.id, firstId);
    expect(semesters.first.name, '2026 First Semester');
    expect(semesters.first.startDate, DateTime(2026, 1, 1));
    expect(semesters.first.endDate, DateTime(2026, 6, 30));

    // UPDATE
    final updatedSemester = Semester(
      id: firstId,
      name: '2026 Updated Semester',
      startDate: DateTime(2026, 2, 1),
      endDate: DateTime(2026, 7, 31),
    );

    await dataSource.updateSemester(updatedSemester);

    final updatedSemesters = await dataSource.getSemesters();

    expect(updatedSemesters, hasLength(1));
    expect(updatedSemesters.first.name, '2026 Updated Semester');
    expect(updatedSemesters.first.startDate, DateTime(2026, 2, 1));
    expect(updatedSemesters.first.endDate, DateTime(2026, 7, 31));

    // DELETE
    await dataSource.deleteSemester(firstId);

    final remainingSemesters = await dataSource.getSemesters();

    expect(remainingSemesters, isEmpty);

    await databaseHelper.close();
    await databaseFactory.deleteDatabase(databaseName);
  });
}
