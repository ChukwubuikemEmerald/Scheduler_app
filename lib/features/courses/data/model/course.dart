class Course {
  final int? id;
  final int? semesterId;
  final String code;
  final String name;

  Course({this.id, this.semesterId, required this.code, required this.name});

  Map<String, dynamic> toMap() => {
    'id': id,
    'semesterId': semesterId,
    'code': code,
    'name': name,
  };

  factory Course.fromMap(Map<String, dynamic> map) => Course(
    id: map['id'] as int?,
    semesterId: map['semesterId'] as int?,
    code: map['code'] as String,
    name: map['name'] as String,
  );
}
