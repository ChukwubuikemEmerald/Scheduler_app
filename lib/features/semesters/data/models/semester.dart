import 'package:uuid/uuid.dart';

class Semester {
  final int? id;
  final String syncId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  Semester({
    this.id,
    String? syncId,
    required this.name,
    required this.startDate,
    required this.endDate,
  }) : syncId = syncId ?? Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'sync_id': syncId,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

  factory Semester.fromMap(Map<String, dynamic> map) => Semester(
        id: map['id'] as int?,
        syncId: map['sync_id'] as String,
        name: map['name'] as String,
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
      );
}