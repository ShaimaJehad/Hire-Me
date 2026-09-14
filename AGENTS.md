# AGENTS.md — HireMe

## Required Workflow

Read the relevant skill from `hireme_skills/` **before** writing any code.

| When | Skill |
|------|-------|
| Before any new controller or feature screen | `flutter-getx-controller` |
| Before touching backend, routing, notifications, chat, auth, or uploads | `hireme-architecture` |
| Before writing or editing any test | `hireme-testing` |
| After completing work, before marking done | `flutter-code-review` |
| Before committing or opening a PR | `flutter-pr` |

## Commands

```bash
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings   # exact flags — must match CI
flutter test --no-pub                       # matches CI; omit --no-pub locally if needed
flutter test test/<file>.dart               # single file
flutter run
flutter build apk --release
```

**CI pipeline:** `pub get` → `analyze` → `test --no-pub` → `build apk --release` → Firebase App Distribution. Flutter `3.41.6`, Java 17.

### Deploy (project root only)

```bash
firebase deploy --only database          # after editing database.rules.json
firebase deploy --only functions         # after editing functions/index.js
firebase deploy --only firestore:indexes
```

## Gotchas & Conventions

- **Testing:** Manual fakes only — no mockito, no mocktail. Call `Get.reset()` in `tearDown`. No Firebase/Supabase init needed in tests.
- **Firestore:** All writes must use `SetOptions(merge: true)` — never plain `set()`.
- **Logout (four-step):** `deleteToken()` → `clearAuthSession()` → `signOut()`. Skipping any step leaks FCM tokens.
- **Notification badges:** Stream subscriptions must have `onError` handler that resets count to 0, else a stream error kills the badge permanently.
- **Storage:** `firebase_storage` is in `pubspec.yaml` but **unused** — all uploads go through Supabase Storage.
- **Routing:** Import only `app/routes/app_pages.dart` — `app_routes.dart` is `part of` it. Use `Routes.*` constants. Protected routes use `RoleGuardMiddleware`; `Routes.jobSeekerSearchJobs` has **no** middleware (intentionally public).
- **UI constants:** `AppColor`, `CustomTextstyle`, `AppString`, `Assets` — all in `lib/core/utils/`.
- **Codegen:** `lib/core/utils/app_assets.dart` is auto-generated. Do not edit manually.
- **Platform:** Android only. iOS/macOS/Windows/Linux files are Flutter template defaults, unused.

## Entrypoint (`lib/main.dart`)

`dotenv.load` → `Firebase.initializeApp` + `Supabase.initialize` (parallel, with `Firebase.apps.isEmpty` guard) → `Get.putAsync(StorageService)` → `Get.putAsync(NotificationService)` → `runApp`. Background FCM handler registered before init.
