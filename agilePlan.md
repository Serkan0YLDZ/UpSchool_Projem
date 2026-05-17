# track_calendar_tasks_habits — Agile plan

## 1. Vizyon ve ilkeler

- **Platform:** Flutter (Dart), paket: `track_calendar_tasks_habits`.
- Çalışma biçimi: **PRD = tek doğruluk kaynağı**; sprint kabul kriterleri PRD bölüm numaralarına referans verir.
- **v0.1:** Tam yerel, SQLite (veya eşdeğeri), mock veri üretim dışı bırakılır.
- **v0.2:** Firebase Auth, senkron, harici takvim, widget, rozet, sosyal.

---

## 2. Epic özeti

| Epic | Sürüm | Süre (öneri) |
|------|--------|----------------|
| **E1 — Veri ve migrasyon** | v0.1 | 1 sprint |
| **E2 — Shell ve üçgen navigasyon** | v0.1 | 1 sprint |
| **E3 — Takvim / Alışkanlık / Todo ekranları** | v0.1 | 1–2 sprint |
| **E4 — Seri motoru ve es geç** | v0.1 | 1 sprint |
| **E5 — Polish: profil, filtre, boşluklar, splash, onboarding** | v0.1 | 1 sprint |
| **E6 — Firebase Auth** | v0.2 | 1 sprint |
| **E7 — Bulut senkron ve çakışma** | v0.2 | 1–2 sprint |
| **E8 — Harici takvim** | v0.2 | 2+ sprint |
| **E9 — Ana ekran widget’ları** | v0.2 | 1 sprint |
| **E10 — Rozetler** | v0.2 | 1 sprint |
| **E11 — Sosyal ve paylaşım** | v0.2 | 2+ sprint |

---

## 3. Epic E1 — Veri modeli ve migrasyon (v0.1 · Sprint S1)

**Hedef:** PRD §FR-04 tablolarının oluşturulması, `sqflite` (veya seçilen yerel DB) + migration zinciri.

### Kullanıcı hikayeleri

| ID | Hikaye | PRD |
|----|--------|-----|
| US-1.1 | Geliştirici olarak, takvim etkinlikleri, alışkanlıklar ve yapılacaklar için ayrı tablolarla şema oluşturabilmeliyim. | FR-04 |
| US-1.2 | Geliştirici olarak, `habit_day_logs` ile planlı gün başına durum tutabilmeliyim. | FR-04, FR-05 |

### Teknik görevler

- [x] `sqflite` + `path` bağımlılıkları; `DatabaseHelper` (veya Drift) ve sürüm `onUpgrade`.
- [x] Tablolar: `calendar_events`, `habits`, `todos`, `habit_day_logs`, `streak_snapshots` (veya türetim stratejisi dokümante).
- [x] Repository katmanı: CRUD + soft delete + `local_revision`.
- [x] Mevcut mock akışından veri kaynağına geçiş planı (feature flag veya tek seferlik import).

### Definition of Done

- [x] Temiz kurulumda migration hatasız.
- [x] En az bir birim testi: habit insert + günlük log satırı.

---

## 4. Epic E2 — Shell ve üçgen sekme (v0.1 · Sprint S2)

**Hedef:** PRD §FR-01: alt barda Ekle + üçgen köşe navigasyonu.

### Kullanıcı hikayeleri

| ID | Hikaye | PRD |
|----|--------|-----|
| US-2.1 | Kullanıcı olarak, alt barda üç mod ikonunun üçgenin köşeleri gibi dizildiğini görmeliyim (üçgen çizilmez). | FR-01 |
| US-2.2 | Kullanıcı olarak, çift dokunuşla Takvim → Alışkanlık → Yapılacaklar arasında döngüsel geçiş yapabilmeliyim. | FR-01 |
| US-2.3 | Kullanıcı olarak, uzun basışla mod seçici (picker) açabilmeliyim. | FR-01 |
| US-2.4 | Kullanıcı olarak, ekran okuyucuda her mod için anlamlı etiket duyabilmeliyim. | FR-01 |

### Teknik görevler

