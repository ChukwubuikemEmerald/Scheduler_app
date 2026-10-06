class Course {
  final int? id;
  final String sync_id;
  final int? semesterId;
  final String code;
  final String name;

  Course({
    this.id,
    required this.sync_id,
    this.semesterId,
    required this.code,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'sync_id': sync_id,
    'semesterId': semesterId,
    'code': code,
    'name': name,
  };

  factory Course.fromMap(Map<String, dynamic> map) => Course(
    id: map['id'] as int?,
    sync_id: map['sync_id'],
    semesterId: map['semesterId'] as int?,
    code: map['code'] as String,
    name: map['name'] as String,
  );
}
