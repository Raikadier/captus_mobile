# Captus Mobile — Frontend Audit Report
**Date:** 2026-05-15  
**Scope:** `lib/` — all screens, providers, constants, router  
**Auditor:** Claude Code (automated read-only analysis)

---

## 🎨 Design Violations

> Design rules: colors → `AppColors.*` only; font → `GoogleFonts.inter()` only; opacity → `.withAlpha(AppAlpha.aXX)` only; AppBar bg → `AppColors.surface`, elevation 0; page bg → `AppColors.background`; card bg → `AppColors.surface`.

---

### `lib/core/router/app_router.dart` — `NotFoundScreen`
| Line | Violation |
|------|-----------|
| ~inner | `Colors.black87` — use `AppColors.textPrimary` |
| ~inner | `Colors.black54` — use `AppColors.textSecondary` |

---

### `lib/features/shell/main_shell.dart`
| Line | Violation |
|------|-----------|
| modal barrier | `Color(0xFF1E1E1E)` hardcoded hex — use `AppColors.modalBg` |
| modal barrier | `Colors.black54` — use `AppColors.modalBg` or `AppColors.textSecondary` |
| modal overlay | `Colors.transparent` — use `AppColors.background` or remove explicit color |
| center nav icon | `Colors.white` — use `AppColors.textOnPrimary` |
| nav label/title | `TextStyle(fontSize: 20)` — wrap with `GoogleFonts.inter()` |
| nav label/title | `TextStyle(fontSize: 16)` — wrap with `GoogleFonts.inter()` |
| nav label/title | `TextStyle(fontSize: 13)` — wrap with `GoogleFonts.inter()` |

---

### `lib/features/home/screens/home_dashboard_screen.dart`
| Line | Violation |
|------|-----------|
| "Proyectos" quick card | `Color(0xFF8B5CF6)` hardcoded purple hex — no AppColors token; add one or use `AppColors.primary` |
| AI suggestion card | `Colors.white` (multiple instances) — use `AppColors.textOnPrimary` |
| AI suggestion card | `Colors.white.withAlpha(...)` (multiple) — use `AppColors.textOnPrimary.withAlpha(AppAlpha.aXX)` |

---

### `lib/features/home/screens/home_dashboard_teacher_screen.dart`
| Line | Violation |
|------|-----------|
| AI tools card | `Colors.white` — use `AppColors.textOnPrimary` |
| AI tools card | `Colors.white.withAlpha(...)` — use `AppColors.textOnPrimary.withAlpha(AppAlpha.aXX)` |
| FAB icon | `Colors.black` — use `AppColors.textOnPrimary` |

---

### `lib/features/calendar/screens/calendar_screen.dart`
| Line | Violation |
|------|-----------|
| event type "reunión" | `Colors.purple` — define `AppColors.eventMeeting` or use `AppColors.primary` |
| event cards | `Colors.white` (multiple) — use `AppColors.surface` / `AppColors.textOnPrimary` |
| event cards | `Colors.grey.shade200` — use `AppColors.surface2` or `AppColors.border` |
| modal | `Colors.transparent` — use `AppColors.background` |
| `_MonthYearPickerDialog` | `dialogBackgroundColor: Colors.white` — use `AppColors.surface` |

---

### `lib/features/calendar/screens/calendar_event_create_screen.dart`
| Line | Violation |
|------|-----------|
| `_typeColors` list | `Colors.purple` — use an `AppColors` token |

---

### `lib/features/courses/screens/courses_list_teacher_screen.dart`
| Line | Violation |
|------|-----------|
| FAB | `foregroundColor: Colors.black` — use `AppColors.textOnPrimary` |
| card borders | `border.withOpacity(0.4)` — use `.withAlpha(AppAlpha.a40)` |
| course color | `color.withOpacity(...)` (multiple) — use `.withAlpha(AppAlpha.aXX)` |

---

