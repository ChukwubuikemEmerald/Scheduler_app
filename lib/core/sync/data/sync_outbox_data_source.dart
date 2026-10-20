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

    return await executor.insert('sync_outbox', {
      'entity_type': entityType.name,
      'sync_id': syncId,
      'operation': operation.name,
      'payload': payload == null ? null : jsonEncode(payload),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
