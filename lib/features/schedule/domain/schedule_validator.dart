
import 'package:student_app_project/features/schedule/data/models/schedule.dart';

class ScheduleValidator {
  const ScheduleValidator();

  List<String> validate(
    Schedule schedule, {
    List<Schedule> existingSchedules = const [],
  }) {
    final errors = <String>[];

    if (schedule.title.trim().isEmpty) {
      errors.add('Title cannot be empty.');
    }

    if (schedule.dayOfWeek < 1 || schedule.dayOfWeek > 7) {
      errors.add('Day of week must be between 1 and 7.');
    }

    if (schedule.startTime < 0 || schedule.startTime > 1439) {
      errors.add('Start time must be between 00:00 and 23:59.');
    }

    if (schedule.endTime < 1 || schedule.endTime > 1440) {
      errors.add('End time must be between 00:01 and 24:00.');
    }

    if (schedule.endTime <= schedule.startTime) {
      errors.add('End time must be after start time.');
    }

    if (hasOverlap(schedule, existingSchedules)) {
      errors.add('Schedule overlaps with another schedule.');
    }

    return errors;
  }

  bool hasOverlap(
    Schedule schedule,
    List<Schedule> existingSchedules,
  ) {
    return existingSchedules.any((existing) {
      // Ignore the schedule itself when editing.
      if (schedule.id != null && existing.id == schedule.id) {
        return false;
      }

      // Different days cannot overlap.
      if (existing.dayOfWeek != schedule.dayOfWeek) {
        return false;
      }

      return existing.startTime < schedule.endTime &&
          existing.endTime > schedule.startTime;
    });
  }
}