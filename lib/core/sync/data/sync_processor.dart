import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'package:student_app_project/core/sync/data/sync_outbox_data_source.dart';

Uri _buildSyncEndpoint(String baseUrl) {
  final normalized = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
  return Uri.parse(normalized).resolve('api/sync');
}

class SyncBatchResult {
  final int syncedCount;
  final int? failedEntryId;
  final String? error;
  final int deferredCount;

  const SyncBatchResult({
    required this.syncedCount,
    this.failedEntryId,
    this.error,
    this.deferredCount = 0,
  });

  bool get succeeded => failedEntryId == null;
}

class SyncProcessor {
  final Database database;
  final SyncOutboxDataSource outbox;
  final Uri endpoint;

  final http.Client _client;
  final bool _ownsClient;

  SyncProcessor({
    required this.database,
    required String baseUrl,
    SyncOutboxDataSource? outbox,
    http.Client? client,
  }) : endpoint = _buildSyncEndpoint(baseUrl),
       outbox = outbox ?? SyncOutboxDataSource(),
       _client = client ?? http.Client(),
       _ownsClient = client == null;

  Future<void> _ensureInitialBackfill() async {
    const marker = 'initial_outbox_backfill_v1';

    String requireSyncId(Map<String, Object?> row, String entityType) {
      final value = row['sync_id']?.toString();

      if (value == null || value.trim().isEmpty) {
        throw StateError('$entityType ${row['id']} has no sync_id.');
      }

      return value;
    }

    await database.transaction((txn) async {
      final completed = await txn.query(
        'sync_metadata',
        where: 'key = ?',
        whereArgs: [marker],
        limit: 1,
      );

      // The initial backfill has already run.
      if (completed.isNotEmpty) return;

      // Do not enqueue records already represented in the outbox.
      final existingEntries = await txn.query(
        'sync_outbox',
        columns: ['entity_type', 'sync_id'],
      );

      final queuedKeys = <String>{
        for (final entry in existingEntries)
          '${entry['entity_type']}|${entry['sync_id']}',
      };

      // Read all existing semesters and build their local-ID mapping.
      final semesters = await txn.query('semesters', orderBy: 'id ASC');

      final semesterSyncIds = <int, String>{};

      for (final semester in semesters) {
        semesterSyncIds[semester['id'] as int] = requireSyncId(
          semester,
          'semester',
        );
      }

      // Queue semesters first.
      for (final semester in semesters) {
        final syncId = requireSyncId(semester, 'semester');
        final key = 'semester|$syncId';

        if (queuedKeys.contains(key)) continue;

        if (semester['startDate'] == null || semester['endDate'] == null) {
          throw StateError('Semester ${semester['id']} is missing dates.');
        }

        await outbox.enqueue(
          executor: txn,
          entityType: SyncEntityType.semester,
          syncId: syncId,
          operation: SyncOperation.upsert,
          payload: {
            'sync_id': syncId,
            'name': semester['name'],
            'start_date': semester['startDate'],
            'end_date': semester['endDate'],
          },
        );

        queuedKeys.add(key);
      }

      // Read all existing courses and build their local-ID mapping.
      final courses = await txn.query('courses', orderBy: 'id ASC');

      final courseSyncIds = <int, String>{};

      for (final course in courses) {
        courseSyncIds[course['id'] as int] = requireSyncId(course, 'course');
      }

      // Queue courses with their semester's stable sync ID.
      for (final course in courses) {
        final syncId = requireSyncId(course, 'course');
        final key = 'course|$syncId';

        if (queuedKeys.contains(key)) continue;

        final semesterId = course['semesterId'] as int?;
        final semesterSyncId = semesterId == null
            ? null
            : semesterSyncIds[semesterId];

        if (semesterId != null && semesterSyncId == null) {
          throw StateError(
            'Course ${course['id']} references missing '
            'local semester $semesterId.',
          );
        }

        await outbox.enqueue(
          executor: txn,
          entityType: SyncEntityType.course,
          syncId: syncId,
          operation: SyncOperation.upsert,
          payload: {
            'sync_id': syncId,
            'code': course['code'],
            'name': course['name'],
            'semester_sync_id': semesterSyncId,
          },
        );

        queuedKeys.add(key);
      }

      // Queue schedules with their course's stable sync ID.
      final schedules = await txn.query('schedules', orderBy: 'id ASC');

      for (final schedule in schedules) {
        final syncId = requireSyncId(schedule, 'schedule');
        final key = 'schedule|$syncId';

        if (queuedKeys.contains(key)) continue;

        final courseId = schedule['courseId'] as int?;
        final courseSyncId = courseId == null ? null : courseSyncIds[courseId];

        if (courseId != null && courseSyncId == null) {
          throw StateError(
            'Schedule ${schedule['id']} references '
            'missing local course $courseId.',
          );
        }

        await outbox.enqueue(
          executor: txn,
          entityType: SyncEntityType.schedule,
          syncId: syncId,
          operation: SyncOperation.upsert,
          payload: {
            'sync_id': syncId,
            'title': schedule['title'],
            'description': schedule['description'],
            'day_of_week': schedule['dayOfWeek'],
            'start_time': schedule['startTime'],
            'end_time': schedule['endTime'],
            'location': schedule['location'],
            'type': schedule['type'],
            'course_sync_id': courseSyncId,
          },
        );

        queuedKeys.add(key);
      }

      // Mark completion only after all records have been queued.
      await txn.insert('sync_metadata', {'key': marker, 'value': 'done'});
    });
  }

  Future<SyncBatchResult> syncPending({int limit = 50}) async {
    await _ensureInitialBackfill();
    final entries = await outbox.getPending(executor: database, limit: limit);

    var syncedCount = 0;

    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final id = entry['id'] as int;

      String? failure;

      try {
        final payloadText = entry['payload'] as String?;

        final dynamic decodedPayload = payloadText == null
            ? null
            : jsonDecode(payloadText);

        final Map<String, dynamic>? payload = decodedPayload == null
            ? null
            : Map<String, dynamic>.from(decodedPayload as Map);

        final response = await _client.post(
          endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'entity_type': entry['entity_type'],
            'sync_id': entry['sync_id'],
            'operation': entry['operation'],
            'payload': payload,
          }),
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          failure = 'HTTP ${response.statusCode}: ${response.body}';
        } else {
          await outbox.markSynced(executor: database, id: id);

          syncedCount++;
          continue;
        }
      } catch (error) {
        failure = error.toString();
      }

      await outbox.recordFailure(executor: database, id: id, error: failure);

      // Stop at the first failure. Preserve ordering for operations
      // that may depend on an earlier semester or course.
      return SyncBatchResult(
        syncedCount: syncedCount,
        failedEntryId: id,
        error: failure,
        deferredCount: entries.length - index - 1,
      );
    }

    return SyncBatchResult(syncedCount: syncedCount);
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
