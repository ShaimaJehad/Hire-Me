---
name: flutter-code-review
description: Run a self-review checklist before completing a task. Use when the user says "task done", "work is done", "finished", "review this", or when verifying code quality and safety before approval.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(git diff)
  - Bash(git status)
  - Bash(flutter analyze --no-fatal-infos --no-fatal-warnings)
---

# Code Completion Self-Review

Run this checklist before marking any task as done. This is a read-only review — do not modify code during this step.

## Correctness

- [ ] The root cause is correctly identified and addressed (not just symptoms).
- [ ] The solution handles the specific problem described in the task.
- [ ] Edge cases are handled: null, empty, loading, and error states.
- [ ] No silent failures — errors surface via snackbar, dialog, or state update.

## Architecture Compliance (GetX / HireMe)

- [ ] Feature follows the structure: `modules/{feature}/bindings/`, `controllers/`, `views/`.
- [ ] Controller registered in its Binding class — not instantiated manually.
- [ ] No business logic inside views — views call controller methods only.
- [ ] Firebase/Supabase calls live in the controller or a service — never in a view.
- [ ] `StorageService` used for role/session data — not direct SharedPreferences calls.
- [ ] Role guard respected — protected routes use `RoleGuardMiddleware`.
- [ ] Shared logic placed in `lib/core/` — not duplicated across features.

## Safety

- [ ] No existing flows, routes, or UX broken.
- [ ] No performance regressions (unnecessary Obx wraps, heavy build methods, missing const).
- [ ] No hardcoded secrets — Supabase credentials loaded from `.env` only.
- [ ] No unused imports, dead code, or debug print statements left behind.
- [ ] Controllers properly closed/disposed — `onClose()` overridden if needed.

## Code Quality

- [ ] Code is clean, readable, and follows project conventions.
- [ ] Dart naming conventions followed (camelCase variables, PascalCase classes).
- [ ] GetX reactive variables use `.obs` where needed.
- [ ] No unnecessary `update()` calls — prefer reactive `.obs` over manual rebuilds.
- [ ] Import ordering correct (dart → flutter → packages → project).
- [ ] `flutter analyze` passes with no new warnings.

## Output

After completing the checklist, provide a brief summary:

1. **What** was changed
2. **Why** it was changed
3. **Why** the solution is safe and correct

If any checklist item fails, flag it and suggest a fix before proceeding.