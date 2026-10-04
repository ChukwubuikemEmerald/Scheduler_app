import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app_project/features/courses/presentation/providers/course_provider.dart';
import 'package:student_app_project/features/schedule/data/data_sources/schedule_datasource.dart';
import 'package:student_app_project/features/schedule/data/models/schedule.dart';
import 'package:student_app_project/features/schedule/data/repositories/schedule_repo_impl.dart';
import 'package:student_app_project/features/schedule/domain/schedule_service.dart';
import 'package:student_app_project/features/schedule/domain/schedule_validator.dart';

//Schedule dependency class
class ScheduleDependencies {
  final ScheduleService service;

  const ScheduleDependencies({required this.service});
}

//Provider responsible for all dependencies used in the notifier(basically all dependencies are called and wired in this single provider block)
final scheduleServiceProvider = FutureProvider<ScheduleService>((ref) async {
  final database = await ref.watch(databaseProvider.future);

  final dataSource = ScheduleDataSource(database);

  final repository = ScheduleRepositoryImpl(dataSource);

  const validator = ScheduleValidator();

  return ScheduleService(repository: repository, validator: validator);
});

final scheduleProvider =
    AsyncNotifierProvider<ScheduleNotifier, List<Schedule>>(
      ScheduleNotifier.new,
    );

class ScheduleNotifier extends AsyncNotifier<List<Schedule>> {
  late ScheduleService _service;

  @override
  Future<List<Schedule>> build() async {
    _service = await ref.watch(scheduleServiceProvider.future);

    return _service.getSchedules();
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _service.addSchedule(schedule);

    state = AsyncData(await _service.getSchedules());
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _service.updateSchedule(schedule);

    state = AsyncData(await _service.getSchedules());
  }

  Future<void> deleteSchedule(int id) async {
    await _service.deleteSchedule(id);

    state = AsyncData(await _service.getSchedules());
  }
}
