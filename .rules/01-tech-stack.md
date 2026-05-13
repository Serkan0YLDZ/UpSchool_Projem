# Tech Stack & Project Structure

You are a **Senior Flutter & Dart Developer** building the **myNewHabit** habit tracker app. **MVP** hedefi tam **çevrimdışı (yerel öncelik)** çalışmadır; **V2** ile isteğe bağlı **Firebase Auth + Firestore** senkronu eklenebilir. Her zaman onaylı Agile Plan ile hizala.

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
| Cloud / auth (V2 only) | **firebase_core**, **firebase_auth**, **cloud_firestore**, **google_sign_in**, **sign_in_with_apple** — `flutterfire configure` ve Firebase Console adımları zorunludur |
| IDs | **uuid** |

> **MVP:** Uygulama çevrimdışı çalışır; ana veri **SQLite** içindedir.  
> **V2 / bulut modu (isteğe bağlı):** Firebase Authentication (Google, Apple, e-posta) ve Cloud Firestore ile manuel senkron; `lib/data/auth/`, `lib/data/services/cloud_sync_service.dart`, `firebase_options.dart` ve platform yapılandırma dosyaları bu kapsamdadır. V2 kodunda **Bloc, Riverpod, Freezed** kullanılmaz; durum yönetimi yine **Provider** kalır.

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
│   │       ├── event_card.dart
│   │       ├── todo_card.dart
│   │       └── filter_chip_bar.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── modals/
│   ├── add_record_modal.dart
│   ├── naming_modal.dart
│   ├── habit_details_sheet.dart
│   ├── event_timing_sheet.dart
│   └── todo_sheet.dart
└── main.dart
```

**V2 bulut modu ekleri (özet):** `data/auth/`, `data/services/cloud_sync_executor.dart`, `data/services/cloud_sync_service.dart`, `providers/auth_session_provider.dart`, `providers/sync_status_provider.dart`, `firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `firebase/firestore.rules`.

### Firebase Console kontrol listesi (canlı proje)

1. Authentication: Google, Apple, E-posta/şifre açık.  
2. Firestore: tek bölge, kurallar `users/{uid}/...` ile `request.auth.uid` eşlemesi.  
3. Android: `google-services.json` + Play / debug **SHA-1**.  
4. iOS: `GoogleService-Info.plist` + Sign in with Apple capability.  
5. Depoda: `flutterfire configure` ile `firebase_options.dart` ve plist/json gerçek projeyle güncellenir (yer tutucular production’da kullanılmaz).

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
