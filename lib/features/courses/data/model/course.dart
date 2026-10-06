import 'package:uuid/uuid.dart';

class Course {
  final int? id;
  final String syncId;
  final int? semesterId;
  final String code;
  final String name;

  Course({
    this.id,
    String? syncId,
    this.semesterId,
    required this.code,
    required this.name,
  }) : syncId = syncId ?? Uuid().v4();

  Map<String, dynamic> toMap() => {
    'id': id,
    'sync_id': syncId,
    'semesterId': semesterId,
    'code': code,
    'name': name,
  };

  factory Course.fromMap(Map<String, dynamic> map) => Course(
    id: map['id'] as int?,
    syncId: map['syncId'] as String?,
    semesterId: map['semesterId'] as int?,
    code: map['code'] as String,
    name: map['name'] as String,
  );
}
