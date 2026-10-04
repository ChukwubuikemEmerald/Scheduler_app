import 'package:student_app_project/features/schedule/data/models/schedule.dart';
import 'package:student_app_project/features/schedule/domain/scheduler/scheduler_state_class.dart';

class ScheduleService {
  final DateTime now;
  List<Schedule> schedule;

  ScheduleService({required this.now, required this.schedule});

  List<int> getTimeInfo(DateTime date) {
    int weekday = date.weekday;
    int hour = date.hour;
    int minute = date.minute;

    int totalMinutes = hour * 60 + minute;
    return [weekday, totalMinutes];
  }

  List<Schedule> getTodaysSchedules(List<Schedule> schedules, DateTime now) {
    final todaySchedules = schedules
        .where((schedule) => schedule.dayOfWeek == now.weekday)
        .toList();

    return todaySchedules;
  }

  Schedule? getActiveSchedule(List<Schedule> todaySchedules, DateTime now) {
    int currentMin = now.hour * 60 + now.minute;

    for (var schedule in todaySchedules) {
      if (schedule.startTime <= currentMin && currentMin < schedule.endTime) {
        return schedule;
      }
    }
    return null;
  }

  Schedule? getNextSchedule(List<Schedule> todaySchedules, DateTime now) {
    int currentMin = now.hour * 60 + now.minute;

    var futureSchedules = todaySchedules.where((s) => s.startTime > currentMin);

    if (futureSchedules.isEmpty) return null;

    return futureSchedules.reduce(
      (curr, next) => curr.startTime < next.startTime ? curr : next,
    );
  }

  Duration getRemainingTime(Schedule schedule, DateTime now) {
    int currentMin = now.hour * 60 + now.minute;

    int remainingMin = schedule.endTime - currentMin;

    return Duration(minutes: remainingMin);
  }

  Duration getTimeUntil(Schedule schedule, DateTime now) {
    int currentMin = now.hour * 60 + now.minute;

    int remainingMin = schedule.startTime - currentMin;

    return Duration(minutes: remainingMin);
  }

  SchedulerState getState(List<Schedule> schedules, DateTime now) {
    final todaySchedules = getTodaysSchedules(schedules, now);

    final activeSchedule = getActiveSchedule(todaySchedules, now);

    if (activeSchedule != null) {
      return SchedulerState(
        status: SchedulerStatus.active,
        schedule: activeSchedule,
        duration: getRemainingTime(activeSchedule, now),
      );
    }

    final nextSchedule = getNextSchedule(todaySchedules, now);

    if (nextSchedule != null) {
      return SchedulerState(
        status: SchedulerStatus.upcoming,
        schedule: nextSchedule,
        duration: getTimeUntil(nextSchedule, now),
      );
    }

    return SchedulerState(
      status: SchedulerStatus.finished,
      schedule: null,
      duration: Duration.zero,
    );
  }
}
