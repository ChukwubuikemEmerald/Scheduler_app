import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app_project/core/extentions/app_drawer.dart';
import 'package:student_app_project/features/courses/presentation/providers/course_provider.dart';
import 'package:student_app_project/core/extentions/snack_bar_messages.dart';
import 'package:go_router/go_router.dart';

class CourseScreen extends ConsumerWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(courseProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-course');
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/semester');
            },
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Semesters',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (courses) {
          // we'll build the course list here next
          if (courses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No courses added yet',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first course',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return ListTile(
                title: Text(course.code),
                subtitle: Text(course.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Edit button
                    IconButton(
                      onPressed: () {
                        context.push('/edit-course', extra: course);
                      },
                      icon: const Icon(Icons.edit),
                    ),

                    //Delete button
                    IconButton(
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete course?'),
                              content: Text(
                                'Are you sure you want to delete ${course.code}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
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
                        try {
                          await ref
                              .read(courseProvider.notifier)
                              .deleteCourse(course);

                          if (!context.mounted) return;

                          context.showMessage(
                            '${course.code} deleted successfully',
                          );
                        } catch (error) {
                          if (!context.mounted) return;

                          context.showMessage(
                            'Failed to delete ${course.code}',
                            isError: true,
                          );
                        }
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