### `lib/features/courses/screens/course_detail_student_screen.dart`
| Line | Violation |
|------|-----------|
| tab content | `Colors.white` (multiple) — use `AppColors.surface` / `AppColors.textOnPrimary` |
| course color overlays | `color.withOpacity(...)` (multiple) — use `.withAlpha(AppAlpha.aXX)` |

---

### `lib/features/courses/screens/course_detail_teacher_screen.dart`
| Line | Violation |
|------|-----------|
| avatar child text | `Colors.white` — use `AppColors.textOnPrimary` |
| course color overlays | `color.withOpacity(...)` — use `.withAlpha(AppAlpha.aXX)` |

---

### `lib/features/courses/screens/activity_create_screen.dart`
| Line | Violation |
|------|-----------|
| publish button | `foregroundColor: Colors.black` — use `AppColors.textOnPrimary` |

---

### `lib/features/courses/screens/course_groups_teacher_screens.dart`
**Severity: CRITICAL** — This file has the highest density of raw color usage in the codebase.

| Line | Violation |
|------|-----------|
| Step 1 AppBar | `backgroundColor: Colors.orange.shade700` — use `AppColors.surface` |
| Group detail AppBar | `backgroundColor: Colors.blue.shade600` — use `AppColors.surface` |
| AppBar text | `foregroundColor: Colors.white` — use `AppColors.textOnPrimary` |
| Group list | `Colors.orange` (multiple) — use `AppColors.warning` or define a token |
| Group list | `Colors.red` (multiple) — use `AppColors.error` |
| Group list | `Colors.deepPurple` — no AppColors equivalent; use `AppColors.primary` |
| Group list | `Colors.green` (multiple) — use `AppColors.success` |
| Group list | `Colors.white` (multiple) — use `AppColors.textOnPrimary` |
| Font sizes | `24 * 0.75`, `28 * 0.75`, `30 * 0.75`, `23 * 0.75`, `20 * 0.75`, `14 * 0.75` — use literal values or named text styles; never arithmetic on font sizes |
| Opacity | `.withOpacity(...)` (extensive) — replace with `.withAlpha(AppAlpha.aXX)` throughout |

---

### `lib/features/tasks/screens/global_search_screen.dart`
| Line | Violation |
|------|-----------|
| (minor) | No direct AppColors violations noted; stub issue dominates |

---

### `lib/features/groups/screens/groups_list_screen.dart`
| Line | Violation |
|------|-----------|
| FAB | `foregroundColor: Colors.black` — use `AppColors.textOnPrimary` |

---

### `lib/features/groups/screens/group_detail_screen.dart`
| Line | Violation |
|------|-----------|
| check icon | `Colors.black` — use `AppColors.textPrimary` or `AppColors.primary` |
| CircleAvatar text | `Colors.white` — use `AppColors.textOnPrimary` |

---

### `lib/features/statistics/screens/statistics_teacher_screen.dart`
**Severity: CRITICAL** — Wrong font family used throughout.

| Line | Violation |
|------|-----------|
| ~10 text widgets | `GoogleFonts.outfit(...)` — **must be** `GoogleFonts.inter(...)` |
| shadow colors | `Colors.black.withAlpha(...)` — use `AppColors.textPrimary.withAlpha(AppAlpha.aXX)` |

---

### `lib/features/statistics/screens/statistics_screen.dart`
| Line | Violation |
|------|-----------|
| "Buen rendimiento" badge | `Color(0xFF7A4F00)` hardcoded hex — no AppColors token; define `AppColors.warningText` or use `AppColors.warning` |
| Purple stat tiles (×3) | `Color(0xFFAB47BC)` hardcoded purple hex — no AppColors token; use `AppColors.primary` or define a token |

---

### `lib/features/evidence/screens/evidence_screen.dart`
**Severity: HIGH** — Both color and font rules violated throughout.

