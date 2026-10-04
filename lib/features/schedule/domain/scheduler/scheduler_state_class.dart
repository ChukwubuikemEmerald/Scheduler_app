import 'package:student_app_project/features/schedule/data/models/schedule.dart';

enum SchedulerStatus { active, upcoming, finished }

class SchedulerState {
  final SchedulerStatus status;
  final Schedule? schedule;
  final Duration? duration;

  const SchedulerState({required this.status, this.schedule, this.duration});
}
