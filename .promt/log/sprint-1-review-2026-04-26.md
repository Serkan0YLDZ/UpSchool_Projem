# Kod Analiz Logu

**Tarih:** 2026-04-26
**Hedef:** Sprint 1 — Proje Kurulumu & Tasarım Sistemi
**Analist:** Antigravity (02-code-reviewer.md)

---

## Genel Değerlendirme

Sprint 1 kodu genel olarak kurallara **yüksek düzeyde uygunluk** gösteriyor. Design token sistemi eksiksiz kurulmuş, folder structure büyük ölçüde doğru, go_router + ShellRoute kurulumu doğru yapılmış. Bulunan ihlaller kritik değil; kısa vadede düzeltilebilir düzeyde.

---

## Bulunan İhlaller

| Dosya | Satır | İhlal | Kural | Öneri |
|---|---|---|---|---|
| `lib/screens/shell/main_shell.dart` | 83 | `Color(0xFFF2F2F2)` hardcode renk | 05-flutter-ui → Design System | `AppColors.surfaceContainerLowest` veya `AppColors.surfaceContainerLow` kullan |
| `lib/screens/shell/main_shell.dart` | 80 | `height: 64` hardcode spacing | 05-flutter-ui → Design System | `AppSpacing.xxl` (64) veya yeni `AppSpacing.navBarHeight` sabiti tanımla |
| `lib/screens/shell/main_shell.dart` | 81 | `EdgeInsets.symmetric(horizontal: 16)` hardcode | 05-flutter-ui → Design System | `EdgeInsets.symmetric(horizontal: AppSpacing.md)` |
| `lib/screens/shell/main_shell.dart` | 84 | `BorderRadius.circular(9999)` hardcode | 05-flutter-ui → Design System | `BorderRadius.circular(AppSpacing.radiusFull)` |
| `lib/screens/shell/main_shell.dart` | 147 | `Colors.grey.shade500` hardcode renk | 05-flutter-ui → Design System | `AppColors.onSurfaceVariant` |
| `lib/screens/shell/main_shell.dart` | 146 | `Colors.white` hardcode renk | 05-flutter-ui → Design System | `AppColors.onPrimary` |
| `lib/core/widgets/app_button.dart` | 166-173 | `color: AppColors.onPrimary` doğrudan renk; loading state spinner rengi | Küçük tutarsızlık | Sorun yok ama `danger` variant'ında loading spinner rengi `onError` olmalı |
| `lib/core/theme/app_spacing.dart` | 6 | Doc comment'te `sm=12px` yazıyor ama kod `sm=8` tanımladı; `smMd=12` | 04-commenting | Doc comment'i düzelt: `sm = 8dp`, `smMd = 12dp` |
| `lib/screens/home/home_screen.dart` | 26 | Commented-out kod satırı (`// Not: _NotificationIconButton artık kullanılmıyor`) | 04-commenting | Dead code yorumu silindi değil, git history'e terk edilmeli |
| `lib/main.dart` | 39-45 | Commented-out `MultiProvider` kodu | 04-commenting | `// TODO(sprint-2):` formatında kısalt veya tamamen sil |
| `lib/core/widgets/app_badge.dart` | 63 | String literal ile öncelik karşılaştırması (`'high' \|\| 'yüksek'`) | 01-tech-stack / 03-clean-code | Sprint 2'de `Priority` enum tanımlanınca `enum` ile değiştirilmeli — `// TODO(sprint-2):` ekle |

### Mimari Kontroller

| Kontrol | Durum |
|---|---|
| UI'da iş mantığı yok mu? | ✅ Temiz |
| Bağımlılıklar constructor'dan inject ediliyor mu? | ✅ (Sprint 1'de henüz provider yok, doğru) |
| SRP: Tek sorumluluk | ✅ |
| Folder structure doğru mu? | ⚠️ Eksik: `lib/data/` hiç oluşturulmamış (Sprint 1 kapsamında bekleniyor mu? → Hayır, Sprint 2 kapsamı) |

### Kod Kalitesi