| Line | Violation |
|------|-----------|
| Background, cards | `Colors.white` (multiple) — use `AppColors.surface` / `AppColors.background` |
| Borders, dividers | `Colors.grey.shade200` — use `AppColors.border` |
| Text | `Colors.grey` (as text color) — use `AppColors.textSecondary` |
| All text widgets | Bare `TextStyle()` without `GoogleFonts.inter()` (multiple) |
| Navigation | Uses `MaterialPageRoute` to `QrScannerScreen` — must use GoRouter |

---

### `lib/features/admin/screens/admin_periods_screen.dart`
| Line | Violation |
|------|-----------|
| Active period badge/border/icon | `Colors.green` (multiple) — use `AppColors.success` |
| Text styles | `TextStyle(color: Colors.green)` and `TextStyle(color: Colors.red)` — use `AppColors.success` / `AppColors.error` with `GoogleFonts.inter()` |

---

### `lib/features/admin/screens/admin_courses_screen.dart`
| Line | Violation |
|------|-----------|
| Error SnackBars | `backgroundColor: Colors.red` — use `AppColors.error` |
| PopupMenuItem | `TextStyle(color: Colors.red)` — use `AppColors.error` with `GoogleFonts.inter()` |
| Button style | `foregroundColor: Colors.red` — use `AppColors.error` |

---

### `lib/features/superadmin/screens/superadmin_dashboard_screen.dart`
**Severity: CRITICAL** — Entire screen ignores the design system.

| Line | Violation |
|------|-----------|
| All colors | Uses `Theme.of(context).colorScheme.*` — replace with `AppColors.*` throughout |
| All text | Uses `Theme.of(context).textTheme.*` — replace with `GoogleFonts.inter(...)` throughout |
| Scaffold | No explicit `backgroundColor: AppColors.background` |
| AppBar | No explicit `backgroundColor: AppColors.surface`, no `elevation: 0` |

---

### `lib/features/superadmin/screens/superadmin_users_screen.dart`
| Line | Violation |
|------|-----------|
| Colors | System theme usage (`Theme.of(context).colorScheme.*`) — use `AppColors.*` |
| Scaffold | Missing `backgroundColor: AppColors.background` |

---

### `lib/features/superadmin/screens/superadmin_audit_screen.dart`
| Line | Violation |
|------|-----------|
| Active state color | `Colors.green` return value — use `AppColors.success` |
| Text styles | `const TextStyle(fontSize: 13)` — wrap with `GoogleFonts.inter()` |
| Text styles | `const TextStyle(fontSize: 11)` — wrap with `GoogleFonts.inter()` |
| Colors | System theme usage — use `AppColors.*` |

---

### `lib/features/notifications/screens/notifications_screen.dart`
| Line | Violation |
|------|-----------|
| Selected tab chip | `Colors.black` on text — use `AppColors.textPrimary` or `AppColors.textOnPrimary` |
| Dismissible delete icon | `Colors.white` — use `AppColors.textOnPrimary` |

---

### `lib/features/profile/screens/settings_security_screen.dart`
| Line | Violation |
|------|-----------|
| Update button text | `Colors.black` — use `AppColors.textOnPrimary` |

---

### `lib/features/courses/screens/course_create_screen.dart`
| Line | Violation |
|------|-----------|
| TextFormField labels | `const TextStyle(color: AppColors.textPrimary)` — bare `TextStyle` without `GoogleFonts.inter()` |

---

### `lib/features/auth/screens/register_screen.dart`
| Line | Violation |
|------|-----------|
| Loading spinner | `color: Colors.black` — use `AppColors.textOnPrimary` |

---

### `lib/features/auth/screens/forgot_password_screen.dart`
| Line | Violation |
|------|-----------|
| Loading spinner | `color: Colors.black` — use `AppColors.textOnPrimary` |

---

### `lib/features/auth/screens/registration_success_screen.dart`
| Line | Violation |
|------|-----------|
| Primary button foreground | `color: Colors.black` — use `AppColors.textOnPrimary` |

---

### `lib/features/auth/screens/register_academic_profile_screen.dart`
| Line | Violation |
|------|-----------|
| Selected semester text | `isSelected ? Colors.black : AppColors.textPrimary` — use `AppColors.textOnPrimary` for selected state |

