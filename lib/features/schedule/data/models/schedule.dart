enum ScheduleType { lecture, lab, exam, study, event, other }

class Schedule {
  final int? id;
  final int? courseId;
  final String title;
  final String? description;
  final int dayOfWeek;
  final int startTime;
  final int endTime;
  final String? location;
  final ScheduleType type;

  const Schedule({
    this.id,
    this.courseId,
    required this.title,
    this.description,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.type,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'type': type.name,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as int?,
      courseId: map['courseId'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dayOfWeek: map['dayOfWeek'] as int,
      startTime: map['startTime'] as int,
      endTime: map['endTime'] as int,
      location: map['location'] as String?,
      type: ScheduleType.values.byName(map['type'] as String),
    );
  }
}
