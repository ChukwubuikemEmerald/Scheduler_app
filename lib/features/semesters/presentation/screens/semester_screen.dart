import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app_project/core/extentions/app_drawer.dart';
import 'package:student_app_project/core/extentions/snack_bar_messages.dart';

import 'package:student_app_project/features/semesters/presentation/providers/semester_provider.dart';
import 'package:student_app_project/features/semesters/presentation/screens/add_semester_screen.dart';
import 'package:student_app_project/features/semesters/presentation/screens/edit_semester_screen.dart';

class SemesterScreen extends ConsumerWidget {
  const SemesterScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semestersAsync = ref.watch(semesterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Semesters')),
      drawer: const AppDrawer(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSemesterScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: semestersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: $error', textAlign: TextAlign.center),
          ),
        ),
        data: (semesters) {
          if (semesters.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No semesters added yet',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Tap + to add your first semester'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: semesters.length,
            itemBuilder: (context, index) {
              final semester = semesters[index];

              return ListTile(
                title: Text(semester.name),
                subtitle: Text(
                  '${_formatDate(semester.startDate)}'
                  ' - '
                  '${_formatDate(semester.endDate)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditSemesterScreen(semester: semester),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Delete semester?'),
                              content: Text(
                                'Are you sure you want to delete '
                                '${semester.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, true);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete != true) {
                          return;
                        }

                        await ref
                            .read(semesterProvider.notifier)
                            .deleteSemester(semester.id!);

                        if (!context.mounted) {
                          return;
                        }

                        final currentState = ref.read(semesterProvider);

                        currentState.when(
                          data: (_) {
                            context.showMessage(
                              '${semester.name} deleted successfully',
                            );
                          },
                          loading: () {},
                          error: (error, stackTrace) {
                            context.showMessage(
                              'Unable to delete ${semester.name}. '
                              'Make sure no courses are assigned to it.',
                              isError: true,
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
