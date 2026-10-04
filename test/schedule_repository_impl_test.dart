import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_app_project/features/schedule/data/data_sources/schedule_datasource.dart';
import 'package:student_app_project/features/schedule/data/data_sources/schedule_repo_interface.dart';
import 'package:student_app_project/features/schedule/data/models/schedule.dart';
import 'package:student_app_project/features/schedule/data/repositories/schedule_repo_impl.dart';

class MockScheduleDataSource extends Mock implements ScheduleDataSource {}

void main() {
  late MockScheduleDataSource dataSource;
  late ScheduleRepository repository;

  late Schedule schedule;

  setUp(() {
    dataSource = MockScheduleDataSource();
    repository = ScheduleRepositoryImpl(dataSource);

    schedule = Schedule(
      id: 1,
      courseId: 10,
      title: 'Mathematics',
      description: 'Calculus lecture',
      dayOfWeek: 4,
      startTime: 8 * 60,
      endTime: 9 * 60,
      location: 'Room A',
      type: ScheduleType.lecture,
    );
  });

  group('ScheduleRepositoryImpl', () {
    test('getSchedules delegates to data source', () async {
      final schedules = [schedule];

      when(() => dataSource.getSchedules()).thenAnswer((_) async => schedules);

      final result = await repository.getSchedules();

      expect(result, schedules);

      verify(() => dataSource.getSchedules()).called(1);
    });

    test('getScheduleById delegates to data source', () async {
      when(() => dataSource.getScheduleById(1))
          .thenAnswer((_) async => schedule);

      final result = await repository.getScheduleById(1);

      expect(result, schedule);

      verify(() => dataSource.getScheduleById(1)).called(1);
    });

    test('addSchedule delegates to data source', () async {
      when(() => dataSource.insertSchedule(schedule))
          .thenAnswer((_) async => 1);

      final result = await repository.addSchedule(schedule);

      expect(result, 1);

      verify(() => dataSource.insertSchedule(schedule)).called(1);
    });

    test('updateSchedule delegates to data source', () async {
      when(() => dataSource.updateSchedule(schedule))
          .thenAnswer((_) async => 1);

      final result = await repository.updateSchedule(schedule);

      expect(result, 1);

      verify(() => dataSource.updateSchedule(schedule)).called(1);
    });

    test('deleteSchedule delegates to data source', () async {
      when(() => dataSource.deleteSchedule(1)).thenAnswer((_) async => 1);

      final result = await repository.deleteSchedule(1);

      expect(result, 1);

      verify(() => dataSource.deleteSchedule(1)).called(1);
    });
  });
}
