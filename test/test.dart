import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:student_app_project/core/database/database_helper.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';
import 'package:student_app_project/features/courses/presentation/providers/course_provider.dart';

void main() {
  // Initialize SQLite for the test environment.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late ProviderContainer container;

  // Runs before every test.
  setUp(() {
    final testDatabaseName = 'test_${DateTime.now().microsecondsSinceEpoch}.db';

    container = ProviderContainer(
      overrides: [
        databaseHelperProvider.overrideWith(
          (ref) => DatabaseHelper(databaseName: testDatabaseName),
        ),
      ],
    );
  });

  // Runs after every test.
  tearDown(() {
    container.dispose();
  });

  test('initial state is empty', () async {
    final courses = await container.read(courseProvider.future);

    expect(courses, isEmpty);
  });

  test('adds a course', () async {
    final notifier = container.read(courseProvider.notifier);

    final course = Course(code: 'CSC101', name: 'Introduction to Computing');

    await notifier.addCourse(course);

    final courses = await container.read(courseProvider.future);

    expect(courses, hasLength(1));
    expect(courses.first.code, 'CSC101');
    expect(courses.first.name, 'Introduction to Computing');
    expect(courses.first.id, isNotNull);
  });

  test('updates a course', () async {
    final notifier = container.read(courseProvider.notifier);

    final course = Course(code: 'CSC101', name: 'Introduction to Computing');

    await notifier.addCourse(course);

    final courses = await container.read(courseProvider.future);

    final originalId = courses.first.id;

    await notifier.updateCourse(
      Course(id: originalId, code: 'CSC102', name: 'Advanced Computing'),
    );

    final updatedCourses = await container.read(courseProvider.future);

    expect(updatedCourses, hasLength(1));
    expect(updatedCourses.first.code, 'CSC102');
    expect(updatedCourses.first.name, 'Advanced Computing');
    expect(updatedCourses.first.id, originalId);
  });

  test('deletes a course', () async {
    final notifier = container.read(courseProvider.notifier);

    final course = Course(code: 'CSC101', name: 'Introduction to Computing');

    await notifier.addCourse(course);

    final courses = await container.read(courseProvider.future);

    expect(courses, hasLength(1));

    await notifier.deleteCourse(courses.first);

    final remainingCourses = await container.read(courseProvider.future);

    expect(remainingCourses, isEmpty);
  });

  test('cannot update a course without an ID', () async {
    final notifier = container.read(courseProvider.notifier);

    final course = Course(code: 'CSC101', name: 'Introduction to Computing');

    expect(
      () async => await notifier.updateCourse(course),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('cannot delete a course without an ID', () async {
    final notifier = container.read(courseProvider.notifier);

    final course = Course(code: 'CSC101', name: 'Introduction to Computing');

    expect(
      () async => await notifier.deleteCourse(course),
      throwsA(isA<ArgumentError>()),
    );
  });
}
