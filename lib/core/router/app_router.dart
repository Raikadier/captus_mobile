import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/register_academic_profile_screen.dart';
import '../../features/auth/screens/register_notifications_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/home/screens/home_dashboard_screen.dart';
import '../../features/home/screens/home_dashboard_teacher_screen.dart';
import '../../features/tasks/screens/tasks_list_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';
import '../../features/tasks/screens/task_create_screen.dart';
import '../../features/tasks/screens/global_search_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/calendar/screens/calendar_agenda_screen.dart';
import '../../features/calendar/screens/calendar_event_create_screen.dart';
import '../../features/ai_assistant/screens/ai_chat_screen.dart';
import '../../features/ai_assistant/screens/ai_chat_history_screen.dart';
import '../../features/ai_assistant/screens/ai_settings_screen.dart';
import '../../features/courses/screens/courses_list_screen.dart';
import '../../features/courses/screens/course_detail_student_screen.dart';
import '../../features/courses/screens/activity_detail_student_screen.dart';
import '../../features/courses/screens/courses_list_teacher_screen.dart';
import '../../features/courses/screens/course_detail_teacher_screen.dart';
import '../../features/courses/screens/activity_create_screen.dart';
import '../../features/assignments/screens/teacher_assignment_create_screen.dart';
import '../../features/assignments/screens/teacher_assignments_list_screen.dart';
import '../../features/assignments/screens/assignment_review_screen.dart';
import '../../features/assignments/screens/student_assignments_screen.dart';
import '../../features/assignments/screens/student_submission_create_screen.dart';
import '../../features/groups/screens/groups_list_screen.dart';
import '../../features/groups/screens/group_detail_screen.dart';
import '../../features/groups/screens/group_settings_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/notifications/screens/notifications_settings_screen.dart';
import '../../features/statistics/screens/statistics_screen.dart';
import '../../features/statistics/screens/achievements_screen.dart';
import '../../features/statistics/screens/statistics_teacher_screen.dart';
import '../../features/statistics/screens/student_profile_view_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/profile_edit_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/settings_security_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Routes that are accessible without authentication.
const _publicRoutes = {
  '/splash',
  '/onboarding',
  '/login',
  '/register',
  '/forgot-password'
};

