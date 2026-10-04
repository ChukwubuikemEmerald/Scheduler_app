import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final String databaseName;

  DatabaseHelper({this.databaseName = 'courses.db'});

  Future<Database>? _database;

  Future<Database> get database {
    _database ??= _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return openDatabase(
      path,
      version: 4,

      // Enable foreign-key enforcement.
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      // Fresh installation.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE semesters(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            startDate TEXT NOT NULL,
            endDate TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE courses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            semesterId INTEGER,
            code TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            FOREIGN KEY (semesterId) REFERENCES semesters(id)
          )
        ''');

        await db.execute('''
  CREATE TABLE schedules(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  courseId INTEGER,
  title TEXT NOT NULL,
  description TEXT,
  dayOfWeek INTEGER NOT NULL,
  startTime INTEGER NOT NULL,
  endTime INTEGER NOT NULL,
  location TEXT,
  type TEXT NOT NULL,

  FOREIGN KEY (courseId)
    REFERENCES courses(id)
    ON DELETE SET NULL,

  CHECK (dayOfWeek BETWEEN 1 AND 7),
  CHECK (startTime BETWEEN 0 AND 1439),
  CHECK (endTime BETWEEN 1 AND 1440),
  CHECK (endTime > startTime)
''');
      },

      // Existing database upgrades.
      onUpgrade: (db, oldVersion, newVersion) async {
        // ----------------------------------------------------------
        // VERSION 3 MIGRATION
        // Introduced UNIQUE(code) and cleaned duplicate courses.
        // ----------------------------------------------------------

        if (oldVersion < 3) {
          final duplicateCodes = await db.rawQuery('''
            SELECT code
            FROM courses
            GROUP BY code
            HAVING COUNT(*) > 1
          ''');

          for (final row in duplicateCodes) {
            final code = row['code'] as String;

            final result = await db.rawQuery(
              '''
              SELECT MIN(id) AS min_id
              FROM courses
              WHERE code = ?
              ''',
              [code],
            );

            final minId = result.first['min_id'] as int;

            await db.delete(
              'courses',
              where: 'code = ? AND id != ?',
              whereArgs: [code, minId],
            );
          }

          await db.execute('''
            CREATE TABLE courses_new(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              code TEXT NOT NULL UNIQUE,
              name TEXT NOT NULL
            )
          ''');

          await db.execute('''
            INSERT INTO courses_new (id, code, name)
            SELECT id, code, name
            FROM courses
          ''');

          await db.execute('DROP TABLE courses');

          await db.execute('''
            ALTER TABLE courses_new
            RENAME TO courses
          ''');
        }

        // ----------------------------------------------------------
        // VERSION 4 MIGRATION
        // Introduced semesters and Course -> Semester relationship.
        // ----------------------------------------------------------

        if (oldVersion < 4) {
          // 1. Create the table that Course will reference.
          await db.execute('''
            CREATE TABLE semesters(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE,
              startDate TEXT NOT NULL,
              endDate TEXT NOT NULL
            )
          ''');

          // 2. Create the new Course schema.
          //
          // semesterId is intentionally nullable during migration
          // because existing courses don't have semester information.
          await db.execute('''
            CREATE TABLE courses_new(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              semesterId INTEGER,
              code TEXT NOT NULL UNIQUE,
              name TEXT NOT NULL,
              FOREIGN KEY (semesterId) REFERENCES semesters(id)
            )
          ''');

          // 3. Preserve existing courses.
          //
          // Existing courses receive NULL for semesterId.
          await db.execute('''
            INSERT INTO courses_new (
              id,
              semesterId,
              code,
              name
            )
            SELECT
              id,
              NULL,
              code,
              name
            FROM courses
          ''');

          // 4. Remove the old Course table.
          await db.execute('DROP TABLE courses');

          // 5. Replace it with the new schema.
          await db.execute('''
            ALTER TABLE courses_new
            RENAME TO courses
          ''');
        }
        if (oldVersion < 5) {
          // Schedule migration
          await db.execute('''
    CREATE TABLE schedules(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      courseId INTEGER,
      title TEXT NOT NULL,
      description TEXT,
      startTime INTEGER NOT NULL,
      endTime INTEGER NOT NULL,
      location TEXT,
      type TEXT NOT NULL,
      FOREIGN KEY (courseId) REFERENCES courses(id)
        ON DELETE SET NULL,
      CHECK (endTime > startTime)
    )
  ''');
        }
        if (oldVersion < 6) {
          final oldSchedules = await db.query('schedules');

          await db.execute('ALTER TABLE schedules RENAME TO schedules_old');

          await db.execute('''
    CREATE TABLE schedules(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      courseId INTEGER,
      title TEXT NOT NULL,
      description TEXT,
      dayOfWeek INTEGER NOT NULL,
      startTime INTEGER NOT NULL,
      endTime INTEGER NOT NULL,
      location TEXT,
      type TEXT NOT NULL,

      FOREIGN KEY (courseId)
        REFERENCES courses(id)
        ON DELETE SET NULL,

      CHECK (dayOfWeek BETWEEN 1 AND 7),
      CHECK (startTime BETWEEN 0 AND 1439),
      CHECK (endTime BETWEEN 1 AND 1440),
      CHECK (endTime > startTime)
    )
  ''');

          for (final row in oldSchedules) {
            final start = DateTime.fromMillisecondsSinceEpoch(
              row['startTime'] as int,
            );

            final end = DateTime.fromMillisecondsSinceEpoch(
              row['endTime'] as int,
            );

            // Overnight schedules cannot be represented
            // by the new recurring timetable model.
            if (start.year != end.year ||
                start.month != end.month ||
                start.day != end.day) {
              throw StateError(
                'Cannot migrate an overnight schedule: ${row['title']}',
              );
            }

            final startMinutes = start.hour * 60 + start.minute;
            final endMinutes = end.hour * 60 + end.minute;

            await db.insert('schedules', {
              'id': row['id'],
              'courseId': row['courseId'],
              'title': row['title'],
              'description': row['description'],
              'dayOfWeek': start.weekday,
              'startTime': startMinutes,
              'endTime': endMinutes,
              'location': row['location'],
              'type': row['type'],
            });
          }

          await db.execute('DROP TABLE schedules_old');
        }
      },
    );
  }

  Future<void> close() async {
    final db = await _database;

    if (db != null && db.isOpen) {
      await db.close();
    }

    _database = null;
  }
}
