# Tech Stack & Project Structure

You are a **Senior Flutter & Dart Developer** building the **myNewHabit** habit tracker app. This app runs fully **offline (local-only)** with no backend integration in the MVP. Always align your code with the approved Agile Plan.

---

## Core Tech Stack

| Layer | Technology |
|---|---|
| Language | Dart (with full null safety) |
| Framework | Flutter |
| State Management | **Provider** (ChangeNotifier-based) |
| Navigation | **go_router** |
| Local Database | **sqflite** (SQLite) |
| Notifications | **flutter_local_notifications** |
| Fonts | **google_fonts** (Plus Jakarta Sans) |
| Date/Time | **intl** |
| Persistence | **shared_preferences** (onboarding flags only) |
| IDs | **uuid** |

> **No backend, no Firebase, no Supabase, no Bloc, no Riverpod, no Freezed.**  
> The app is local-only. Do not introduce any cloud dependency in the MVP.

---

## Mandatory Folder Structure

Follow this structure exactly. Do not deviate.

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       # Color constants only
│   │   ├── app_typography.dart   # TextStyle definitions
│   │   ├── app_spacing.dart      # 4px-grid spacing constants
│   │   └── app_theme.dart        # Central ThemeData
│   └── widgets/                  # Shared reusable widgets
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── app_badge.dart
│       └── empty_state_widget.dart
├── data/
│   ├── database/
│   │   └── database_helper.dart  # sqflite singleton + migrations
│   ├── models/
│   │   ├── record_model.dart
│   │   ├── completion_model.dart
│   │   └── streak_model.dart
│   ├── repositories/
│   │   ├── record_repository.dart
│   │   └── completion_repository.dart
│   ├── services/
│   │   ├── streak_service.dart
│   │   └── notification_service.dart
│   └── defaults/
│       └── default_habits.dart
├── providers/
│   ├── record_provider.dart
│   └── completion_provider.dart
├── screens/
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/              # Screen-private widgets
│   │       ├── calendar_bar_widget.dart
│   │       ├── habit_card.dart
│   │       ├── task_card.dart
│   │       ├── quit_card.dart
│   │       └── filter_chip_bar.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── modals/
│   ├── add_record_modal.dart
│   ├── naming_modal.dart
│   ├── habit_details_sheet.dart
│   ├── task_timing_sheet.dart
│   └── quit_sheet.dart
└── main.dart
```

---

## File & Naming Conventions

- **Files & directories:** `snake_case` (e.g., `habit_card.dart`)
- **Classes:** `PascalCase` (e.g., `HabitCard`, `RecordRepository`)
- **Variables & methods:** `camelCase` (e.g., `currentStreak`, `markAsDone`)
- **Constants:** `SCREAMING_SNAKE_CASE` for env values; `lowerCamelCase` for code constants
- **Boolean variables:** always use auxiliary verbs — `isLoading`, `hasError`, `canSkip`, `isActive`
- **Method names:** start with a verb — `fetchRecords()`, `markDone()`, `calculateStreak()`
- One public export per file.
- Use `underscore_case` for private class members: `_records`, `_dbHelper`.

---

## Design Tokens (Never hardcode these values)

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  static const primary   = Color(0xFF0077B6);
  static const secondary = Color(0xFF90E0EF);
  static const tertiary  = Color(0xFF00B4D8);
  static const neutral   = Color(0xFFF8FBFF);
}
```

Font: **Plus Jakarta Sans** via `google_fonts`.  
Spacing: **4px grid** — use `AppSpacing.xs (4)`, `sm (8)`, `md (16)`, `lg (24)`, `xl (32)`.
