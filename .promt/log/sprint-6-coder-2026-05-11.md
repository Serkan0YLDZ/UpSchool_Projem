# Sprint 6 — Kod Yazma Logu

**Tarih:** 2026-05-11  
**Sprint:** Seri (Streak) Sistemi & Es Geçme

## Tamamlanan Görevler

- [x] PRD ve agilePlan Sprint 6 seri kuralları (grace, kurtarma, sert kapanış, görünürlük) → [prd.md](../prd.md), [agilePlan.md](../agilePlan.md)
- [x] DB v6 migration + `streaks` yeni kolonlar + yeni kurulum şeması → [database_helper.dart](../myNewHabit/lib/data/database/database_helper.dart)
- [x] `StreakModel` genişletmesi → [streak_model.dart](../myNewHabit/lib/data/models/streak_model.dart)
- [x] `HabitSchedule` (planlı gün DRY) → [habit_schedule.dart](../myNewHabit/lib/core/utils/habit_schedule.dart)
- [x] `StreakRepository` + habit oluştururken streak satırı → [streak_repository.dart](../myNewHabit/lib/data/repositories/streak_repository.dart), [record_repository.dart](../myNewHabit/lib/data/repositories/record_repository.dart)
- [x] `StreakService` + `StreakViewState` → [streak_service.dart](../myNewHabit/lib/data/services/streak_service.dart)
- [x] `StreakProvider`, `CompletionProvider.onMutated`, `main.dart` provider sırası → [streak_provider.dart](../myNewHabit/lib/providers/streak_provider.dart), [completion_provider.dart](../myNewHabit/lib/providers/completion_provider.dart), [main.dart](../myNewHabit/lib/main.dart)
- [x] Ana sayfa: gizli seri filtresi, yükleme/önplan resume, takvim günü değişimi → [home_screen.dart](../myNewHabit/lib/screens/home/home_screen.dart), [calendar_bar_widget.dart](../myNewHabit/lib/screens/home/widgets/calendar_bar_widget.dart)
- [x] `HabitCard` rozet, Es Geç, kurtarma, uzun basışta seri yeniden başlat → [habit_card.dart](../myNewHabit/lib/screens/home/widgets/habit_card.dart)
- [x] US-604 istatistik diyaloğu → [streak_stats_dialog.dart](../myNewHabit/lib/modals/streak_stats_dialog.dart)
- [x] Tasarım tokenları (seri renkleri) → [app_colors.dart](../myNewHabit/lib/core/theme/app_colors.dart)
- [x] Birim testleri + widget test stubları → aşağıdaki tablolar

## Yazılan Dosyalar

| Dosya | Açıklama |
|-------|----------|
| myNewHabit/lib/core/utils/habit_schedule.dart | Planlı gün listesi / sonraki planlı gün |
| myNewHabit/lib/data/repositories/streak_repository.dart | Streak CRUD + kurtarma/sert kapanış güncellemeleri |
| myNewHabit/lib/data/services/streak_service.dart | reconcile + computeView + haftalık skip türetimi |
| myNewHabit/lib/providers/streak_provider.dart | Bellek önbelleği ve reconcile tetikleri |
| myNewHabit/lib/modals/streak_stats_dialog.dart | En uzun seri diyaloğu |
| myNewHabit/test/data/repositories/streak_repository_stub.dart | Widget testleri için stub |
| myNewHabit/test/data/services/streak_service_test.dart | Seri motoru senaryo testleri |

## Yazılan / Güncellenen Testler

| Test Dosyası | Kapsanan davranış |
|---------------|-------------------|
| test/data/services/streak_service_test.dart | Ardışık tamamlama, kurtarma günü kaçırma → sert kapanış, kurtarma ile devam, Es Geç, gizleme tarihi |
| test/widget_test.dart, test/screens/navigation_test.dart | StreakProvider + paylaşılan stub ile HomeScreen yükleme |

## Tamamlanmayan / Bloker Görevler

- Yok.

## Notlar

- Haftalık Es Geç tüketimi tamamlama kayıtlarından (`skipped` + Pazartesi hafta anahtarı) türetilir; DB’deki sayaç reconcile ile senkron kalır.
- Sert kapanıştan sonra alışkanlık `series_closed_after` sonrası tarihlerde listeden çıkar; geçmiş günlerde görünür. Uzun basış menüsünde **SERİYİ YENİDEN BAŞLAT** ile `series_closed_after` temizlenir.