---

### `lib/features/courses/screens/activity_detail_student_screen.dart`
| Line | Violation |
|------|-----------|
| Foreground expression | `Colors.black` — use `AppColors.textOnPrimary` |
| SnackBar text | `Colors.white` in `TextStyle` — use `AppColors.textOnPrimary` |

---

### `lib/features/courses/screens/join_course_screen.dart`
| Line | Violation |
|------|-----------|
| AppBar bg | `Colors.transparent` — use `AppColors.surface` or `AppColors.background` |
| Error state icon | `Colors.red` — use `AppColors.error` |
| Already-enrolled icon | `Colors.green` — use `AppColors.success` |
| Button foreground (success) | `foregroundColor: Colors.black` — use `AppColors.textOnPrimary` |
| Button foreground (non-success) | `foregroundColor: Colors.white` — use `AppColors.textOnPrimary` |

---

### `lib/features/courses/screens/scan_qr_join_course_screen.dart`
| Line | Violation |
|------|-----------|
| Scaffold bg | `Colors.black` — acceptable for full-screen camera (low priority) |
| AppBar bg | `Colors.black` — acceptable for full-screen camera (low priority) |
| AppBar back icon | `Colors.white` — acceptable for camera overlay (low priority) |
| AppBar title text | `color: Colors.white` — acceptable for camera overlay (low priority) |
| Instruction text | `color: Colors.white` — acceptable for camera overlay (low priority) |
| Scanner overlay dimmer | `Colors.black.withOpacity(0.55)` — use `.withAlpha(AppAlpha.a55)` |
| Overlay container | `Colors.black`, `Colors.transparent` — acceptable for camera cutout blend logic |
| Detected state border | `Colors.greenAccent` — use `AppColors.success` |
| Detected glow shadow | `Colors.greenAccent.withOpacity(0.45)` — use `AppColors.success.withAlpha(AppAlpha.a45)` |
| Retry button foreground | `foregroundColor: Colors.black` — use `AppColors.textOnPrimary` |

---

## 🚫 Missing Screens

The following screens have no corresponding file in the codebase but are expected for a production-grade app with the features described:

| Missing Screen | Reason / Feature Gap |
|----------------|----------------------|
| **Course Edit screen** | `course_detail_teacher_screen.dart` has "Editar curso" menu item that just closes the dialog — no edit flow exists |
| **Notification Detail screen** | Notifications list is tappable but tapping only marks as read; there is no detail screen showing full notification content |
| **Task Detail screen (student)** | Global search taps navigate to task — no standalone task detail screen for reading full assignment specs |
| **Group Create screen** | `groups_list_screen.dart` FAB navigates to `/groups/create` — this route does not exist (see Navigation Gaps) |
| **Evidence Detail / Full-screen view** | `evidence_screen.dart` shows a list of submitted files but there is no screen for viewing a single evidence submission in full |
| **Activity Submission screen (student)** | Students can view assignments but there is no screen to submit work/attach files |
| **QR Generator screen (teacher)** | Teachers share courses via invite codes — no screen to display the course QR code for in-person sharing |
| **User Profile Edit screen** | No screen exists for a student/teacher to edit their own profile information (name, avatar, bio) |
| **Push Notification Settings screen** | AI settings exist, but no granular push-notification preference screen |
| **Admin User Detail / Edit screen** | Admin can list users but cannot edit user details or roles from within the app |
| **Superadmin Institution Detail screen** | Superadmin dashboard lists institutions but no detail screen to drill in |
| **Superadmin Institution Create/Edit screen** | No CRUD flow for institutions in the superadmin zone |
| **Password Change screen (standalone)** | `settings_security_screen.dart` shows a bottom-sheet that makes no API call — a proper screen is needed |

---

## 🧩 Incomplete / Stub Screens

