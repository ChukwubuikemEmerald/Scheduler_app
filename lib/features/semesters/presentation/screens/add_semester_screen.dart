import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app_project/core/extentions/snack_bar_messages.dart';
import 'package:student_app_project/features/semesters/data/models/semester.dart';
import 'package:student_app_project/features/semesters/presentation/providers/semester_provider.dart';

class AddSemesterScreen extends ConsumerStatefulWidget {
  const AddSemesterScreen({super.key});

  @override
  ConsumerState<AddSemesterScreen> createState() => _AddSemesterScreenState();
}

class _AddSemesterScreenState extends ConsumerState<AddSemesterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _startDate = pickedDate;
    });
  }

  Future<void> _selectEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _endDate = pickedDate;
    });
  }

  Future<void> _saveSemester() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      context.showMessage('Please select a start date', isError: true);
      return;
    }

    if (_endDate == null) {
      context.showMessage('Please select an end date', isError: true);
      return;
    }

    if (!_startDate!.isBefore(_endDate!)) {
      context.showMessage('End date must be after start date', isError: true);
      return;
    }

    final semester = Semester(
      name: _nameController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
    );

    await ref.read(semesterProvider.notifier).addSemester(semester);

    if (!context.mounted) {
      return;
    }

    final currentState = ref.read(semesterProvider);

    currentState.when(
      data: (_) {
        context.showMessage('Semester added successfully');

        context.pop();
      },
      loading: () {},
      error: (error, stackTrace) {
        context.showMessage('Failed to add semester', isError: true);
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Semester')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Semester name',
                  hintText: 'e.g. 2026 First Semester',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a semester name';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start date'),
                subtitle: Text(_formatDate(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectStartDate,
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End date'),
                subtitle: Text(_formatDate(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectEndDate,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSemester,
                  child: const Text('Save Semester'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
