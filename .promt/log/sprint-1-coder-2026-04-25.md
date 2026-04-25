# Sprint 1 — Kod Yazma Logu

**Tarih:** 2026-04-25
**Sprint:** Proje Kurulumu & Tasarım Sistemi

---

## Tamamlanan Görevler

- [x] `flutter create myNewHabit` ile proje oluşturuldu → `myNewHabit/`
- [x] `pubspec.yaml` bağımlılıkları eklendi (provider, go_router, sqflite, path, flutter_local_notifications, google_fonts, intl, shared_preferences, uuid, mockito, build_runner)
- [x] `lib/core/theme/app_colors.dart` → Renk sabitleri tanımlandı
- [x] `lib/core/theme/app_typography.dart` → Plus Jakarta Sans + text style'lar
- [x] `lib/core/theme/app_spacing.dart` → 4px grid spacing sabitleri
- [x] `lib/core/theme/app_theme.dart` → ThemeData merkezi tanım (Material 3)
- [x] `lib/core/widgets/app_button.dart` → AppButton (Primary/Secondary/Danger varyantları)
- [x] `lib/core/widgets/app_card.dart` → AppCard (ambient shadow, 16dp radius)
- [x] `lib/core/widgets/app_badge.dart` → AppBadge + PriorityBadge
- [x] `lib/core/widgets/empty_state_widget.dart` → EmptyStateWidget
- [x] `lib/core/router/app_router.dart` → go_router ShellRoute ile navigasyon kurulumu
- [x] `lib/screens/shell/main_shell.dart` → NavigationBar (Material 3) ile 3-tab kabuk
- [x] `lib/screens/home/home_screen.dart` → Home screen placeholder
- [x] `lib/screens/profile/profile_screen.dart` → Profile screen placeholder
- [x] `lib/main.dart` → Uygulama giriş noktası (portrait-only, transparent status bar)
- [x] `flutter analyze` → 0 hata/uyarı
- [x] `flutter test` → 14/14 test geçti

---

## Yazılan Dosyalar

| Dosya | Satır Sayısı | Açıklama |
|---|---|---|
| `lib/core/theme/app_colors.dart` | 68 | Tüm renk sabitleri (brand, surface, error, functional aliases) |
| `lib/core/theme/app_spacing.dart` | 62 | 4px grid spacing + border radii + touch targets |
| `lib/core/theme/app_typography.dart` | 109 | Plus Jakarta Sans, headline/body/label stilleri, Material 3 TextTheme |
| `lib/core/theme/app_theme.dart` | 193 | ThemeData (AppBar, NavigationBar, ElevatedButton, Card, Chip, Input, BottomSheet, SnackBar) |
| `lib/core/widgets/app_button.dart` | 163 | 3 varyantlı buton, loading state, haptic feedback |
| `lib/core/widgets/app_card.dart` | 47 | Ambient shadow kart konteyneri |
| `lib/core/widgets/app_badge.dart` | 76 | AppBadge + PriorityBadge |
| `lib/core/widgets/empty_state_widget.dart` | 47 | Emoji + mesaj + CTA |
| `lib/core/router/app_router.dart` | 33 | go_router ShellRoute + AppRoutes sabitleri |
| `lib/screens/shell/main_shell.dart` | 88 | 3-tab NavigationBar kabuğu |
| `lib/screens/home/home_screen.dart` | 54 | Home screen placeholder |
| `lib/screens/profile/profile_screen.dart` | 31 | Profile screen placeholder |
| `lib/main.dart` | 40 | Uygulama giriş noktası, portrait-only |
| `pubspec.yaml` | 44 | Tüm Sprint 1 bağımlılıkları açıklamalı |

---

## Yazılan Testler

| Test Dosyası | Test Sayısı | Kapsanan Kabul Kriteri |
|---|---|---|
| `test/core/theme/app_colors_test.dart` | 8 | Primary `#0077B6` doğruluğu (US-102), Material 3 aktif |
| `test/screens/navigation_test.dart` | 5 | 3 tab görünür (US-103), tab geçişi, 375px overflow yok, Ekle placeholder |
| `test/widget_test.dart` | 1 | Uygulama hatasız başlar (US-101) |
| **Toplam** | **14** | |

---

## Tamamlanmayan / Bloker Görevler

- [ ] `flutter run` ile cihazda görsel doğrulama — **kullanıcı onayı bekleniyor** (simulator/emulator gerekli)
- [ ] Splash screen & app icon — Sprint 1 kapsamında belirtilmiş; placeholder durumunda kaldı (Flutter varsayılanı)

---

## Notlar

1. **MultiProvider boş liste:** `nested` paketi (provider bağımlılığı) boş `providers: []` listesini assertion ile reddediyor. Sprint 2'de `RecordProvider` eklenene kadar `MaterialApp.router` doğrudan kullanıldı; provider altyapısı kod yorumu olarak hazır.
2. **Google Fonts testlerde:** Widget testleri dışında `GoogleFonts.config.allowRuntimeFetching = false` gerekli; aksi halde `ServicesBinding` hatası oluşuyor. Tüm testlere `setUpAll` ile eklendi.
3. **Tasarım kararları:** `AppColors.primaryContainer = #0077B6` (Agile Plan'da belirtilen primary) ve `AppColors.primary = #005D90` (WCAG kontrast için daha koyu ton) ayrı tutuldu. Butonlar `primaryContainer` kullanır — tasarım çıktısına daha yakın.
4. **go_router `ShellRoute`:** "Ekle" sekmesi rota olmadığından (bottom sheet açacak) sadece 2 rota kayıtlı; index 1 tıklandığında Sprint 2 placeholder SnackBar gösteriyor.
