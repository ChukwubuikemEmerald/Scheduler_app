import 'package:sqflite/sqflite.dart';
import 'package:student_app_project/features/schedule/data/models/schedule.dart';


class ScheduleDataSource {
  final Database db;

  ScheduleDataSource(this.db);

  Future<List<Schedule>> getSchedules() async {
    final result = await db.query('schedules');

    return result
        .map((map) => Schedule.fromMap(map))
        .toList();
  }

  Future<Schedule?> getScheduleById(int id) async {
    final result = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Schedule.fromMap(result.first);
  }

  Future<int> insertSchedule(Schedule schedule) async {
    return await db.insert(
      'schedules',
      schedule.toMap(),
    );
  }

  Future<int> updateSchedule(Schedule schedule) async {
    if (schedule.id == null) {
      throw ArgumentError(
        'Cannot update a schedule without an id.',
      );
    }

    return await db.update(
      'schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteSchedule(int id) async {
    return await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}