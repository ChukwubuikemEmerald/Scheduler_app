import 'package:flutter_test/flutter_test.dart';
import 'package:student_app_project/features/schedule/data/models/schedule.dart';

void main() {
  group('Schedule model', () {
    test('toMap and fromMap round trip preserve values', () {
      final schedule = Schedule(
        id: 1,
        courseId: 10,
        title: 'Mathematics',
        description: 'Calculus lecture',
        dayOfWeek: 7,
        startTime: 8 * 60,
        endTime: 9 * 60,
        location: 'Room A',
        type: ScheduleType.lecture,
      );

      final map = schedule.toMap();
      final fromMap = Schedule.fromMap(map);

      // Map values
      expect(map['id'], 1);
      expect(map['courseId'], 10);
      expect(map['title'], 'Mathematics');
      expect(map['description'], 'Calculus lecture');
      expect(map['dayOfWeek'], 7);
      expect(map['startTime'], 8 * 60);
      expect(map['endTime'], 9 * 60);
      expect(map['location'], 'Room A');
      expect(map['type'], 'lecture');

      // Reconstructed Schedule values
      expect(fromMap.id, 1);
      expect(fromMap.courseId, 10);
      expect(fromMap.title, 'Mathematics');
      expect(fromMap.description, 'Calculus lecture');
      expect(fromMap.dayOfWeek, 7);
      expect(fromMap.startTime, 8 * 60);
      expect(fromMap.endTime, 9 * 60);
      expect(fromMap.location, 'Room A');
      expect(fromMap.type, ScheduleType.lecture);
    });
  });
}
