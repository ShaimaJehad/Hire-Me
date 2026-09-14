---
name: hireme-testing
description: Testing conventions and patterns for HireMe. Read before writing, editing, or running any test. Triggers on "write test", "add test", "test this", "fix test", "run tests", or any task involving files under test/.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(flutter test *)
---

# HireMe Testing Reference

## Rules

- **Manual fakes only** — no mockito, no mocktail.
- No Firebase or Supabase initialization needed in tests.
- Call `Get.reset()` in `tearDown` to isolate GetX state between tests.

## Existing Test Files

| File | What it covers |
|------|----------------|
| `test/widget_test.dart` | Placeholder only |
| `test/auth_login_controller_test.dart` | Login controller logic |
| `test/job_seeker_dashboard_controller_test.dart` | Job seeker dashboard + filter logic |
| `test/application_review_controller_test.dart` | Application review flow |
| `test/profile_controller_test.dart` | Profile controller |
| `test/company_dashboard_controller_test.dart` | Company dashboard |

## Fake Pattern

Replicate controller logic with top-level helper functions and plain fake classes. Do not use real controllers or services.

```dart
// Fake model — keep public so top-level functions can use it
class FakeJob {
  final String title;
  final String location;
  FakeJob({required this.title, required this.location});
}

// Mirror the controller's filter logic as a top-level function
List<FakeJob> applyFilters(List<FakeJob> jobs, String query) {
  if (query.isEmpty) return jobs;
  return jobs.where((j) => j.title.contains(query)).toList();
}
```

**Naming rule:** Test-only types must be `public` (`FakeJob`) — `_`-prefixed types used inside public top-level functions trigger lint errors.

## Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(() => Get.reset());

  group('applyFilters', () {
    test('returns all jobs when query is empty', () {
      final jobs = [FakeJob(title: 'Dev', location: 'Remote')];
      expect(applyFilters(jobs, ''), jobs);
    });

    test('filters by title', () {
      final jobs = [
        FakeJob(title: 'Dev', location: 'Remote'),
        FakeJob(title: 'Designer', location: 'Local'),
      ];
      expect(applyFilters(jobs, 'Dev'), [jobs[0]]);
    });
  });
}
```

## Running Tests

```bash
flutter test                        # All tests
flutter test test/<file>.dart       # Single file
flutter test --no-pub               # Skip pub get (faster, matches CI)
```