| Kontrol | Durum |
|---|---|
| Fonksiyon ≤ 40 satır | ✅ Tüm metodlar kısa |
| UI dosya ≤ 250 satır | ✅ En büyük: `app_theme.dart` 236 satır, sınırda ama OK |
| `Widget _buildX()` fonksiyon widget yok | ✅ Hepsi private class olarak ayrılmış |
| Hardcode renk/spacing yok | ⚠️ `main_shell.dart`'ta 4 ihlal |
| `enum` yerine `String` sabit yok | ✅ (Sprint 2 ihlal adayı: `PriorityBadge` string karşılaştırması) |
| `print()` yerine `log()` | ✅ Print yok |
| `ListView.builder` kullanımı | ✅ (Sprint 1'de dinamik liste yok) |

### Flutter Performans

| Kontrol | Durum |
|---|---|
| `const` kullanımı | ✅ Tüm stateless widget'lar const |
| `Consumer` scope dar | ✅ (Sprint 1'de provider kullanımı yok) |
| Loading/Error/Empty state | ✅ EmptyStateWidget mevcut |
| TextField screen unfocus | ✅ (Sprint 1'de form yok) |

### Yorum Satırları

| Kontrol | Durum |
|---|---|
| WHAT yorumu yok | ⚠️ `main.dart:38` MultiProvider yorum bloğu WHAT niteliğinde |
| WHY yorumları var | ✅ Önemli kararlar açıklanmış |
| Public metodlar `///` ile belgelenmiş | ✅ data/ ve providers/ katmanları henüz Sprint 1'de yok; mevcut public sınıflarda `///` var |

---

## Test Kapsamı

| Kabul Kriteri | ID | Durum |
|---|---|---|
| `flutter run` hatasız çalışır | US-101 | ✅ Smoke test geçiyor |
| 3 tab görünür ve tıklanabilir | US-103 | ✅ `navigation_test.dart` kapsıyor |
| Profil tabına geçiş çalışıyor | US-103 | ✅ Kapsanmış |
| Ana sayfa varsayılan açılıyor | US-103 | ✅ Kapsanmış |
| `primary` renk `#0077B6` doğru | US-102 | ✅ `app_colors_test.dart` kapsıyor |
| Plus Jakarta Sans yüklü | US-102 | ⚠️ Test ortamında font HTTP'de devre dışı; font yüklenip yüklenmediği test edilmiyor |
| AppTheme Material 3 aktif | US-102 | ✅ Kapsanmış |
| 375px'te overflow yok | US-101 | ✅ Kapsanmış |
| Ekle butonuna tıklama SnackBar | US-103 | ✅ Kapsanmış |

---

## Test Sonuçları

```
Toplam: 14 test (3 dosya)
Geçen:  14 ✅
Başarısız: 0 ❌
Atlanan: 0 ⚠️
```

### Başarısız Testler
*Yok*

---

## Eklenen Testler

Eksik test yazma gereksinimi tespit edilmedi (mevcut testler Sprint 1 kabul kriterlerini yeterince kapsıyor). Aşağıdaki test önerileri sonraki sprint'lerde veya isteğe bağlı olarak eklenebilir:

| Test Önerisi | Kapsanan Kriter |
|---|---|
| `AppTypography.headlineSm` font family'nin `Plus Jakarta Sans` içerdiğini doğrula | US-102 |
| `AppButton` primary variant'ın `AppColors.primaryContainer` arka planını kullandığını doğrula | US-102 |
| `AppCard` kart radius'unun `AppSpacing.radiusLg` (16dp) olduğunu doğrula | US-102 |

---

## Sonuç ve Öneriler

**Sprint 2'ye geçilebilir.** Kritik bir sorun yok.

### Önce Düzeltilmesi Gereken (Sprint 2 başlamadan):
1. `main_shell.dart` → `Color(0xFFF2F2F2)`, `Colors.grey.shade500`, `Colors.white`, `height: 64`, `horizontal: 16`, `BorderRadius.circular(9999)` → Design token'lara çevir
2. `app_spacing.dart` satır 6 → Doc comment düzelt (`sm=8dp`)

### Sprint 2 Başlarken TODO Olarak Bırak:
3. `app_badge.dart` → `PriorityBadge`'deki String karşılaştırmasına `// TODO(sprint-2): enum Priority kullanılacak` ekle
4. `main.dart` → Yorum bloğunu `// TODO(sprint-2): MultiProvider ekle` şeklinde sadeleştir

**Düzeltmeler için:** `01-sprint-coder.md` promptunu kullan.
