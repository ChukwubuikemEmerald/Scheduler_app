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

  Future<SyncBatchResult> syncPending({int limit = 50}) async {
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

      await outbox.recordFailure(
        executor: database,
        id: id,
        error: failure 
      );

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
