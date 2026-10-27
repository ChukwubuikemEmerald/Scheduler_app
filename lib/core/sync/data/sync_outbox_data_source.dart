import 'dart:convert';

import 'package:sqflite/sqflite.dart';

enum SyncEntityType { semester, course, schedule }

enum SyncOperation { upsert, delete }

class SyncOutboxDataSource {
  Future<int> enqueue({
    required DatabaseExecutor executor,
    required SyncEntityType entityType,
    required String syncId,
    required SyncOperation operation,
    Map<String, dynamic>? payload,
  }) async {
    if (syncId.trim().isEmpty) {
      throw ArgumentError.value(syncId, 'syncId', 'Sync ID cannot be empty.');
    }

    if (operation == SyncOperation.upsert && payload == null) {
      throw ArgumentError('An upsert operation requires a payload.');
    }

    final entityTypeName = entityType.name;

    // Remove older pending operations for this exact entity.
    await executor.delete(
      'sync_outbox',
      where: 'entity_type = ? AND sync_id = ?',
      whereArgs: [entityTypeName, syncId],
    );

    // Insert the latest requested operation.
    return executor.insert('sync_outbox', {
      'entity_type': entityTypeName,
      'sync_id': syncId,
      'operation': operation.name,
      'payload': payload == null ? null : jsonEncode(payload),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPending({
    required DatabaseExecutor executor,
    int limit = 50,
  }) async {
    return executor.query(
      'sync_outbox',
      orderBy: '''
      CASE
        WHEN entity_type = 'semester'
          AND operation = 'upsert' THEN 0
        WHEN entity_type = 'course'
          AND operation = 'upsert' THEN 1
        WHEN entity_type = 'schedule'
          AND operation = 'upsert' THEN 2
        WHEN entity_type = 'schedule'
          AND operation = 'delete' THEN 3
        WHEN entity_type = 'course'
          AND operation = 'delete' THEN 4
        WHEN entity_type = 'semester'
          AND operation = 'delete' THEN 5
        ELSE 6
      END ASC,
      id ASC
    ''',
      limit: limit,
    );
  }

  Future<int> markSynced({
    required DatabaseExecutor executor,
    required int id,
  }) {
    return executor.delete('sync_outbox', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> recordFailure({
    required DatabaseExecutor executor,
    required int id,
    required String error,
  }) {
    final message = error.length > 2000 ? error.substring(0, 2000) : error;

    return executor.rawUpdate(
      '''
      UPDATE sync_outbox
      SET attempts = attempts + 1,
          last_error = ?
      WHERE id = ?
      ''',
      [message, id],
    );
  }
}
