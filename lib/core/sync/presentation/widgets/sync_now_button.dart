import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';

import 'package:student_app_project/features/courses/presentation/providers/course_provider.dart';
import 'package:student_app_project/core/sync/providers/sync_processor_provider.dart';

class SyncNowButton extends ConsumerWidget {
  const SyncNowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);

        try {
          final databaseHelper = ref.read(databaseHelperProvider);
          final db = await databaseHelper.database;

          final rows = await db.query('sync_outbox', orderBy: 'id ASC');

          debugPrint('========== SYNC OUTBOX ==========');

          for (final row in rows) {
            debugPrint('OUTBOX ROW: ${jsonEncode(row)}', wrapWidth: 1024);
          }

          debugPrint('========== END OUTBOX ==========');

          debugPrint('========== LOCAL SEMESTERS ==========');

          final semesters = await db.query('semesters');

          for (final semester in semesters) {
            debugPrint(
              'LOCAL SEMESTER: ${jsonEncode(semester)}',
              wrapWidth: 1024,
            );
          }

          debugPrint('========== LOCAL COURSES ==========');

          final courses = await db.query('courses');

          for (final course in courses) {
            debugPrint('LOCAL COURSE: ${jsonEncode(course)}', wrapWidth: 1024);
          }

          debugPrint('========== END LOCAL DATA ==========');
          
          final processor = await ref.read(syncProcessorProvider.future);

          final result = await processor.syncPending();

          final message = result.succeeded
              ? 'Sync complete: ${result.syncedCount} operation(s).'
              : 'Sync stopped after ${result.syncedCount} '
                    'operation(s): ${result.error}';

          messenger.showSnackBar(SnackBar(content: Text(message)));
        } catch (error) {
          messenger.showSnackBar(
            SnackBar(content: Text('Sync failed: $error')),
          );
        }
      },
      child: const Text('Sync now'),
    );
  }
}
