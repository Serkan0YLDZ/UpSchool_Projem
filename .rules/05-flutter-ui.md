# Flutter & UI Performance Rules

Every widget decision must consider **rebuild cost, render efficiency, and design consistency.**

---

## 1. Use `const` Everywhere Possible

`const` widgets are created once and never rebuilt unnecessarily. This is the single most impactful performance optimization in Flutter.

```dart
// ✅ Correct
const SizedBox(height: AppSpacing.md),
const Text('Bugün'),
const _Header(),

// ❌ Wrong — widget rebuilds on every parent rebuild
SizedBox(height: 16),
Text('Bugün'),
```

**Rule:** Every widget that does not depend on runtime state must be `const`. The linter will warn you — treat it as an error.

---

## 2. Narrow `Consumer` Scope

`Consumer<T>` forces a subtree to rebuild when the provider notifies. Keep it as **small as possible** — never wrap an entire screen in `Consumer` when only one widget needs the data.

```dart
// ❌ Wrong: entire scaffold rebuilds when provider changes
Consumer<RecordProvider>(
  builder: (context, provider, _) => Scaffold(
    body: Column(children: [...]),
  ),
);

// ✅ Correct: only the list rebuilds
Scaffold(
  body: Column(
    children: [
      const _CalendarBar(),
      Consumer<RecordProvider>(
        builder: (context, provider, _) => _HabitList(records: provider.records),
      ),
    ],
  ),
);
```

---

## 3. Always Use `ListView.builder` for Dynamic Lists

Never use `ListView` with a hardcoded `children` list for data-driven content. `ListView.builder` is lazy — it only builds visible items.

```dart
// ✅ Correct
ListView.builder(
  itemCount: records.length,
  itemBuilder: (context, index) => HabitCard(record: records[index]),
);

// ❌ Wrong
ListView(
  children: records.map((r) => HabitCard(record: r)).toList(),
);
```

---

## 4. Flatten Widget Trees

Deep nesting increases build time and reduces readability. Break large widget trees into small, named private widget classes.

- Max nesting depth: **~4–5 levels** before extracting a sub-widget.
- Never use `Column > Column > Column > Column` chains for what could be a single `_SectionCard` widget.

---

## 5. Design System — Never Hardcode Values

| Instead of | Use |
|---|---|
| `Color(0xFF0077B6)` | `AppColors.primary` |
| `TextStyle(fontSize: 16)` | `Theme.of(context).textTheme.bodyMedium` |
| `EdgeInsets.all(16)` | `EdgeInsets.all(AppSpacing.md)` |
| `SizedBox(height: 8)` | `SizedBox(height: AppSpacing.sm)` |

All colors, text styles, and spacing values must come from the design system defined in `lib/core/theme/`.

---

## 6. Theme API — Use Material 3 Text Style Names

Always use the current Material 3 naming. The old Material 2 names are deprecated.

| ❌ Deprecated | ✅ Use Instead |
|---|---|
| `headline6` | `titleLarge` |
| `headline5` | `headlineSmall` |
| `headline4` | `headlineMedium` |
| `bodyText1` | `bodyLarge` |
| `bodyText2` | `bodyMedium` |
| `caption` | `bodySmall` |

---

## 7. Responsive Layout

The app must render correctly on **iPhone SE (375px width)** and larger screens (acceptance criterion from Agile Plan).

- Use `LayoutBuilder` or `MediaQuery` when sizing needs to adapt.
- Use `Flexible` / `Expanded` instead of hardcoded widths inside `Row`/`Column`.
- Never use a hardcoded pixel width that exceeds 375dp for any full-width element.

---

## 8. Haptic Feedback for Key Interactions

Add tactile feedback for primary completion actions. Keep it subtle.

```dart
// In habit completion toggle
await HapticFeedback.lightImpact();
```

Use `lightImpact` for toggles/checkmarks, `mediumImpact` for destructive actions (e.g., "Relapse" reset).

---

## 9. Animation Guidelines

- Use `AnimatedContainer` for color/size transitions (e.g., selected day in calendar bar).
- Use `AnimatedOpacity` for fade-in of completion checkmarks.
- Keep animation durations between **150ms – 300ms**.
- Do not use `AnimationController` for simple transitions — prefer implicit animation widgets.

---

## 10. Error & Empty States Are Mandatory

Every list or data-dependent section **must** handle all three states:

```dart
Widget build(BuildContext context) {
  return Consumer<RecordProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) return const _LoadingIndicator();
      if (provider.hasError) return _ErrorView(message: provider.errorMessage);
      if (provider.records.isEmpty) return const EmptyStateWidget();
      return _RecordList(records: provider.records);
    },
  );
}
```

- Loading: `CircularProgressIndicator` centered.
- Error: meaningful message via `ScaffoldMessenger.showSnackBar`.
- Empty: `EmptyStateWidget` from `lib/core/widgets/` with a call-to-action.
