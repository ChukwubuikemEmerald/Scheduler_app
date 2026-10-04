import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:student_app_project/core/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('migrates duplicate course codes', () async {
    await deleteDatabase('migration_test.db');

    final database = await openDatabase(
      'migration_test.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE courses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          code TEXT NOT NULL,
          name TEXT NOT NULL
        )
      ''');
      },
    );

    await database.insert('courses', {
      'code': 'CSC101',
      'name': 'Introduction to Computing',
    });

    await database.insert('courses', {
      'code': 'CSC101',
      'name': 'Computer Fundamentals',
    });

    await database.close();

    // Next step: reopen as version 2.

    final helper = DatabaseHelper(databaseName: 'migration_test.db');

    final migratedDatabase = await helper.database;

    final courses = await migratedDatabase.query('courses');

    expect(courses, hasLength(1));
    expect(courses.first['code'], 'CSC101');
    expect(courses.first['name'], 'Introduction to Computing');

    //Verifing version 2 constraints
    expect(
      () => migratedDatabase.insert('courses', {
        'code': 'CSC101',
        'name': 'Another CSC101',
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('migrates v3 database to v4 and preserves courses', () async {
    const databaseName = 'v3_to_v4_test.db';

    // Start with a completely clean test database.
    await databaseFactory.deleteDatabase(databaseName);

    // ------------------------------------------------------------
    // Create a VERSION 3 database manually.
    // ------------------------------------------------------------
    final db = await databaseFactory.openDatabase(
      databaseName,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE courses(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              code TEXT NOT NULL UNIQUE,
              name TEXT NOT NULL
            )
          ''');
        },
      ),
    );

    // Insert legacy courses.
    final cscId = await db.insert('courses', {
      'code': 'CSC101',
      'name': 'Programming',
    });

    final matId = await db.insert('courses', {
      'code': 'MAT101',
      'name': 'Mathematics',
    });

    await db.close();

    // ------------------------------------------------------------
    // Open the SAME database using our production DatabaseHelper.
    // DatabaseHelper is now version 4, so v3 -> v4 migration runs.
    // ------------------------------------------------------------
    final helper = DatabaseHelper(databaseName: databaseName);

    final migratedDb = await helper.database;

    // ------------------------------------------------------------
    // TEST 1: Existing courses survived the migration.
    // ------------------------------------------------------------
    final courses = await migratedDb.query('courses', orderBy: 'id ASC');

    expect(courses, hasLength(2));

    expect(courses[0]['id'], cscId);
    expect(courses[0]['code'], 'CSC101');
    expect(courses[0]['name'], 'Programming');

    expect(courses[1]['id'], matId);
    expect(courses[1]['code'], 'MAT101');
    expect(courses[1]['name'], 'Mathematics');

    // Existing courses don't know their semester yet.
    expect(courses[0]['semesterId'], isNull);
    expect(courses[1]['semesterId'], isNull);

    // ------------------------------------------------------------
    // TEST 2: The semesters table exists.
    // ------------------------------------------------------------
    final semesterTable = await migratedDb.rawQuery('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      AND name = 'semesters'
    ''');

    expect(semesterTable, hasLength(1));

    // ------------------------------------------------------------
    // TEST 3: We can create a semester.
    // ------------------------------------------------------------
    final semesterId = await migratedDb.insert('semesters', {
      'name': '2026 First Semester',
      'startDate': '2026-01-01',
      'endDate': '2026-06-30',
    });

    expect(semesterId, greaterThan(0));

    // ------------------------------------------------------------
    // TEST 4: We can assign an existing course to that semester.
    // ------------------------------------------------------------
    await migratedDb.update(
      'courses',
      {'semesterId': semesterId},
      where: 'id = ?',
      whereArgs: [cscId],
    );

    final updatedCourse = await migratedDb.query(
      'courses',
      where: 'id = ?',
      whereArgs: [cscId],
    );

    expect(updatedCourse.first['semesterId'], semesterId);

    // ------------------------------------------------------------
    // TEST 5: Foreign-key constraint works.
    //
    // Semester 999 does not exist, so this should fail.
    // ------------------------------------------------------------
    expect(
      () => migratedDb.insert('courses', {
        'semesterId': 999,
        'code': 'CSC999',
        'name': 'Invalid Course',
      }),
      throwsA(isA<DatabaseException>()),
    );

    // Clean up.
    await helper.close();
    await databaseFactory.deleteDatabase(databaseName);
  });
}
