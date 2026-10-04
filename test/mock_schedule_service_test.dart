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
      retry: (retryCount, error) => null,
      overrides: [scheduleServiceProvider.overrideWith((ref) async => service)],
    );
  }

  group('ScheduleNotifier error behavior', () {
    test('initial load failure produces AsyncError', () async {
      final exception = Exception('Database failed');

      when(() => service.getSchedules()).thenThrow(exception);

      final container = ProviderContainer(
        retry: (retryCount, error) => null,
        overrides: [
          scheduleServiceProvider.overrideWith((ref) async => service),
        ],
      );

      addTearDown(container.dispose);

      await expectLater(
        container.read(scheduleProvider.future),
        throwsA(same(exception)),
      );

      final state = container.read(scheduleProvider);

      expect(state, isA<AsyncError<List<Schedule>>>());

      final errorState = state as AsyncError<List<Schedule>>;

      expect(errorState.error, same(exception));

      verify(() => service.getSchedules()).called(1);
    });

    test(
      'validation failure does not replace existing schedule state',
      () async {
        final validationException = ScheduleValidationException([
          'Schedule overlaps with another schedule.',
        ]);

        when(() => service.getSchedules())
            .thenAnswer((_) async => [mathematics]);

        when(() => service.addSchedule(physics)).thenThrow(validationException);

        final container = createContainer();
        addTearDown(container.dispose);

        // Initial successful load.
        await container.read(scheduleProvider.future);

        // Mutation fails validation.
        expect(
          () => container.read(scheduleProvider.notifier).addSchedule(physics),
          throwsA(validationException),
        );

        final state = container.read(scheduleProvider);

        // The existing list should remain intact.
        expect(state, isA<AsyncData<List<Schedule>>>());
        expect(state.requireValue, [mathematics]);

        // Because validation failed, there should be no refresh.
        verify(() => service.getSchedules()).called(1);

        verify(() => service.addSchedule(physics)).called(1);
      },
    );

    test(
      'unexpected mutation failure does not replace existing schedule state',
      () async {
        final exception = Exception('Unexpected database failure');

        when(() => service.getSchedules())
            .thenAnswer((_) async => [mathematics]);

        when(() => service.deleteSchedule(mathematics.id!))
            .thenThrow(exception);

        final container = createContainer();
        addTearDown(container.dispose);

        // Initial successful load.
        await container.read(scheduleProvider.future);

        // Mutation fails unexpectedly.
        expect(
          () => container
              .read(scheduleProvider.notifier)
              .deleteSchedule(mathematics.id!),
          throwsA(exception),
        );

        final state = container.read(scheduleProvider);

        // Existing state remains intact.
        expect(state, isA<AsyncData<List<Schedule>>>());
        expect(state.requireValue, [mathematics]);

        // No refresh because deletion never succeeded.
        verify(() => service.getSchedules()).called(1);

        verify(() => service.deleteSchedule(mathematics.id!)).called(1);
      },
    );
  });
}
