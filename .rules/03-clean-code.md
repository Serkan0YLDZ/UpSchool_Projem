# Clean Code & YAGNI Rules

Write code that is **easy to read, easy to delete, and nothing more than what is needed today.**

---

## YAGNI — You Aren't Gonna Need It

This project is in **MVP phase**. The V2+ features are explicitly documented in `agilePlan.md` and `prd.md`.

- **Do NOT implement** any feature listed under "V2+ / Gelecekte Eklenecek Özellikler."
- **Do NOT add** abstract layers, generic factories, plugin systems, or extra abstraction "just in case."
- **Do NOT add** parameters, fields, or methods to a class unless they are immediately required.
- When in doubt, write the **simplest thing that satisfies the current user story.**

```dart
// ❌ Wrong: Adding a "categoryId" field because "we might need it later"
class RecordModel {
  final String id;
  final String title;
  final String? categoryId; // Not in MVP. Don't add it.
}

// ✅ Correct: Only what the Agile Plan defines
class RecordModel {
  final String id;
  final RecordType type;
  final String title;
  final String? icon;
  final Priority? priority;
  final List<String> repeatDays;
  final String? scheduledTime;
  final DateTime? endDate;
  final DateTime createdAt;
  final bool isActive;
}
```

---

## DRY — Don't Repeat Yourself

- If the same UI pattern appears in **2 or more screens**, extract it into `lib/core/widgets/`.
- If the same database query appears in 2 methods, extract a private helper.
- Do not copy-paste code. Refactor instead.

```dart
// ❌ Wrong: Same card padding repeated in every screen
Padding(padding: EdgeInsets.all(16), child: HabitCard(...))
Padding(padding: EdgeInsets.all(16), child: TaskCard(...))

// ✅ Correct: Shared AppCard wraps consistent padding
AppCard(child: HabitCard(...))
AppCard(child: TaskCard(...))
```

---

## Private Widget Classes (Never Use Builder Methods)

This is **non-negotiable**. Function-based sub-widgets cause unnecessary rebuilds and poor readability.

```dart
// ❌ Never do this
Widget _buildHeader() => Text('Bugün');

// ✅ Always do this
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Text('Bugün');
}
```

- Screen-specific sub-widgets live in a `widgets/` subfolder alongside their parent screen.
- Widgets reused across multiple screens go in `lib/core/widgets/`.

---

## Function & Class Size Limits

| Rule | Limit |
|---|---|
| Lines per UI file | Max **250 lines** |
| Lines per function / method | Max **40 lines** |
| Public methods per class | Max **10** |
| Properties per class | Max **10** |

If you exceed these limits, **refactor into smaller, focused units** before continuing.

---

## Self-Documenting Code

Code must read like prose. If you need a comment to explain what the code does, the code is not clean enough — rename and simplify first.

```dart
// ❌ Unclear + needs a comment
int d = DateTime.now().difference(last).inDays; // days since relapse

// ✅ Clear without a comment
int daysSinceLastRelapse = DateTime.now().difference(lastRelapseDate).inDays;
```

---

## Miscellaneous Clean Code Rules

- Use `const` constructors for all immutable widgets and values.
- Use **arrow syntax** for single-expression methods: `int get count => _records.length;`
- Use **trailing commas** in multi-line parameter lists (enables `dart format` to expand them).
- Use `log()` from `dart:developer` instead of `print()` for all debug output.
- Use `enum` instead of raw `String` constants for finite sets of values (`RecordType`, `Priority`, `CompletionStatus`).
- Write boolean extension getters for every `enum`:

```dart
enum Priority { low, medium, high }

extension PriorityX on Priority {
  bool get isHigh   => this == Priority.high;
  bool get isMedium => this == Priority.medium;
  bool get isLow    => this == Priority.low;
}
```

- Wrap any screen containing `TextField` or a form in a `GestureDetector` that calls `FocusScope.of(context).unfocus()` on tap.
- Always use `ListView.builder` (never `ListView` with hardcoded children) for dynamic lists.
- Always provide an `errorBuilder` when using `Image.network`.
