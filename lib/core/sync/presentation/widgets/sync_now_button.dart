import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app_project/core/sync/providers/sync_processor_provider.dart';

class SyncNowButton extends ConsumerWidget {
  const SyncNowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);

        try {
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
