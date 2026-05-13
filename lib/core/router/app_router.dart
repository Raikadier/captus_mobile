import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../services/router_service.dart';
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
import '../../features/tasks/screens/categories_management_screen.dart';
import '../../features/tasks/screens/personal_tasks_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/calendar/screens/calendar_agenda_screen.dart';
import '../../features/calendar/screens/calendar_event_create_screen.dart';
import '../../features/ai_assistant/screens/ai_chat_screen.dart';
import '../../features/ai_assistant/screens/ai_chat_history_screen.dart';
import '../../features/ai_assistant/screens/ai_settings_screen.dart';
import '../../features/courses/screens/courses_list_screen.dart';
import '../../features/courses/screens/course_detail_student_screen.dart';
import '../../features/courses/screens/activity_detail_student_screen.dart';
import '../../features/courses/screens/join_course_screen.dart';
import '../../features/courses/screens/scan_qr_join_course_screen.dart';
import '../../features/courses/screens/courses_list_teacher_screen.dart';
import '../../features/courses/screens/course_detail_teacher_screen.dart';
import '../../features/courses/screens/course_groups_teacher_screens.dart';
import '../../features/courses/screens/activity_create_screen.dart';
import '../../features/courses/screens/course_create_screen.dart';
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
import '../../features/evidence/screens/evidence_screen.dart';
import '../../features/admin/screens/admin_shell_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_courses_screen.dart';
import '../../features/admin/screens/admin_institution_screen.dart';
import '../../features/superadmin/screens/superadmin_shell_screen.dart';
import '../../features/superadmin/screens/superadmin_dashboard_screen.dart';
import '../../features/superadmin/screens/superadmin_institutions_screen.dart';
import '../../features/superadmin/screens/superadmin_users_screen.dart';
import '../../features/superadmin/screens/superadmin_audit_screen.dart';

// Use the shared key so FCM / deep-link code can navigate imperatively
final _rootNavigatorKey  = RouterService.navigatorKey;
final _shellNavigatorKey = GlobalKey<NavigatorState>();

const _publicRoutes = {
  '/splash',
  '/onboarding',
  '/login',
  '/register',
  '/forgot-password',
  '/join',
};

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);

      if (authAsync.isLoading) return '/splash';

      final authState = authAsync.asData?.value;
      final isAuthenticated = authState?.isAuthenticated ?? false;
      final isPublic = _publicRoutes.contains(state.matchedLocation);

      if (!isAuthenticated && !isPublic) return '/login';

      if (isAuthenticated &&
          isPublic &&
          state.matchedLocation != '/splash' &&
          state.matchedLocation != '/join') {
        final role = authState?.role ?? 'student';
        if (role == 'superadmin') return '/superadmin/dashboard';
        if (role == 'admin') return '/admin/dashboard';
        return role == 'teacher' ? '/home/teacher' : '/home';
      }

      if (isAuthenticated) {
        final role = authState?.role ?? 'student';
        final loc = state.matchedLocation;
        final isCommon = _publicRoutes.contains(loc) ||
            loc == '/settings' ||
            loc == '/profile' ||
            loc == '/notifications';

        if (role == 'superadmin' &&
            !loc.startsWith('/superadmin') &&
            !isCommon) {
          return '/superadmin/dashboard';
        }

        if (role == 'admin' && !loc.startsWith('/admin') && !isCommon) {
          return '/admin/dashboard';
        }
      }

      return null;
    },
    refreshListenable: _AuthChangeNotifier(ref),
    routes: [
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
      GoRoute(
        path: '/evidences',
        builder: (_, __) => const EvidenceScreen(),
      ),

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

      ShellRoute(
        builder: (context, state, child) => AdminShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            name: 'admin_dashboard',
            builder: (_, __) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            name: 'admin_users',
            builder: (_, __) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/admin/courses',
            name: 'admin_courses',
            builder: (_, __) => const AdminCoursesScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/admin/institution',
        name: 'admin_institution',
        builder: (_, __) => const AdminInstitutionScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) =>
            SuperAdminShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/superadmin/dashboard',
            name: 'superadmin_dashboard',
            builder: (_, __) => const SuperAdminDashboardScreen(),
          ),
          GoRoute(
            path: '/superadmin/institutions',
            name: 'superadmin_institutions',
            builder: (_, __) => const SuperAdminInstitutionsScreen(),
          ),
          GoRoute(
            path: '/superadmin/users',
            name: 'superadmin_users',
            builder: (_, __) => const SuperAdminUsersScreen(),
          ),
          GoRoute(
            path: '/superadmin/audit',
            name: 'superadmin_audit',
            builder: (_, __) => const SuperAdminAuditScreen(),
          ),
        ],
      ),

      // ── Tasks ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/tasks/personal',
        name: 'personal_tasks',
        builder: (_, __) => const PersonalTasksScreen(),
      ),
      GoRoute(
        path: '/tasks/categories',
        name: 'categories_management',
        builder: (_, __) => const CategoriesManagementScreen(),
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
        path: '/tasks/:id',
        name: 'task_detail',
        builder: (_, state) => TaskDetailScreen(
          taskId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/search',
        name: 'global_search',
        builder: (_, __) => const GlobalSearchScreen(),
      ),

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
        path: '/teacher/courses/new',
        name: 'course_create',
        builder: (_, __) => const CourseCreateScreen(),
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
        path: '/teacher/courses/:courseId/groups/new',
        name: 'course_group_create_teacher',
        builder: (_, state) => CreateCourseGroupScreen(
          courseId: int.parse(state.pathParameters['courseId']!),
        ),
      ),
      GoRoute(
        path: '/teacher/courses/:courseId/groups/:groupId',
        name: 'course_group_detail_teacher',
        builder: (_, state) => GroupDetailTeacherScreen(
          courseId: int.parse(state.pathParameters['courseId']!),
          groupId: int.parse(state.pathParameters['groupId']!),
        ),
      ),
      GoRoute(
        path: '/teacher/courses/:courseId/groups/:groupId/admin',
        name: 'course_group_admin_teacher',
        builder: (_, state) => GroupAdminTeacherScreen(
          courseId: int.parse(state.pathParameters['courseId']!),
          groupId: int.parse(state.pathParameters['groupId']!),
        ),
      ),

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
      GoRoute(
        path: '/join',
        builder: (context, state) {
          final code = state.uri.queryParameters['code'] ?? '';
          return JoinCourseScreen(inviteCode: code);
        },
      ),
      GoRoute(
        path: '/scan-qr',
        name: 'scan_qr_join_course',
        builder: (_, __) => const ScanQRJoinCourseScreen(),
      ),
    ],
  );
}

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(WidgetRef ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}