- [x] `_TriangleCornerNav` widget’ı: `Stack` + `Positioned` ile 3 ikon üçgen köşe pozisyonlarında — **üçgen çizilmez**.
- [x] `_CornerIcon`: aktif ikon büyük + tam renk; pasif ikon küçük + düşük opasite; `AnimatedOpacity` geçişi.
- [x] `GestureDetector.onDoubleTap` → `_nextFocusRoute()` döngüsel geçiş (Takvim→Alışkanlık→Yapılacaklar→Takvim).
- [x] `GestureDetector.onLongPress` → `FocusModePickerSheet` (mevcut picker korunur).
- [x] **Tek dokunuş bellek davranışı:** `MainShell`'de `static String _lastFocusRoute` tutulur; odak bölümündeyken her `build()`'de güncellenir. Tek tap → odak dışındaysa `_lastFocusRoute`'a gider, odak içindeyken hiçbir şey yapmaz.
- [x] `Semantics` etiketleri: aktif mod adı + “seçili” duyurusu.
- [x] Renk token’ları: `homeSectionCalendarBlue`, `homeSectionHabitsCoral`, `homeSectionTodosOrange`.

### DoD

- [x] Üçgen çizilmediği, yalnızca köşe konumlaması kullanıldığı doğrulandı.
- [x] Tek dokunuş: odak dışındayken `_lastFocusRoute`’a gidildiği, odak içindeyken değişiklik olmadığı test edildi.
- [x] Çift dokunuş döngüsü: Takvim→Alışkanlık→Yapılacaklar→Takvim manuel test edildi.
- [x] Uzun basışta picker açılıyor; seçim sonrası doğru ekrana gidiliyor.
- [x] PRD renkleri ve köşe eşlemesi doğrulandı.
- [x] Küçük ekranda (ör. 375 genişlik) taşma yok.

---

## 5. Epic E3 — Üç mod ekranı ve formlar (v0.1 · Sprint S3)

**Hedef:** Liste + ekleme/düzenleme; alışkanlıkta ikon + renk (FR-03).

### Kullanıcı hikayeleri

| ID | Hikaye | PRD |
|----|--------|-----|
| US-3.1 | Kullanıcı olarak, takvim etkinliği ekleyip seçili güne göre listeleyebilmeliyim. | FR-04 |
| US-3.2 | Kullanıcı olarak, alışkanlık eklerken ikon ve ikon rengi seçebilmeliyim. | FR-03 |
| US-3.3 | Kullanıcı olarak, haftalık veya N günde bir tekrar tanımlayabilmeliyim. | FR-04, FR-05 |
| US-3.4 | Kullanıcı olarak, yapılacak ekleyip tamamlayabilmeliyim. | FR-04 |

### Teknik görevler

- [x] `Provider` (veya mevcut state) ile repository bağlantısı.
- [x] İkon seçici UI + `icon_key`, `icon_color_argb` persistans.
- [x] Takvim çubuğu ve güne göre filtre.

### DoD

- [x] Üç mod uçtan uca veri okur/yazar.

---

## 6. Epic E4 — Seri ve es geç (v0.1 · Sprint S4)

**Hedef:** PRD §FR-05 kanonik örnek (10 / 12 / 14) ve haftada 1 es geç.

### Kullanıcı hikayeleri

| ID | Hikaye | PRD |
|----|--------|-----|
| US-4.1 | Kullanıcı olarak, planlı günlerde hedefe ulaştığımda seri sayımının arttığını görmeliyim. | FR-05 |
| US-4.2 | Kullanıcı olarak, haftada bir kez es geç ile seriyi koruyabilmeliyim. | FR-05 |
| US-4.3 | Kullanıcı olarak, seri bittiğinde bunu arayüzde anlayabilmeliyim. | FR-05 |

### Teknik görevler

- [x] Planlı gün üretici: `anchor_date` + `interval_days` / haftalık maske.
- [x] `StreakService` (veya domain servisi): `met` / `missed` / `skipped` / `series_lapsed` geçişleri.
- [x] ISO haftası bazlı `skip_used` sayacı (Pazartesi başlangıç).
- [x] **Birim testleri:** PRD’deki 10-12-14 senaryosu + es geç sınırı.

### DoD

- [x] Tüm birim testleri yeşil.
- [x] `skip_source` alanı yazılıyor (`free_weekly`).

---

## 7. Epic E5 — Polish (v0.1 · Sprint S5)

**Hedef:** FR-02, FR-06, FR-07, FR-08, FR-09, FR-10.

### Kullanıcı hikayeleri

