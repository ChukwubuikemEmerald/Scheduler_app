import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app_project/features/courses/data/data_sources/datasource_interface.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';
import 'package:student_app_project/features/courses/presentation/providers/course_provider.dart';

class FakeCourseRepository implements CourseRepository {
  final List<Course> _courses = [];

  @override
  Future<List<Course>> getCourses() async {
    return _courses;
  }

  @override
  Future<int> insertCourse(Course course) async {
    final id = _courses.length + 1;

    _courses.add(Course(id: id, code: course.code, name: course.name));

    return id;
  }

  @override
  Future<void> updateCourse(Course course) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    _courses.removeWhere((c) => c.id == id);
  }
}

//Failure case repo

class FailingCourseRepository implements CourseRepository {
  @override
  Future<List<Course>> getCourses() async {
    throw Exception('Failed to load courses');
  }

  @override
  Future<int> insertCourse(Course course) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCourse(Course course) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCourse(int id) async {
    throw UnimplementedError();
  }
}
//TEST

void main() {
  test('load courses from a fake repository', () async {
    final fakeRepository = FakeCourseRepository();
    final container = ProviderContainer(
      overrides: [
        courseRepositoryProvider.overrideWith((ref) => fakeRepository),
      ],
    );
    await fakeRepository.insertCourse(
      Course(code: 'BST', name: 'Bible studies'),
    );
    await fakeRepository.insertCourse(
      Course(code: 'GST', name: 'General studies'),
    );

    final courses = await container.read(courseProvider.future);

    expect(courses, hasLength(2));
    expect(courses.first.code, 'BST');
    expect(courses.last.code, 'GST');

    container.dispose();
  });
  test('load courses from the failure case repository', () async {
    final failingRepository = FailingCourseRepository();
    final container = ProviderContainer(
      retry: (retryCount, error) => null,

      overrides: [
        courseRepositoryProvider.overrideWith((ref) => failingRepository),
      ],
    );
    try {
      await container.read(courseProvider.future);
    } catch (error) {
      //
    }
    final state = container.read(courseProvider);

    expect(state, isA<AsyncError<List<Course>>>());

    container.dispose();
  });

  test('adds a course using the repository', () async {
    final fakeRepository = FakeCourseRepository();

    final container = ProviderContainer(
      overrides: [
        courseRepositoryProvider.overrideWith((ref) => fakeRepository),
      ],
    );
    final course = Course(code: 'CSC101', name: 'Introduction to Computing');
    final notifier = container.read(courseProvider.notifier);
    await notifier.addCourse(course);
    final courses = await fakeRepository.getCourses();
    expect(courses, hasLength(1));
    expect(courses.first.code, 'CSC101');
    expect(courses.first.name, 'Introduction to Computing');
    container.dispose();
  });

  test('adds a course using the failing repository', () async {
    final failingRepository = FailingCourseRepository();

    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        courseRepositoryProvider.overrideWith((ref) => failingRepository),
      ],
    );

    final course = Course(code: 'CSC101', name: 'Introduction to Computing');

    final notifier = container.read(courseProvider.notifier);

    expect(
      () => notifier.addCourse(course),
      throwsA(isA<UnimplementedError>()),
    );

    container.dispose();
  });
}
