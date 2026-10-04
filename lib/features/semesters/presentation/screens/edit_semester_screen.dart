import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app_project/core/extentions/snack_bar_messages.dart';
import 'package:student_app_project/features/semesters/data/models/semester.dart';
import 'package:student_app_project/features/semesters/presentation/providers/semester_provider.dart';

class EditSemesterScreen extends ConsumerStatefulWidget {
  final Semester semester;

  const EditSemesterScreen({super.key, required this.semester});

  @override
  ConsumerState<EditSemesterScreen> createState() => _EditSemesterScreenState();
}

class _EditSemesterScreenState extends ConsumerState<EditSemesterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.semester.name);

    _startDate = widget.semester.startDate;
    _endDate = widget.semester.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
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
      initialDate: _endDate,
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

  Future<void> _updateSemester() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_startDate.isBefore(_endDate)) {
      context.showMessage('End date must be after start date', isError: true);
      return;
    }

    final updatedSemester = Semester(
      id: widget.semester.id,
      name: _nameController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
    );

    await ref.read(semesterProvider.notifier).updateSemester(updatedSemester);

    if (!context.mounted) {
      return;
    }

    final currentState = ref.read(semesterProvider);

    currentState.when(
      data: (_) {
        context.showMessage('Semester updated successfully');

        context.pop();
      },
      loading: () {},
      error: (error, stackTrace) {
        context.showMessage('Failed to update semester', isError: true);
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Semester')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Semester name'),
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
                  onPressed: _updateSemester,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
