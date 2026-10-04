class Semester {
  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  Semester({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  };

  factory Semester.fromMap(Map<String, dynamic> map) => Semester(
    id: map['id'] as int?,
    name: map['name'] as String,
    startDate: DateTime.parse(map['startDate'] as String),
    endDate: DateTime.parse(map['endDate'] as String),
  );
}
