# Commenting Rules

Code should be **self-documenting**. Comments are not a substitute for clarity — they are reserved for genuinely non-obvious decisions.

---

## The Golden Rule

> **Explain WHY, never WHAT.**

If a comment describes what the code is doing (something already visible from reading the code), delete it.  
If a comment explains *why* an uncommon decision was made, keep it.

---

## When to Write a Comment ✅

Write a comment **only** in these situations:

### 1. Complex business logic explaining a non-obvious "why"
```dart
// Skip count resets each Monday (ISO week start), not on the calendar month.
// This matches the UX spec: users get 1 skip per ISO week per habit.
bool get canSkipThisWeek => _skipUsedThisWeek < 1;
```

### 2. Known limitations or intentional workarounds
```dart
// sqflite does not support BOOLEAN natively.
// We store 1/0 as INTEGER and convert on read.
final isActive = (map['is_active'] as int) == 1;
```

### 3. Public API documentation (`///` doc comments)
Use `///` on all public classes, public methods, and public properties in the `data/` and `providers/` layers. Focus on purpose, not implementation.

```dart
/// Marks the given habit as done for [date] and recalculates its streak.
///
/// Throws [DatabaseException] if the write fails.
Future<void> markDone(String recordId, String date) async { ... }
```

### 4. Documenting a non-intuitive algorithm
```dart
// Streak breaks if there is a gap > 1 day between completions,
// UNLESS a skip was used on that gap day.
int _calculateStreak(List<CompletionModel> completions) { ... }
```

---

## When NOT to Write a Comment ❌

Never write comments that:

- Restate what the code does:
  ```dart
  // ❌ Increments the counter
  _counter++;

  // ❌ Returns the list of records
  return _records;
  ```

- Describe obvious getter/setter behavior:
  ```dart
  // ❌ Gets the current streak
  int get currentStreak => _currentStreak;
  ```

- Are placeholder "TODO" comments left indefinitely without a linked task.

- Comment out dead code. **Delete dead code.** Git history exists for a reason.

---

## Comment Style

| Context | Style | Example |
|---|---|---|
| Public class / method / property | `///` doc comment | `/// The current active streak count.` |
| Complex logic "why" | `//` inline | `// ISO week resets on Monday, per UX spec` |
| Workarounds / limitations | `//` inline | `// sqflite stores bool as INTEGER` |
| TODOs (with context) | `// TODO(sprint-N):` | `// TODO(sprint-4): hook into StreakService` |

---

## Summary Checklist

Before submitting any code, ask yourself:

- [ ] Can I rename this variable/method to make the comment unnecessary?
- [ ] Does this comment explain *why*, not *what*?
- [ ] Are all public APIs documented with `///`?
- [ ] Is there any commented-out code that should be deleted?
