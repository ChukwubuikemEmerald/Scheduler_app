import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app_project/core/extentions/snack_bar_messages.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';
import 'package:student_app_project/features/courses/presentation/providers/course_provider.dart';
import 'package:student_app_project/features/semesters/presentation/providers/semester_provider.dart';

class AddCourseScreen extends ConsumerStatefulWidget {
  const AddCourseScreen({super.key});

  @override
  ConsumerState<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends ConsumerState<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  int? _selectedSemesterId;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSemesterId == null) {
      context.showMessage('Please select a semester', isError: true);
      return;
    }

    final course = Course(
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      semesterId: _selectedSemesterId,
    );

    await ref.read(courseProvider.notifier).addCourse(course);

    if (!context.mounted) {
      return;
    }

    final currentState = ref.read(courseProvider);

    currentState.when(
      data: (_) {
        context.showMessage('${course.code} added successfully');

        context.pop();
      },
      loading: () {},
      error: (error, stackTrace) {
        context.showMessage('Failed to add ${course.code}', isError: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final semestersAsync = ref.watch(semesterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Course')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Course code',
                  hintText: 'e.g. CSC101',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a course code';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Course name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a course name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              semestersAsync.when(
                loading: () {
                  return const InputDecorator(
                    decoration: InputDecoration(labelText: 'Semester'),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Loading semesters...'),
                      ],
                    ),
                  );
                },
                error: (error, stackTrace) {
                  return InputDecorator(
                    decoration: const InputDecoration(labelText: 'Semester'),
                    child: Text(
                      'Unable to load semesters',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
                data: (semesters) {
                  if (semesters.isEmpty) {
                    return const InputDecorator(
                      decoration: InputDecoration(labelText: 'Semester'),
                      child: Text('Create a semester before adding a course'),
                    );
                  }

                  return DropdownButtonFormField<int>(
                    initialValue: _selectedSemesterId,
                    decoration: const InputDecoration(labelText: 'Semester'),
                    items: semesters.map((semester) {
                      return DropdownMenuItem<int>(
                        value: semester.id,
                        child: Text(semester.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSemesterId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Select a semester';
                      }

                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addCourse,
                  child: const Text('Save Course'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
