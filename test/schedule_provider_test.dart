import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_app_project/features/schedule/data/models/schedule.dart';
import 'package:student_app_project/features/schedule/domain/schedule_service.dart';
import 'package:student_app_project/features/schedule/presentation/providers/schedule_provider.dart';

class MockScheduleService extends Mock implements ScheduleService {}

void main() {
  late MockScheduleService service;

  late Schedule mathematics;
  late Schedule physics;

  setUp(() {
    service = MockScheduleService();

    mathematics = const Schedule(
      id: 1,
      courseId: 10,
      title: 'Mathematics',
      description: 'Calculus lecture',
      dayOfWeek: 1,
      startTime: 8 * 60,
      endTime: 9 * 60,
      location: 'Room A',
      type: ScheduleType.lecture,
    );

    physics = const Schedule(
      id: 2,
      courseId: 11,
      title: 'Physics',
      description: 'Mechanics lecture',
      dayOfWeek: 1,
      startTime: 10 * 60,
      endTime: 11 * 60,
      location: 'Room B',
      type: ScheduleType.lecture,
    );
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [scheduleServiceProvider.overrideWith((ref) async => service)],
    );
  }

  group('ScheduleNotifier', () {
    test('build loads schedules from ScheduleService', () async {
      when(() => service.getSchedules()).thenAnswer((_) async => [mathematics]);

      final container = createContainer();
      addTearDown(container.dispose);

      final result = await container.read(scheduleProvider.future);

      expect(result, [mathematics]);

      verify(() => service.getSchedules()).called(1);
    });

    test('addSchedule adds the schedule and refreshes state', () async {
      final schedules = <Schedule>[mathematics];

      when(() => service.getSchedules())
          .thenAnswer((_) async => List<Schedule>.from(schedules));

      when(() => service.addSchedule(physics)).thenAnswer((_) async {
        schedules.add(physics);
        return physics.id!;
      });

      final container = createContainer();
      addTearDown(container.dispose);

      // Initial build.
      await container.read(scheduleProvider.future);

      // Add the new schedule.
      await container.read(scheduleProvider.notifier).addSchedule(physics);

      final state = container.read(scheduleProvider);

      expect(state, isA<AsyncData<List<Schedule>>>());

      final result = state.requireValue;

      expect(result, [mathematics, physics]);

      verify(() => service.addSchedule(physics)).called(1);

      verify(() => service.getSchedules()).called(2);
    });

    test('updateSchedule updates the schedule and refreshes state', () async {
      var schedules = <Schedule>[mathematics];

      final updatedMathematics = Schedule(
        id: mathematics.id,
        courseId: mathematics.courseId,
        title: 'Advanced Mathematics',
        description: mathematics.description,
        dayOfWeek: mathematics.dayOfWeek,
        startTime: mathematics.startTime,
        endTime: mathematics.endTime,
        location: mathematics.location,
        type: mathematics.type,
      );

      when(() => service.getSchedules())
          .thenAnswer((_) async => List<Schedule>.from(schedules));

      when(() => service.updateSchedule(updatedMathematics))
          .thenAnswer((_) async {
            schedules = [updatedMathematics];
            return updatedMathematics.id!;
          });

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(scheduleProvider.future);

      await container
          .read(scheduleProvider.notifier)
          .updateSchedule(updatedMathematics);

      final state = container.read(scheduleProvider);

      expect(state, isA<AsyncData<List<Schedule>>>());

      final result = state.requireValue;

      expect(result, [updatedMathematics]);

      verify(() => service.updateSchedule(updatedMathematics)).called(1);

      verify(() => service.getSchedules()).called(2);
    });

    test('deleteSchedule deletes the schedule and refreshes state', () async {
      final schedules = <Schedule>[mathematics, physics];

      when(() => service.getSchedules())
          .thenAnswer((_) async => List<Schedule>.from(schedules));

      when(() => service.deleteSchedule(mathematics.id!)).thenAnswer((_) async {
        schedules.removeWhere((schedule) => schedule.id == mathematics.id);

        return 1;
      });

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(scheduleProvider.future);

      await container
          .read(scheduleProvider.notifier)
          .deleteSchedule(mathematics.id!);

      final state = container.read(scheduleProvider);

      expect(state, isA<AsyncData<List<Schedule>>>());

      final result = state.requireValue;

      expect(result, [physics]);

      verify(() => service.deleteSchedule(mathematics.id!)).called(1);

      verify(() => service.getSchedules()).called(2);
    });
  });
}
