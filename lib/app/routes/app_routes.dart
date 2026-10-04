import 'package:go_router/go_router.dart';
import 'package:student_app_project/features/courses/data/model/course.dart';
import 'package:student_app_project/features/courses/presentation/screens/add_course_screen.dart';
import 'package:student_app_project/features/courses/presentation/screens/course_screen.dart';
import 'package:student_app_project/features/courses/presentation/screens/edit_course_screen.dart';
import 'package:student_app_project/features/semesters/presentation/screens/semester_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/courses',
  routes: [
    GoRoute(
      path: '/courses',
      builder: (context, state) => const CourseScreen(),
    ),

    GoRoute(
      path: '/semester',
      builder: (context, state) => const SemesterScreen(),
    ),

    GoRoute(
      path: '/edit-course',
      builder: (context, state) {
        final course = state.extra as Course;
        return EditCourseScreen(course: course);
      },
    ),

    GoRoute(
      path: '/add-course',
      builder: (context, state) => const AddCourseScreen(),
    ),
  ],
);
