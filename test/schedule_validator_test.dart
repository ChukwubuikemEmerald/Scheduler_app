import 'package:flutter_test/flutter_test.dart';
import 'package:student_app_project/features/schedule/data/models/schedule.dart';
import 'package:student_app_project/features/schedule/domain/schedule_validator.dart';

void main() {
  late ScheduleValidator validator;

  setUp(() {
    validator = const ScheduleValidator();
  });

  Schedule createSchedule({
    int? id,
    int? courseId,
    String title = 'Mathematics',
    String? description = 'Calculus lecture',
    int dayOfWeek = 1,
    int startTime = 8 * 60,
    int endTime = 9 * 60,
    String? location = 'Room A',
    ScheduleType type = ScheduleType.lecture,
  }) {
    return Schedule(
      id: id,
      courseId: courseId,
      title: title,
      description: description,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      location: location,
      type: type,
    );
  }

  group('ScheduleValidator', () {
    test('valid schedule returns no errors', () {
      final schedule = createSchedule();

      final errors = validator.validate(schedule);

      expect(errors, isEmpty);
    });

    test('empty title returns an error', () {
      final schedule = createSchedule(title: '');

      final errors = validator.validate(schedule);

      expect(errors, contains('Title cannot be empty.'));
    });

    test('whitespace-only title returns an error', () {
      final schedule = createSchedule(title: '   ');

      final errors = validator.validate(schedule);

      expect(errors, contains('Title cannot be empty.'));
    });

    test('dayOfWeek below 1 returns an error', () {
      final schedule = createSchedule(dayOfWeek: 0);

      final errors = validator.validate(schedule);

      expect(errors, contains('Day of week must be between 1 and 7.'));
    });

    test('dayOfWeek above 7 returns an error', () {
      final schedule = createSchedule(dayOfWeek: 8);

      final errors = validator.validate(schedule);

      expect(errors, contains('Day of week must be between 1 and 7.'));
    });

    test('start time below 0 returns an error', () {
      final schedule = createSchedule(startTime: -1);

      final errors = validator.validate(schedule);

      expect(errors, contains('Start time must be between 00:00 and 23:59.'));
    });

    test('start time above 1439 returns an error', () {
      final schedule = createSchedule(startTime: 1440);

      final errors = validator.validate(schedule);

      expect(errors, contains('Start time must be between 00:00 and 23:59.'));
    });

    test('end time below 1 returns an error', () {
      final schedule = createSchedule(endTime: 0);

      final errors = validator.validate(schedule);

      expect(errors, contains('End time must be between 00:01 and 24:00.'));
    });

    test('end time above 1440 returns an error', () {
      final schedule = createSchedule(endTime: 1441);

      final errors = validator.validate(schedule);

      expect(errors, contains('End time must be between 00:01 and 24:00.'));
    });

    test('end time equal to start time is invalid', () {
      final schedule = createSchedule(startTime: 9 * 60, endTime: 9 * 60);

      final errors = validator.validate(schedule);

      expect(errors, contains('End time must be after start time.'));
    });

    test('end time before start time is invalid', () {
      final schedule = createSchedule(startTime: 10 * 60, endTime: 9 * 60);

      final errors = validator.validate(schedule);

      expect(errors, contains('End time must be after start time.'));
    });

    test('overlapping schedules on the same day are invalid', () {
      final existing = createSchedule(
        id: 1,
        dayOfWeek: 1,
        startTime: 8 * 60,
        endTime: 9 * 60,
      );

      final newSchedule = createSchedule(
        id: 2,
        dayOfWeek: 1,
        startTime: 8 * 60 + 30,
        endTime: 10 * 60,
      );

      final errors = validator.validate(
        newSchedule,
        existingSchedules: [existing],
      );

      expect(errors, contains('Schedule overlaps with another schedule.'));
    });

    test('schedule starting inside another schedule is invalid', () {
      final existing = createSchedule(
        id: 1,
        startTime: 8 * 60,
        endTime: 10 * 60,
      );

      final newSchedule = createSchedule(
        id: 2,
        startTime: 9 * 60,
        endTime: 11 * 60,
      );

      final errors = validator.validate(
        newSchedule,
        existingSchedules: [existing],
      );

      expect(errors, contains('Schedule overlaps with another schedule.'));
    });

    test('schedule completely inside another schedule is invalid', () {
      final existing = createSchedule(
        id: 1,
        startTime: 8 * 60,
        endTime: 11 * 60,
      );

      final newSchedule = createSchedule(
        id: 2,
        startTime: 9 * 60,
        endTime: 10 * 60,
      );

      final errors = validator.validate(
        newSchedule,
        existingSchedules: [existing],
      );

      expect(errors, contains('Schedule overlaps with another schedule.'));
    });

    test(
      'overlap where new schedule contains existing schedule is invalid',
      () {
        final existing = createSchedule(
          id: 1,
          startTime: 9 * 60,
          endTime: 10 * 60,
        );

        final newSchedule = createSchedule(
          id: 2,
          startTime: 8 * 60,
          endTime: 11 * 60,
        );

        final errors = validator.validate(
          newSchedule,
          existingSchedules: [existing],
        );

        expect(errors, contains('Schedule overlaps with another schedule.'));
      },
    );

    test('back-to-back schedules are allowed', () {
      final existing = createSchedule(
        id: 1,
        startTime: 8 * 60,
        endTime: 9 * 60,
      );

      final newSchedule = createSchedule(
        id: 2,
        startTime: 9 * 60,
        endTime: 10 * 60,
      );

      final errors = validator.validate(
        newSchedule,
        existingSchedules: [existing],
      );

      expect(errors, isEmpty);
    });

    test('schedules on different days do not overlap', () {
      final existing = createSchedule(
        id: 1,
        dayOfWeek: 1,
        startTime: 8 * 60,
        endTime: 10 * 60,
      );

      final newSchedule = createSchedule(
        id: 2,
        dayOfWeek: 2,
        startTime: 8 * 60 + 30,
        endTime: 9 * 60 + 30,
      );

      final errors = validator.validate(
        newSchedule,
        existingSchedules: [existing],
      );

      expect(errors, isEmpty);
    });

    test('schedule does not overlap with itself during editing', () {
      final schedule = createSchedule(
        id: 5,
        startTime: 8 * 60,
        endTime: 10 * 60,
      );

      final errors = validator.validate(
        schedule,
        existingSchedules: [schedule],
      );

      expect(errors, isEmpty);
    });

    test('multiple validation errors can be returned', () {
      final schedule = createSchedule(
        title: '',
        dayOfWeek: 0,
        startTime: 1500,
        endTime: 1400,
      );

      final errors = validator.validate(schedule);

      expect(errors, hasLength(greaterThan(1)));
      expect(errors, contains('Title cannot be empty.'));
      expect(errors, contains('Day of week must be between 1 and 7.'));
      expect(errors, contains('Start time must be between 00:00 and 23:59.'));
      expect(errors, contains('End time must be after start time.'));
    });
  });
}
