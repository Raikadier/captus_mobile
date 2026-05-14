<div align="center">

<img src="assets/images/captus.jpeg" alt="Captus" width="100" height="100" />

# Captus Mobile

**Intelligent academic management platform for Latin American universities**

[![CI](https://github.com/Raikadier/captus_mobile/actions/workflows/mobile-ci.yml/badge.svg)](https://github.com/Raikadier/captus_mobile/actions/workflows/mobile-ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.32-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-API_21+-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Firebase](https://img.shields.io/badge/Firebase-Crashlytics_+_FCM-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Supabase](https://img.shields.io/badge/Supabase-Auth_+_DB-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)

[Backend API](https://github.com/Raikadier/captus-backend) · [API Docs](https://captus-backend.vercel.app/api-docs)

</div>

---

## Overview

Captus is a Flutter mobile application that centralizes academic life for students, teachers, and institutional administrators. It combines task management, course tracking, assignment workflows, an AI-powered chat assistant, and real-time push notifications into a single platform — designed specifically for Latin American universities.

The app adapts its interface based on four user roles: **students**, **teachers**, **institution admins**, and **platform superadmins**.

---

## Features

| Feature | Description |
|---|---|
| 📋 **Task Management** | Personal tasks with subtasks, priorities, categories, and streak tracking |
| 🎓 **Courses** | Student enrollment via QR code or invite link; full teacher course management |
| 📝 **Assignments** | Teacher creation and grading; student file-based submissions |
| 🤖 **AI Assistant** | Gemini-powered chat with intent routing, tool execution, and conversation history |
| 📅 **Calendar** | Academic events, deadlines, and agenda view |
| 📊 **Statistics** | Productivity charts, weekly heatmap, streak tracking, achievements |
| 🔔 **Notifications** | FCM push notifications, in-app overlay banner, notification center |
| 👥 **Groups** | Study and project groups with member management |
| 📓 **Notes** | Personal notes with pin support and rich text |
| 🔍 **Evidence** | QR-based attendance and evidence scanning |
| 🏛️ **Admin Panel** | Manage users, courses, grading scales, and academic periods |
| 🌐 **Superadmin Panel** | Multi-institution oversight, audit log, global role management |
| 📵 **Offline Detection** | Animated connectivity banner — real-time network status |
| 🔒 **Session Security** | Auto-logout on inactivity, encrypted token storage |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.32 · Dart 3.5+ |
| **State Management** | Riverpod 3 (`NotifierProvider`, `FutureProvider`, `StreamProvider`) |
| **Navigation** | GoRouter 16 — role-based guards, deep linking |
| **Backend** | Captus REST API (Node.js/Express) via Dio |
| **Authentication** | Supabase Auth (JWT) |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **Crash Reporting** | Firebase Crashlytics |
| **Analytics** | Firebase Analytics |
| **Local Storage** | Hive (cache) · SharedPreferences · SQLite (sqflite) |
| **Voice Input** | speech_to_text |
| **QR** | mobile_scanner · qr_flutter |
| **UI** | Material 3 · Google Fonts · Lottie · Shimmer · flutter_markdown |
| **Testing** | flutter_test · mockito · http_mock_adapter |
| **CI/CD** | GitHub Actions |

---

## Project Structure

```
lib/
├── main.dart                         # Entry point: Firebase, Supabase, FCM, Riverpod
├── firebase_options.dart             # Firebase project config
│
├── core/                             # Shared infrastructure
│   ├── env/env.dart                  # flutter_dotenv typed loader
│   ├── router/app_router.dart        # GoRouter — 17 route groups + role guards
│   ├── theme/app_theme.dart          # Material 3 dark theme
│   ├── constants/app_colors.dart     # Design system color tokens
│   ├── utils/app_errors.dart         # friendlyError() — user-facing Spanish error messages
│   ├── providers/                    # 18 Riverpod providers
│   │   ├── auth_provider.dart        # AuthNotifier — sign in / sign up / sign out
│   │   ├── ai_chat_provider.dart     # AiChatNotifier — send, stop, clear, history
│   │   ├── tasks_provider.dart
│   │   ├── courses_provider.dart
│   │   ├── statistics_provider.dart
│   │   ├── connectivity_provider.dart  # StreamProvider<bool> — real-time network state
│   │   └── ...                       # assignments, events, notifications, groups...
│   └── services/
│       ├── api_client.dart           # Dio singleton with JWT interceptor + CancelToken
│       ├── fcm_service.dart          # FCM: deep-link routing + in-app overlay
│       ├── monitoring_service.dart   # Crashlytics + Analytics wrapper
│       ├── local_notification_service.dart
│       ├── inactivity_service.dart   # Auto-logout timer
│       └── router_service.dart       # Shared GlobalKey<NavigatorState>
│
├── models/                           # Shared data models
│   └── user.dart · course.dart · assignment.dart · submission.dart
│       group.dart · statistics.dart · app_notification.dart · ...
│
├── shared/widgets/                   # Reusable UI components
│   ├── offline_banner.dart           # AnimatedSwitcher connectivity indicator
│   ├── loading_shimmer.dart · course_card.dart
│   ├── streak_badge.dart · empty_state.dart · priority_bar.dart
│   └── countdown_chip.dart
│
└── features/                         # 17 feature modules — 78+ screens
    ├── auth/          # Splash, onboarding, login, register, forgot password
    ├── home/          # Role-based dashboards (student / teacher)
    ├── tasks/         # Task list, detail, create, categories, global search
    ├── courses/       # Enrollment, QR join, course detail, group management
    ├── assignments/   # Teacher creation & review · student submission
    ├── ai_assistant/  # AI chat, conversation history, settings
    ├── calendar/      # Events, agenda, event creation
    ├── statistics/    # Charts, heatmap, achievements, teacher analytics
    ├── notes/         # Personal notes with pin
    ├── notifications/ # Notification center, preferences
    ├── groups/        # Study/project groups
    ├── evidence/      # QR scanner for attendance
    ├── profile/       # Profile view, edit, settings, security
    ├── admin/         # Institution dashboard, users, courses, periods, grading
    ├── superadmin/    # Platform dashboard, institutions, audit log
    └── shell/         # Bottom nav shell with offline banner
```

---

## Getting Started

### Prerequisites

- **Flutter** 3.32+ → [Install guide](https://docs.flutter.dev/get-started/install)
- **Dart** 3.5+
- **Android Studio** or **VS Code** with the Flutter extension
- Android device or emulator (API 21+)
- A running [Captus Backend](https://github.com/Raikadier/captus-backend) instance
- A [Supabase](https://supabase.com) project
- A [Firebase](https://console.firebase.google.com) project (Android app configured)

### 1. Clone & install

```bash
git clone https://github.com/Raikadier/captus_mobile.git
cd captus_mobile
flutter pub get
```

### 2. Configure environment

Create `.env` in the project root:

```dotenv
SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
API_BASE_URL=https://captus-backend.vercel.app/api
```

| Variable | Required | Description |
|---|---|---|
| `SUPABASE_URL` | ✅ | Supabase project URL |
| `SUPABASE_ANON_KEY` | ✅ | Supabase anonymous/public key |
| `API_BASE_URL` | ✅ | Backend base URL including `/api` |

> **Local dev tips:**
> - Android emulator → `API_BASE_URL=http://10.0.2.2:3000/api`
> - Physical device → `API_BASE_URL=http://192.168.x.x:3000/api`

### 3. Configure Firebase

Place `google-services.json` in `android/app/`.

> Download from Firebase Console → Project Settings → Your Android App. This file is excluded from version control.

### 4. Run

```bash
# Debug
flutter run

# Release build
flutter run --release
```

---

## Architecture

### State Management — Riverpod

All business logic lives in Riverpod notifiers. Screens are stateless `ConsumerWidget` or minimal `ConsumerStatefulWidget`.

```dart
// Reading AI chat state
final state = ref.watch(aiChatProvider);

// Sending a message
await ref.read(aiChatProvider.notifier).send('Muéstrame mis tareas pendientes');

// Cancel in-flight AI request
ref.read(aiChatProvider.notifier).stop();

// Reset conversation
ref.read(aiChatProvider.notifier).clear();
```

### Navigation — GoRouter

Routes are grouped by role. Guards redirect unauthenticated users to `/login` and enforce role-based access at the router level.

```
/splash → /onboarding → /login
                          ↓ role check
                    /home        (student shell)
                    /teacher     (teacher shell)
                    /admin       (admin shell)
                    /superadmin  (superadmin shell)
```

Deep links: `captus://join?code=XXXX` → opens the course join screen directly.

### HTTP Client — Dio

`ApiClient` is a Dio singleton that:
- Automatically injects `Authorization: Bearer <token>` on every request
- Supports `CancelToken` for in-flight AI request cancellation
- Maps all errors to user-friendly Spanish strings via `friendlyError()`

### Offline Detection

```dart
// Automatically rebuilds widgets when connectivity changes
final isOnline = ref.watch(isOnlineProvider); // bool
```

The `OfflineBanner` widget mounts at the shell level and animates in/out with `AnimatedSwitcher`.

---

## Build & Release

### Debug APK

```bash
flutter build apk --debug
```

### Release (Play Store)

```bash
# Requires keystore at android/app/upload-keystore.jks
# and android/key.properties configured

flutter build appbundle --release   # Recommended for Play Store
flutter build apk --release         # Direct APK
```

**Build settings** (`android/app/build.gradle.kts`):

| Setting | Value |
|---|---|
| `applicationId` | `com.captus.app` |
| `minSdk` | 21 (Android 5.0+) |
| `targetSdk` | 34 (Android 14) |
| `minifyEnabled` | `true` (release) |
| `shrinkResources` | `true` (release) |
| ProGuard rules | `proguard-rules.pro` |

---

## Testing

```bash
# All tests
flutter test

# Single file
flutter test test/providers/ai_chat_provider_test.dart

# With coverage
flutter test --coverage
```

| Suite | Tests | Description |
|---|---|---|
| `ai_chat_provider_test` | 30 | AiStep model, state machine, send/stop/clear |
| `tasks_provider_test` | ~15 | Task CRUD state transitions |
| `courses_provider_test` | ~12 | Course loading and enrollment |
| `auth_provider_test` | ~10 | Sign-in, sign-up, sign-out flows |
| `api_client_test` | ~8 | HTTP client with mock adapter |
| `local_user_test` | ~6 | LocalUser model serialization |

---

## CI/CD Pipeline

Every push to `master` and every PR triggers two jobs:

**1. Analyze & Test** (ubuntu-latest)
- Flutter 3.32 setup
- Creates `.env` from GitHub secrets
- `flutter pub get`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
- Coverage upload to Codecov

**2. Build APK** (master only)
- `flutter build apk --debug`
- Artifact upload (7-day retention)

---

## Permissions

| Permission | Purpose |
|---|---|
| `INTERNET` | API & Supabase communication |
| `CAMERA` | QR code scanning |
| `READ_MEDIA_IMAGES` | Image picker (Android 13+) |
| `RECORD_AUDIO` | Voice input — AI assistant |
| `ACCESS_FINE_LOCATION` | Location services |
| `POST_NOTIFICATIONS` | FCM push notifications (Android 13+) |
| `RECEIVE_BOOT_COMPLETED` | Reschedule local notifications on reboot |
| `VIBRATE` | Notification haptics |

---

## Monitoring

| Service | Purpose |
|---|---|
| **Firebase Crashlytics** | Automatic crash capture + Flutter error boundaries |
| **Firebase Analytics** | User events: login, task created, AI message sent |

Both are initialized in `main.dart` before `runApp()` and integrated with `FlutterError.onError` and `PlatformDispatcher.onError`.

---

## Test Accounts

The project includes **585 seeded users** across 5 Colombian universities.

**Universal password:** `123456789`

| Role | Example email |
|---|---|
| Student | `estudiante@unal.edu.co` |
| Teacher | `docente@udea.edu.co` |
| Admin | `admin@univalle.edu.co` |
| Superadmin | `super@captus.app` |

**Universities:** UNAL (Bogotá) · UdeA (Medellín) · Univalle (Cali) · Uniandes (Bogotá) · Unicesar (Valledupar)

---

## Related Repositories

| Repo | Description |
|---|---|
| [captus-backend](https://github.com/Raikadier/captus-backend) | Node.js/Express REST API + AI backend |
| [API Docs](https://captus-backend.vercel.app/api-docs) | Swagger UI — interactive API reference |

---

## Contributing

1. Fork the repository
2. Create a branch: `git checkout -b feat/my-feature`
3. Follow existing patterns: feature modules in `lib/features/`, providers in `lib/core/providers/`
4. Write tests for new providers and models
5. Ensure `dart analyze` passes with zero issues
6. Open a Pull Request against `master`

---

## License

[MIT](LICENSE) © Captus Project

---

<div align="center">

Built with ❤️ for Latin American higher education · [captusproject123@gmail.com](mailto:captusproject123@gmail.com)

</div>
