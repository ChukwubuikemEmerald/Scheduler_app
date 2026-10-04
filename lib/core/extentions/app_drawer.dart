import 'package:flutter/material.dart';

import 'package:student_app_project/features/courses/presentation/screens/course_screen.dart';
import 'package:student_app_project/features/semesters/presentation/screens/semester_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.school, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Student Scheduler',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                // Home screen will be added later.
              },
            ),

            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Courses'),
              onTap: () {
                _navigate(context, const CourseScreen());
              },
            ),

            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Semesters'),
              onTap: () {
                _navigate(context, const SemesterScreen());
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Schedule'),
              enabled: false,
              onTap: null,
            ),

            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Tasks'),
              enabled: false,
              onTap: null,
            ),

            ListTile(
              leading: const Icon(Icons.note_outlined),
              title: const Text('Notes'),
              enabled: false,
              onTap: null,
            ),

            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: const Text('Events'),
              enabled: false,
              onTap: null,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              enabled: false,
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }
}
