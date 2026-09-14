---
name: hireme-architecture
description: Reference for HireMe's architecture, data paths, conventions, and gotchas. Read before touching backend logic, routing, notifications, chat, auth/session, or any Firebase/Supabase integration. Triggers on "how does X work", "where does X live", "add notification", "chat", "logout", "role", "session", "upload", or any task involving backend services.
allowed-tools:
  - Read
  - Grep
  - Glob
---

# HireMe Architecture Reference

## Stack

- **State & routing:** GetX
- **Backend:** Firebase (Auth, Firestore, RTDB, Messaging) + Supabase (storage, PKCE auth flow)
- **Local session:** `StorageService` — GetX permanent service backed by SharedPreferences
- **Firebase project:** `hireme-a59e6`

## Module Structure

```
lib/app/modules/
  auth/          — splash, onboarding, select_user, login, register, forgot_password
  company/       — dashboard, jobs, chat, profile, application_list, notifications
  job_seeker/    — dashboard, jobs, chat, profile, notifications
  pdf_viewer/
  profile/
```

Models live inline per module at `model/` or `models/` (e.g. `profile/models/`, `application_list/model/`).

## Routing

- Import only `app/routes/app_pages.dart` — `app_routes.dart` is `part of` it, never import directly.
- Use `Routes.*` constants everywhere.
- Protected routes use `RoleGuardMiddleware` — checks `FirebaseAuth.currentUser` + `StorageService`. Mismatch → redirect; null → `/login`.
- `Routes.JOB_SEEKER_SEARCH_JOBS` has **no** middleware — intentionally public.

## Session & Roles

- `AppUserRole` enum: `company` | `jobSeeker`. `.value` yields `'company'` / `'jobSeeker'`.
- `normalizeRole()` maps `jobseeker` / `job seeker` / `job_seeker` → `'jobSeeker'`.
- Always use `StorageService` for role/session data — never raw SharedPreferences.

## Data Paths

| Data | Path |
|------|------|
| Company FCM token | `companies/{uid}` |
| Job seeker FCM token | `jobSeekers/{uid}` |
| FCM fallback | `users/{uid}` |
| In-app notifications | `notifications/{userId}/items/` |
| Chat messages | `chats/{companyId}_{seekerId}/messages/` |
| Chat metadata | `chats/{chatId}` — fields: `companyId`, `seekerId`, `jobId`, `companyName`, `seekerName`, `lastMessage`, `lastMessageTime`, `unreadSeeker`, `unreadCompany` |

## Notifications

- FCM token saved via `NotificationService._saveTokenToFirestore`. `onTokenRefresh` handles rotation.
- `NotificationService.currentScreen` (`RxString`) suppresses foreground popups when already on that screen.
- Foreground popups require `flutter_local_notifications` channel `hireme_notifications` at `Importance.max`.
- Separate notification view modules for `job_seeker/notifications/` and `company/notifications/`.

## Cloud Functions (`functions/index.js`)

4 v2 handlers — all write a notification doc + best-effort FCM push:

| Trigger | Function |
|---------|----------|
| Firestore create — new application | `onNewApplication` |
| Firestore update — application accepted | `onApplicationAccepted` |
| Firestore update — application rejected | `onApplicationRejected` |
| RTDB create — new chat message | `onNewChatMessage` |

## RTDB

- Chat ID constructed as `${companyId}_${seekerId}` — never looked up via `orderByChild`.
- `ChatService.getChats()` queries both `seekerId` and `companyId` indexes.
- `database.rules.json` must have `.indexOn` for `jobId`, `seekerId`, `companyId`, `time`.

## Gotchas

### Storage & writes
- `firebase_storage` is in `pubspec.yaml` but **unused** — all uploads go through Supabase Storage. Do not use `FirebaseStorage` in new code.
- All Firestore writes must use `SetOptions(merge: true)` — never plain `set()`.
- **Supabase Storage has no deletion calls by default** — when deleting any user-generated content (applications, profiles), manually delete linked files from the relevant bucket. Extract filename via `Uri.parse(url).pathSegments.last`. Wrap Storage deletion in an isolated `try-catch` so a failure does not block Firestore or RTDB operations. Reference implementation: `deleteJob` in `application_list_controller.dart`.

### Notification badge streams
Must have `onError` handlers that reset count to 0. Without this, a stream error terminates the subscription permanently and leaves a stale badge. Match the pattern in `JobSeekerDashboardController.listenToNotificationBadge()` and `CompanyDashboardController._notificationsSubscription` exactly.

### Logout — required four-step sequence
`deleteToken()` → `clearAuthSession()` → `signOut()`. Skipping any step leaks FCM tokens or causes stale role state on next login. Implemented in:
- `lib/app/modules/profile/controllers/profile_controller.dart`
- `lib/app/modules/company/company_profile/controllers/company_profile_controller.dart`
- `lib/app/modules/job_seeker/chat/views/chat_view.dart`
- `lib/app/modules/company/company_chat/views/company_chat_view.dart`

## Conventions

- **Imports:** follow each file's existing style (`package:hire_me/...` or relative).
- **UI constants:** `AppColor`, `CustomTextstyle`, `AppString`, `Assets` — all in `lib/core/utils/`.
- **Platform:** Android-only. iOS files from Flutter template are present but unused.

### Do not edit
| File | Reason |
|------|--------|
| `lib/firebase_options.dart` | Generated by `flutterfire configure` |
| `android/app/google-services.json` | Generated by `flutterfire configure` |
| `.env` | Denied in `opencode.json` |
| `lib/core/utils/app_assets.dart` | Auto-generated by `flutter_assets` codegen |