| File | Issue |
|------|-------|
| `lib/features/courses/screens/courses_list_screen.dart` | Uses `CourseModel.mockList` — no Supabase query; shows same 3 fake courses to every student |
| `lib/features/courses/screens/courses_list_teacher_screen.dart` | Uses `CourseModel.mockList`; FAB `onPressed: () {}` is a no-op; teacher cannot create a course |
| `lib/features/courses/screens/course_detail_student_screen.dart` | Uses `CourseModel.mockList`; Resources tab shows "Sin recursos disponibles" — permanently empty placeholder |
| `lib/features/courses/screens/course_detail_teacher_screen.dart` | Uses `CourseModel.mockList` and `_mockStudents`; "Editar curso" and "Archivar curso" actions only close the menu — no actual operation |
| `lib/features/courses/screens/activity_create_screen.dart` | `_submit(bool publish)` shows a SnackBar and calls `context.pop()` — **no API call is made**; activities are never persisted |
| `lib/features/tasks/screens/global_search_screen.dart` | Entirely built on `TaskModel.mockList` and `CourseModel.mockList`; recent searches are hardcoded strings |
| `lib/features/calendar/screens/calendar_agenda_screen.dart` | Uses `TaskModel.mockList`; no real data integration |
| `lib/features/calendar/screens/calendar_screen.dart` | Task/event tiles in the day list are not tappable — no `onTap` handler |
| `lib/features/groups/screens/groups_list_screen.dart` | Uses `GroupModel.mockList`; navigates to non-existent `/groups/create` route |
| `lib/features/groups/screens/group_detail_screen.dart` | Uses `GroupModel.mockList`, `TaskModel.mockList`, and hardcoded `_activityFeed`; task-toggle FAB `onPressed: () {}` is a no-op |
| `lib/features/statistics/screens/student_profile_view_screen.dart` | **Completely hardcoded**: shows "Carlos Mendoza" and a fake email regardless of `studentId` parameter; the parameter is accepted but never used |
| `lib/features/home/screens/home_dashboard_teacher_screen.dart` | "Revisiones Pendientes" and "Próximos Eventos" sections are permanently empty stubs with no data source |
| `lib/features/profile/screens/settings_screen.dart` | Theme/language switches are local-state only (no persistence); "Eliminar cuenta" navigates to `/login` without deleting anything; Privacy policy and Terms `onTap` callbacks are empty `() {}` |
| `lib/features/profile/screens/settings_security_screen.dart` | Biometrics and 2FA are UI toggles with no actual auth integration; session list is hardcoded mock data; Password change bottom sheet makes no API call |
| `lib/features/evidence/screens/evidence_screen.dart` | Not integrated with GoRouter — launches via raw `MaterialPageRoute` from outside the route graph |
| `lib/features/superadmin/screens/superadmin_dashboard_screen.dart` | Uses system Theme throughout — no AppColors, no real data beyond basic structure |
| `lib/features/assignments/screens/assignment_review_screen.dart` | Displays raw `studentId` UUID as "Estudiante:" label — no name resolution |

---

## 🧭 Navigation Gaps

| Issue | Detail |
|-------|--------|
| **`/groups/create` — route does not exist** | `groups_list_screen.dart` FAB calls `context.go('/groups/create')`. No `GoRoute` with this path is defined in `app_router.dart`. Navigating there crashes with a GoRouter "no route found" error. |
| **`evidence_screen.dart` outside router** | The Evidence screen is reached via `MaterialPageRoute`, bypassing GoRouter entirely. There is no `/evidence` route. The app's back/deep-link behavior is broken for this flow. |
| **Course edit flow — dead end** | `course_detail_teacher_screen.dart` "Editar curso" taps `Navigator.pop(context)` instead of navigating to any edit screen. No edit route is defined. |
| **`/statistics/student/:id`** | `student_profile_view_screen.dart` is reached correctly via GoRouter, but the screen ignores the `:id` parameter and always shows hardcoded data. Functionally a dead end in terms of useful output. |
| **Settings deep links** | Privacy policy and Terms of Service `onTap: () {}` in `settings_screen.dart` go nowhere — no web launch or in-app WebView route configured. |
| **Biometric / 2FA flows** | Toggle states in `settings_security_screen.dart` lead nowhere — no enrollment flow or external auth route. |

