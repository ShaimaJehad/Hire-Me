---
name: flutter-pr
description: Generate git branch name, commit message, and pull request description. Invoke AFTER flutter-code-review passes. Use after code review is approved, when the user says "create PR", "submit", "push this", or when finalizing changes for submission.
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
---

# Git & Pull Request Output

Generate the following after task completion and approval.

## Branch Name

Use conventional format:

```
fix/<short-description>
feat/<short-description>
refactor/<short-description>
perf/<short-description>
chore/<short-description>
```

Keep it lowercase, hyphen-separated, concise. Example: `feat/company-chat-unread-badge`

## Commit Message

Follow conventional commit format:

```
<type>(<scope>): <short summary>

<optional body — explain why, not what>
```

- Types: `fix`, `feat`, `refactor`, `perf`, `chore`, `test`, `docs`
- Scope: use the module name from `lib/app/modules/` (e.g., `auth`, `company`, `job_seeker`, `core`)
- Summary: imperative mood, no period, max 72 characters
- Body: only when the "why" isn't obvious from the summary

Examples:
```
feat(job_seeker): add saved jobs pagination

fix(auth): prevent role mismatch after login with cached session

refactor(core): move StorageService role normalization to helper
```

## Pull Request Title

- Clear, descriptive, concise.
- Match the commit type when possible.
- Example: `feat(company): Add unread message badge to chat tab`

## Pull Request Description

Format in markdown. Keep it concise and to the point.

```markdown
## Summary
Brief description of what this PR does and why.

## Changes
- Key change 1
- Key change 2

## Root Cause (bug fixes only)
What caused the bug and how this PR addresses it.

## Testing
- [ ] Tested on Android
- [ ] Role guard works correctly for both roles
- [ ] No Firebase/Supabase errors in console
```