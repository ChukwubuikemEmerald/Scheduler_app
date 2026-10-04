import 'package:student_app_project/features/schedule/data/data_sources/schedule_datasource.dart';
import 'package:student_app_project/features/schedule/data/data_sources/schedule_repo_interface.dart';
import 'package:student_app_project/features/schedule/data/models/schedule.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleDataSource dataSource;

  ScheduleRepositoryImpl(this.dataSource);

  @override
  Future<List<Schedule>> getSchedules() {
    return dataSource.getSchedules();
  }

  @override
  Future<Schedule?> getScheduleById(int id) {
    return dataSource.getScheduleById(id);
  }

  @override
  Future<int> addSchedule(Schedule schedule) {
    return dataSource.insertSchedule(schedule);
  }

  @override
  Future<int> updateSchedule(Schedule schedule) {
    return dataSource.updateSchedule(schedule);
  }

  @override
  Future<int> deleteSchedule(int id) {
    return dataSource.deleteSchedule(id);
  }
}
