import 'package:student_app_project/features/schedule/data/data_sources/schedule_repo_interface.dart';
import 'package:student_app_project/features/schedule/data/models/schedule.dart';
import 'package:student_app_project/features/schedule/domain/schedule_validator.dart';

class ScheduleService {
  final ScheduleRepository repository;
  final ScheduleValidator validator;

  const ScheduleService({required this.repository, required this.validator});

  Future<List<Schedule>> getSchedules() {
    return repository.getSchedules();
  }

  Future<Schedule?> getScheduleById(int id) {
    return repository.getScheduleById(id);
  }

  Future<int> addSchedule(Schedule schedule) async {
    final existingSchedules = await repository.getSchedules();

    final errors = validator.validate(
      schedule,
      existingSchedules: existingSchedules,
    );

    if (errors.isNotEmpty) {
      throw ScheduleValidationException(errors);
    }

    return repository.addSchedule(schedule);
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final existingSchedules = await repository.getSchedules();

    final errors = validator.validate(
      schedule,
      existingSchedules: existingSchedules,
    );

    if (errors.isNotEmpty) {
      throw ScheduleValidationException(errors);
    }

    return repository.updateSchedule(schedule);
  }

  Future<int> deleteSchedule(int id) {
    return repository.deleteSchedule(id);
  }
}

//Exception class
class ScheduleValidationException implements Exception {
  final List<String> errors;

  const ScheduleValidationException(this.errors);

  @override
  String toString() => errors.join('\n');
}