---

## 👥 Role Coverage

### Student
| Area | Status |
|------|--------|
| Auth (login, register, forgot password) | ✅ Implemented |
| Home dashboard | ⚠️ Partial — AI suggestions card is functional; course list is mock data |
| Course list | ❌ Stub — mock data only |
| Course detail | ❌ Stub — mock data; Resources tab empty forever |
| Activity list (within course) | ⚠️ Partially implemented |
| Activity detail | ⚠️ Partial — view works; submission flow missing |
| Activity submission | ❌ Missing screen |
| Calendar | ⚠️ Partial — events display; day items not tappable; agenda uses mock data |
| Groups list | ❌ Stub — mock data; create navigates to missing route |
| Group detail | ❌ Stub — mock data; task toggle is no-op |
| Global search | ❌ Stub — mock data only |
| Notifications | ⚠️ Partial — list functional; no detail screen |
| AI Chat | ✅ Implemented (providers + history screen complete) |
| AI Settings | ✅ Implemented |
| Statistics / own progress | ⚠️ Partial — screen exists but `Color` violations |
| Evidence | ⚠️ Partial — list exists; outside router; no detail view |
| Profile / Settings | ⚠️ Partial — UI exists; security & account deletion are stubs |
| QR join course | ✅ Implemented (real Supabase call) |

### Teacher
| Area | Status |
|------|--------|
| Home dashboard | ⚠️ Partial — "Revisiones Pendientes" and "Próximos Eventos" are empty stubs |
| Course list | ❌ Stub — mock data; create FAB is no-op |
| Course detail | ❌ Stub — mock data; edit and archive are no-ops |
| Activity create | ❌ Stub — form exists but `_submit()` makes no API call |
| Group management (within course) | ⚠️ Partial — UI exists with severe color violations; limited functionality |
| Student profile view | ❌ Stub — hardcoded "Carlos Mendoza"; ignores `studentId` |
| Teacher statistics | ⚠️ Partial — uses wrong font (`GoogleFonts.outfit`) throughout |
| QR course sharing | ❌ Missing — no QR generator screen |
| AI Tools screen | ✅ Implemented |

### Admin
| Area | Status |
|------|--------|
| Admin shell / navigation | ✅ Implemented |
| User management (list) | ⚠️ Partial — exists; no edit/detail screen |
| Course management | ⚠️ Partial — list + actions exist; `Colors.red` SnackBars |
| Period management | ⚠️ Partial — exists; `Colors.green` violations |
| Statistics (admin) | Unknown — not audited separately |
| Role editing | ❌ Missing — cannot change a user's role from within the app |

### Superadmin
| Area | Status |
|------|--------|
| Dashboard | ❌ Entirely uses system theme — no AppColors; no GoogleFonts.inter |
| Users screen | ⚠️ Partial — system theme; no edit flow |
| Audit log screen | ⚠️ Partial — bare `TextStyle`; `Colors.green`; system theme |
| Institution management | ❌ Missing — no detail, create, or edit screens |

---

## 📊 Summary

### Counts

| Category | Count |
|----------|-------|
| Files with design violations | 30 |
| Missing screens | 13 |
| Stub / incomplete screens | 17 |
| Navigation gaps | 6 |

### Priority Ranking

#### 🔴 Critical
1. **`course_groups_teacher_screens.dart`** — Raw orange/blue AppBars, 7+ raw color names, computed font sizes, extensive `.withOpacity()`. Fails every design rule simultaneously.
2. **`superadmin_dashboard_screen.dart`** — Zero AppColors usage; zero GoogleFonts.inter; uses system Theme throughout.
3. **`statistics_teacher_screen.dart`** — Wrong font family (`GoogleFonts.outfit`) in ~10 places. Every text widget violates the font rule.
4. **`activity_create_screen.dart`** — `_submit()` is a no-op SnackBar. Teachers cannot create activities. Core product functionality broken.
5. **`/groups/create` route missing** — FAB in Groups navigates to a route that does not exist, causing a runtime crash.

