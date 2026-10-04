import 'package:flutter_test/flutter_test.dart';
import 'package:student_app_project/features/semesters/data/models/semester.dart';
import 'package:student_app_project/features/semesters/domain/semester_repository.dart';

class FakeRepo implements SemesterRepository {
  final List<Semester> _semester = [];

  @override
  Future<List<Semester>> getSemesters() async {
    return _semester;
  }

  @override
  Future<int> insertSemester(Semester semester) async {
    final id = _semester.length + 1;
    _semester.add(
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
    final index = _semester.indexWhere((c) => c.id == semester.id);
    if (index != -1) {
      _semester[index] = semester;
    }
  }

  @override
  Future<void> deleteSemester(int id) async {
    _semester.removeWhere((c) => c.id == id);
  }
}

void main() {
  late FakeRepo repository;

  setUp(() {
    repository = FakeRepo();
  });

  group('Semester Repository Tests', () {
    test('insertSemester adds a new semester and returns its ID', () async {
      final newSemester = Semester(
        id: 0,
        name: 'Fall 2026',
        startDate: DateTime(2026 - 09 - 01),
        endDate: DateTime(2026 - 12 - 15),
      );

      final assignedId = await repository.insertSemester(newSemester);
      final semesters = await repository.getSemesters();

      expect(assignedId, equals(1));
      expect(semesters.length, equals(1));
      expect(semesters.first.name, equals('Fall 2026'));
    });

    test('updateSemester modifies an existing semester', () async {
      final initialSemester = Semester(
        id: 0,
        name: 'Fall 2026',
        startDate: DateTime(2026, 09, 01),
        endDate: DateTime(2026, 12, 15),
      );
      final assignedId = await repository.insertSemester(initialSemester);

      final updatedSemester = Semester(
        id: assignedId,
        name: 'Spring 2027',
        startDate: DateTime(2026, 09, 01),
        endDate: DateTime(2026, 12, 15),
      );
      await repository.updateSemester(updatedSemester);

      final semesters = await repository.getSemesters();
      expect(semesters.first.name, equals('Spring 2027'));
    });

    test('deleteSemester completely removes the item by ID', () async {
      final semester = Semester(
        id: 0,
        name: 'Summer 2026',
        startDate: DateTime(2026, 06, 01),
        endDate: DateTime(2026, 08, 15),
      );
      final assignedId = await repository.insertSemester(semester);

      var currentSemesters = await repository.getSemesters();
      expect(currentSemesters.length, equals(1));

      await repository.deleteSemester(assignedId);

      currentSemesters = await repository.getSemesters();
      expect(currentSemesters.isEmpty, isTrue);
    });
  });
}
