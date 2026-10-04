import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app_project/features/semesters/data/models/semester.dart';
import 'package:student_app_project/features/semesters/domain/semester_repository.dart';
import 'package:student_app_project/features/semesters/presentation/providers/semester_provider.dart';

class FakeSemesterRepository implements SemesterRepository {
  final List<Semester> _semesters = [];

  @override
  Future<List<Semester>> getSemesters() async {
    return List.unmodifiable(_semesters);
  }

  @override
  Future<int> insertSemester(Semester semester) async {
    final id = _semesters.length + 1;

    _semesters.add(
      Semester(
        id: id,
        name: semester.name,
        startDate: semester.startDate,
        endDate: semester.endDate,
      ),
    );

    return id;
  }

  @override
  Future<void> updateSemester(Semester semester) async {
    final index = _semesters.indexWhere((item) => item.id == semester.id);

    if (index != -1) {
      _semesters[index] = semester;
    }
  }

  @override
  Future<void> deleteSemester(int id) async {
    _semesters.removeWhere((item) => item.id == id);
  }
}

void main() {
  late FakeSemesterRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeSemesterRepository();

    container = ProviderContainer(
      overrides: [semesterRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('loads semesters', () async {
    await repository.insertSemester(
      Semester(
        name: 'Fall 2026',
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 12, 15),
      ),
    );

    final value = await container.read(semesterProvider.future);

    expect(value, hasLength(1));
    expect(value.first.name, 'Fall 2026');
  });

  test('adds semester', () async {
    final notifier = container.read(semesterProvider.notifier);

    await notifier.addSemester(
      Semester(
        name: 'Fall 2026',
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 12, 15),
      ),
    );

    final semesters = await container.read(semesterProvider.future);

    expect(semesters, hasLength(1));
    expect(semesters.first.name, 'Fall 2026');
  });

  test('updates semester', () async {
    final id = await repository.insertSemester(
      Semester(
        name: 'Fall 2026',
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 12, 15),
      ),
    );

    final notifier = container.read(semesterProvider.notifier);

    await notifier.updateSemester(
      Semester(
        id: id,
        name: 'Spring 2027',
        startDate: DateTime(2027, 1, 1),
        endDate: DateTime(2027, 5, 30),
      ),
    );

    final semesters = await container.read(semesterProvider.future);

    expect(semesters.first.name, 'Spring 2027');
  });

  test('deletes semester', () async {
    final id = await repository.insertSemester(
      Semester(
        name: 'Fall 2026',
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 12, 15),
      ),
    );

    final notifier = container.read(semesterProvider.notifier);

    await notifier.deleteSemester(id);

    final semesters = await container.read(semesterProvider.future);

    expect(semesters, isEmpty);
  });
}