/// Creates the GoRouter with a Riverpod [ref] so the [redirect] callback
/// can read the live [authProvider] state.
GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // ── Auth redirect guard ──────────────────────────────────────────────────
    redirect: (context, state) {
      final authState = ref.read(authProvider).asData?.value;
      if (authState == null || authState.isLoading) return null;

      final isPublic =
          _publicRoutes.any((route) => state.matchedLocation.startsWith(route));

      if (!authState.isAuthenticated) {
        if (!isPublic) return '/login';
        return null;
      }

      if (isPublic) {
        if (authState.role == 'teacher') {
          return '/home/teacher';
        } else {
          return '/home';
        }
      }
      return null;
    },

    // Refresh the router whenever auth state changes.
    refreshListenable: _AuthChangeNotifier(ref),

    routes: [
      // ── Auth ───────────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/register/profile',
        name: 'register_academic_profile',
        builder: (_, __) => const RegisterAcademicProfileScreen(),
      ),
      GoRoute(
        path: '/register/notifications',
        name: 'register_notifications',
        builder: (_, __) => const RegisterNotificationsScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Main shell with bottom nav ─────────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home_dashboard',
            builder: (_, __) => const HomeDashboardScreen(),
          ),
          GoRoute(
            path: '/home/teacher',
            name: 'home_dashboard_teacher',
            builder: (_, __) => const HomeDashboardTeacherScreen(),
          ),
          GoRoute(
            path: '/tasks',
            name: 'tasks_list',
            builder: (_, __) => const TasksListScreen(),
          ),
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            builder: (_, __) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/ai',
            name: 'ai_assistant',
            builder: (_, __) => const AiChatScreen(),
          ),
          GoRoute(
            path: '/groups',
            name: 'groups_list',
            builder: (_, __) => const GroupsListScreen(),
          ),
        ],
      ),

      // ── Tasks ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/tasks/:id',
        name: 'task_detail',
        builder: (_, state) =>
            TaskDetailScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tasks/create',
        name: 'task_create',
        builder: (_, state) => TaskCreateScreen(
          courseId: state.uri.queryParameters['courseId'],
        ),
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        name: 'task_edit',
        builder: (_, state) => TaskCreateScreen(
          taskId: state.pathParameters['id'],
          courseId: state.uri.queryParameters['courseId'],
        ),
      ),
      GoRoute(
        path: '/search',
        name: 'global_search',
        builder: (_, __) => const GlobalSearchScreen(),
      ),

      // ── Calendar ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/calendar/agenda',
        name: 'calendar_agenda',
        builder: (_, __) => const CalendarAgendaScreen(),
      ),
      GoRoute(
        path: '/calendar/event/create',
        name: 'calendar_event_create',
        builder: (_, state) => CalendarEventCreateScreen(
          date: state.uri.queryParameters['date'],
        ),
      ),
      GoRoute(
        path: '/calendar/event/:id/edit',
        name: 'calendar_event_edit',
        builder: (_, state) => CalendarEventCreateScreen(
          eventId: state.pathParameters['id'],
        ),
      ),

      // ── AI ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: '/ai/history',
        name: 'ai_chat_history',
        builder: (_, __) => const AiChatHistoryScreen(),
      ),
      GoRoute(
        path: '/ai/settings',
        name: 'ai_settings',
        builder: (_, __) => const AiSettingsScreen(),
      ),

      // ── Courses ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/courses',
        name: 'courses_list',
        builder: (_, __) => const CoursesListScreen(),
      ),
      GoRoute(
        path: '/courses/:id',
        name: 'course_detail_student',
        builder: (_, state) =>
            CourseDetailStudentScreen(courseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/courses/:courseId/activity/:activityId',
        name: 'activity_detail_student',
        builder: (_, state) => ActivityDetailStudentScreen(
          courseId: state.pathParameters['courseId']!,
          activityId: state.pathParameters['activityId']!,
        ),
      ),
      GoRoute(
        path: '/teacher/courses',
        name: 'courses_list_teacher',
        builder: (_, __) => const CoursesListTeacherScreen(),
      ),
      GoRoute(
        path: '/teacher/courses/:id',
        name: 'course_detail_teacher',
        builder: (_, state) =>
            CourseDetailTeacherScreen(courseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/teacher/courses/:courseId/activity/create',
        name: 'activity_create',
        builder: (_, state) =>
            ActivityCreateScreen(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        path: '/teacher/courses/:courseId/activity/:activityId/edit',
        name: 'activity_edit',
        builder: (_, state) => ActivityCreateScreen(
          courseId: state.pathParameters['courseId']!,
          activityId: state.pathParameters['activityId'],
        ),
      ),
      GoRoute(
        path: '/teacher/assignments',
        name: 'teacher_assignments_list',
        builder: (_, __) => const TeacherAssignmentsListScreen(),
      ),
      GoRoute(
        path: '/teacher/assignments/create',
        name: 'teacher_assignment_create',
        builder: (_, __) => const TeacherAssignmentCreateScreen(),
      ),
      GoRoute(
        path: '/teacher/assignments/:id/review',
        name: 'assignment_review',
        builder: (_, state) =>
            AssignmentReviewScreen(assignmentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/student/assignments',
        name: 'student_assignments_list',
        builder: (_, __) => const StudentAssignmentsScreen(),
      ),
      GoRoute(
        path: '/student/assignments/:id/submit',
        name: 'student_submission_create',
        builder: (_, state) => StudentSubmissionCreateScreen(
            assignmentId: state.pathParameters['id']!),
      ),

      // ── Groups ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/groups/:id',
        name: 'group_detail',
        builder: (_, state) =>
            GroupDetailScreen(groupId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/groups/:id/settings',
        name: 'group_settings',
        builder: (_, state) =>
            GroupSettingsScreen(groupId: state.pathParameters['id']!),
      ),

      // ── Notifications ──────────────────────────────────────────────────────
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/notifications/settings',
        name: 'notifications_settings',
        builder: (_, __) => const NotificationsSettingsScreen(),
      ),

      // ── Statistics ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (_, __) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/statistics/achievements',
        name: 'achievements',
        builder: (_, __) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/teacher/statistics',
        name: 'statistics_teacher',
        builder: (_, __) => const StatisticsTeacherScreen(),
      ),
      GoRoute(
        path: '/teacher/student/:id',
        name: 'student_profile_view',
        builder: (_, state) =>
            StudentProfileViewScreen(studentId: state.pathParameters['id']!),
      ),

      // ── Profile ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile_edit',
        builder: (_, __) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        name: 'settings_security',
        builder: (_, __) => const SettingsSecurityScreen(),
      ),
    ],
  );
}

// ── Auth change notifier ──────────────────────────────────────────────────────

/// Bridges Riverpod → GoRouter: notifies the router to re-evaluate [redirect]
/// every time [authProvider] emits a new value.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(WidgetRef ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