#### 🔴 High
6. **`courses_list_screen.dart` / `courses_list_teacher_screen.dart`** — Both show mock courses to all users. Real enrollment data is never loaded.
7. **`course_detail_student_screen.dart` / `course_detail_teacher_screen.dart`** — Mock data; edit/archive are no-ops.
8. **`student_profile_view_screen.dart`** — Ignores `studentId` parameter; always shows hardcoded "Carlos Mendoza".
9. **`global_search_screen.dart`** — Entirely mock data. Search is non-functional.
10. **`groups_list_screen.dart` / `group_detail_screen.dart`** — Mock data throughout; task toggle is no-op.
11. **`evidence_screen.dart`** — Outside the GoRouter graph; uses `MaterialPageRoute`; extensive font/color violations.
12. **`main_shell.dart`** — `Color(0xFF1E1E1E)` hardcoded hex (labeled as `AppColors.modalBg`); `Colors.black54` modal barrier.

#### 🟡 Medium
13. **`superadmin_users_screen.dart` / `superadmin_audit_screen.dart`** — System theme colors; bare TextStyles.
14. **`calendar_screen.dart`** — `Colors.purple`, `Colors.white`, `Colors.grey`; non-tappable day items.
15. **`admin_periods_screen.dart` / `admin_courses_screen.dart`** — `Colors.green`, `Colors.red` throughout.
16. **`settings_screen.dart` / `settings_security_screen.dart`** — UI-only stubs for security, account deletion, legal links.
17. **`statistics_screen.dart`** — Two hardcoded hex colors: `Color(0xFF7A4F00)`, `Color(0xFFAB47BC)`.
18. **`calendar_agenda_screen.dart`** — Uses `TaskModel.mockList`; no real data.
19. **`home_dashboard_teacher_screen.dart`** — Empty "Revisiones" and "Próximos Eventos" stubs; `Colors.white` / `Colors.black` violations.
20. **Auth screens** (`register_screen.dart`, `forgot_password_screen.dart`, `registration_success_screen.dart`, `register_academic_profile_screen.dart`) — `Colors.black` on loading spinners and buttons.

#### 🟢 Low
21. **`notifications_screen.dart`** — `Colors.black` chip text, `Colors.white` delete icon.
22. **`course_create_screen.dart`** — Bare `TextStyle` without `GoogleFonts.inter()` on two inputs.
23. **`assignment_review_screen.dart`** — Raw UUID displayed as student name.
24. **`join_course_screen.dart`** — `Colors.transparent` AppBar, `Colors.red`/`Colors.green` state icons, `Colors.black`/`Colors.white` button foregrounds.
25. **`scan_qr_join_course_screen.dart`** — `Colors.greenAccent` for scan success state (use `AppColors.success`); `.withOpacity()` in overlay; camera-specific `Colors.black` usage is acceptable.
26. **`NotFoundScreen` (app_router.dart)** — `Colors.black87`, `Colors.black54`.
27. **`activity_detail_student_screen.dart`** — `Colors.black`, `Colors.white` in SnackBar style.

### Missing Screens by Priority
| Priority | Missing Feature |
|----------|----------------|
| High | Course Edit screen |
| High | Group Create screen (route crashes) |
| High | Activity Submission screen (student) |
| Medium | Evidence Detail / full-screen view |
| Medium | User Profile Edit screen |
| Medium | QR Generator for teachers |
| Medium | Admin User Detail / Edit screen |
| Medium | Notification Detail screen |
| Low | Superadmin Institution Detail / Create / Edit screens |
| Low | Task Detail screen (standalone) |
| Low | Password Change screen (proper standalone) |
| Low | Push Notification Settings screen |