| ID | Hikaye | PRD |
|----|--------|-----|
| US-5.1 | Kullanıcı olarak, profil ekranının geri kalan uygulama ile uyumlu görünmesini beklerim. | FR-02 |
| US-5.2 | Kullanıcı olarak, boş listelerde emoji yerine ikon görmeliyim. | FR-06 |
| US-5.3 | Kullanıcı olarak, önem seçiminde gereksiz ikon görmemeliyim. | FR-07 |
| US-5.4 | Kullanıcı olarak, “Yapılacakları Filtrele” başlığını ve seçili chip’lerin koyu gri olduğunu görmeliyim. | FR-08 |
| US-5.5 | Kullanıcı olarak, ilk açılışta kısa rehber görmeliyim. | FR-09 |
| US-5.6 | Kullanıcı olarak, açılışta beyaz flaş yerine markalı/skeleton görünüm görmeliyim. | FR-10 |

### Teknik görevler

- [x] Profil widget’ları tema token’larına bağlama.
- [x] `EmptyStateWidget` ikonlaştırma; öncelik satırlarından ikon kaldırma.
- [x] `todo_filter_button` metin + chip `neoStackFace`.
- [x] Onboarding sayfası + `SharedPreferences` anahtarı.
- [x] Native splash + ilk frame tema.

### DoD (v0.1 çıkış)

- [x] PRD v0.1 FR maddeleri için manuel test checklist tamamlandı.
- [x] `flutter analyze` kritik uyarı yok (takım eşiği).

---

## 8. Epic E6 — Firebase Auth (v0.2 · Sprint S6)

| ID | Hikaye | PRD |
|----|--------|-----|
| US-6.1 | Kullanıcı olarak, Firebase ile oturum açıp kapatabilmeliyim. | FR-11 |

### Teknik görevler

- [ ] `firebase_core`, `firebase_auth`; `flutterfire configure`.
- [ ] Profil ekranında oturum durumu.

### DoD

- [ ] En az bir sağlayıcı (e-posta veya Google) uçtan uca.

---

## 9. Epic E7 — Senkron ve çakışma (v0.2 · Sprint S7)

| ID | Hikaye | PRD |
|----|--------|-----|
| US-7.1 | Kullanıcı olarak, çevrimdışı yaptığım değişikliklerin bağlantı gelince buluta gitmesini beklerim. | FR-12 |
| US-7.2 | Kullanıcı olarak, çakışmada yerel mi bulut mu seçeceğimi sorulduğunda anlayabilmeliyim. | FR-12 |

### Teknik görevler

- [ ] Firestore şema taslağı (koleksiyon başına `local_revision` veya vektör saat).
- [ ] Çakışma çözüm bottom sheet’i.

### DoD

- [ ] İki cihaz senaryosu manuel test dokümantasyonu.

---

## 10. Epic E8 — Harici takvim (v0.2 · Sprint S8+)

| ID | Hikaye | PRD |
|----|--------|-----|
| US-8.1 | Kullanıcı olarak, Google/Apple/Outlook’tan etkinlik içe aktarabilmeliyim (pilot en az bir kaynak). | FR-13 |

### Teknik görevler

- [ ] OAuth istemcileri; token güvenli saklama.
- [ ] `calendar_events` ile harici `external_id` eşlemesi.

---

## 11. Epic E9 — Widget’lar (v0.2 · Sprint S9)

**PRD:** FR-14 önerilerinden en az 1 widget MVP.

### DoD

- [ ] iOS veya Android’de en az bir widget türü mağaza öncesi test edilir.

---

## 12. Epic E10 — Rozetler (v0.2 · Sprint S10)

**PRD:** FR-15.

### DoD

- [ ] `badges` / `user_badges` yazımı ve ilk 3 rozet tetiklenir.

---

## 13. Epic E11 — Sosyal (v0.2 · Sprint S11+)

**PRD:** FR-16.

### DoD

- [ ] Arkadaşlık isteği + kabul.
- [ ] Paylaşılan liste veya paylaşılan alışkanlık pilotu.
- [ ] Security Rules gözden geçirmesi.

---

## 14. Riskler ve bağımlılıklar

- **Harici takvim:** Apple EventKit kapalı ekosistem; Graph ve Google API kota/limitleri.
- **Sosyal:** PII ve KVKK; telefon/e-posta araması için indeks ve hash stratejisi zorunlu.
- **Widget:** Arka plan güncelleme sıklığı OS kısıtları.