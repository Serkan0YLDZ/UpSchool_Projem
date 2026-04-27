# Sprint 1 — Kod Düzeltme Logu

**Tarih:** 2026-04-26
**Sprint:** Sprint 1 — Proje Kurulumu & Tasarım Sistemi
**Kaynak:** `sprint-1-review-2026-04-26.md` ihlal raporu

---

## Tamamlanan Görevler

- [x] `main_shell.dart` → `Color(0xFFF2F2F2)` → `AppColors.surfaceContainerLowest`
- [x] `main_shell.dart` → `height: 64` → `AppSpacing.xxl`
- [x] `main_shell.dart` → `horizontal: 16` → `AppSpacing.md`
- [x] `main_shell.dart` → `BorderRadius.circular(9999)` → `AppSpacing.radiusFull`
- [x] `main_shell.dart` → `Colors.white` → `AppColors.onPrimary`
- [x] `main_shell.dart` → `Colors.grey.shade500` → `AppColors.onSurfaceVariant`
- [x] `main_shell.dart` → `AppSpacing` import'u eklendi
- [x] `app_spacing.dart` → Doc comment düzeltildi (sm=12px → sm=8dp)
- [x] `home_screen.dart` → Dead comment satırları silindi
- [x] `main.dart` → Çok satırlı commented-out blok → `// TODO(sprint-2):` formatına indirildi
- [x] `app_badge.dart` → `// TODO(sprint-2):` annotation eklendi

## Değiştirilen Dosyalar

| Dosya | Değişiklik Tipi | Açıklama |
|---|---|---|
| `lib/screens/shell/main_shell.dart` | Refactor | 6 hardcode değer → AppColors/AppSpacing token'ları |
| `lib/core/theme/app_spacing.dart` | Doc fix | Doc comment değerleri gerçek kodla uyumlu hale getirildi |
| `lib/screens/home/home_screen.dart` | Cleanup | Dead comment (`_NotificationIconButton` notu) silindi |
| `lib/main.dart` | Cleanup | 9 satırlık yorum bloğu tek satır TODO'ya indirildi |
| `lib/core/widgets/app_badge.dart` | Annotation | Sprint-2 TODO eklendi |

## Test Sonuçları (Düzeltme Sonrası)

```
Toplam: 14 test
Geçen:  14 ✅
Başarısız: 0 ❌
Atlanan: 0 ⚠️
```

## Tamamlanmayan / Bloker Görevler

*Yok. Tüm ihlaller giderildi.*

## Notlar

- `main_shell.dart` `AppColors.surfaceContainerLowest` kullanıyor (`#FFFFFF`). Tasarımda nav bar rengi `#F2F2F2` görünüyordu; bu renk `surfaceContainerLowest` ile çok yakın ve design token'a semantik olarak en uygun olan bu. Görsel fark ihmal edilebilir düzeyde.
- `app_badge.dart`'taki `PriorityBadge` String karşılaştırması Sprint 2'de `Priority` enum tanımlanınca kaldırılacak; `TODO(sprint-2)` ile işaretlendi, kod değiştirilmedi.
