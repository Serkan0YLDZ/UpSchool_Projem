# Progress.md — Geliştirme Süreci Kaydı

> Detaylı teknik görevler için → `agilePlan.md`
> Gereksinimler için → `PRD.md`

---

## v0.1 — Tamamlandı ✅

`agilePlan.md`'deki tüm **E1–E5 epic'leri** tamamlanmış ve `main` branch'e push edilmiştir.

### Tamamlanan Epic'ler

| Epic | Kapsam | Durum |
|---|---|---|
| E1 — Veri Modeli & Migrasyon | `sqflite` + migration zinciri; 5 tablo (`calendar_events`, `habits`, `todos`, `habit_day_logs`, `streak_snapshots`) | ✅ |
| E2 — Shell & Üçgen Navigasyon | `TriangleCornerNav` widget; tek/çift/uzun dokunuş davranışı; renk token'ları | ✅ |
| E3 — Ekranlar & Formlar | Takvim, alışkanlık (4 adımlı), yapılacak akışları; ikon/renk seçici | ✅ |
| E4 — Seri Motoru & Es Geç | Full Replay streak hesabı; `habit_day_logs` durum geçişleri; ISO hafta es geç sayacı | ✅ |
| E5 — Polish | Profil tema uyumu; boş durum ikonlaştırma; onboarding; native splash | ✅ |

---

### Önemli Kararlar

**Streak hesabı → Full Replay yaklaşımı**
- _Sorun:_ Karmaşık "recovery" mantığı geçersiz tarih ve tutarsız seri sayıları üretiyordu.
- _Karar:_ `anchor_date`'ten itibaren tüm `habit_day_logs` kayıtları yeniden oynatılarak streak hesaplanır. Daha yavaş ama güvenilir ve test edilebilir.

---

### ⚠️ Şu An Pasif: Es Geç (Skip) UI

- **Backend hazır:** `habit_day_logs.status = 'skipped'`, `skip_source = 'free_weekly'`, ISO hafta sayacı — tümü implement edildi ve birim testleri geçiyor.
- **UI pasif:** Skip butonu v0.1'in son polish aşamasında arayüzden kaldırıldı.
- **Sebep:** v0.1 kapsamını sade tutmak; skip akışının UX'i ayrı bir iterasyon gerektiriyor.
- **Plan:** v0.2'de `AiAssistantScreen` ile birlikte veya ayrı bir sprint'te yeniden bağlanacak.

---

## v0.2 — Başlamadı 🔜

Planlanan epic'ler için → `Plan.md` ve `agilePlan.md` (E6–E12).

Başlangıç koşulları:
- [ ] `git tag v0.1` oluşturuldu.
- [ ] Firebase projesi (`flutterfire configure`) kuruldu.
- [ ] Gemini API anahtarı Google AI Studio'dan alındı.
