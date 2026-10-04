import 'package:student_app_project/features/schedule/data/models/schedule.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getSchedules();

  Future<Schedule?> getScheduleById(int id);

  Future<int> addSchedule(Schedule schedule);

  Future<int> updateSchedule(Schedule schedule);

  Future<int> deleteSchedule(int id);
}
