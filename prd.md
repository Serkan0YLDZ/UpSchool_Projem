# track_calendar_tasks_habits — Ürün Gereksinim Dokümanı (PRD)

## 1. Özet ve vizyon

Takvim etkinlikleri, tekrarlayan alışkanlıklar ve yapılacakları tek uygulamada birleştiren, **önce tam yerel (v0.1)**, ardından **Firebase ile bulut ve geniş özellikler (v0.2)** sunan bir günlük yönetim ürünü.

### 1.1. Sürüm stratejisi

| Sürüm | Odak | Bağımlılık |
|--------|------|------------|
| **v0.1** | Tüm akışların cihazda, **internetsiz** ve **mock’suz üretim kalitesinde** çalışması; SQLite (veya eşdeğeri) ile kalıcı veri | Yok |
| **v0.2** | Firebase Auth, çok cihazlı senkron, harici takvim kaynakları, ana ekran widget’ları, rozetler, sosyal paylaşım | Firebase + platform izinleri |

### 1.2. Tasarım ve tema referansı (v0.1)

- Tema: [`track_calendar_tasks_habits/lib/core/theme/app_theme.dart`](track_calendar_tasks_habits/lib/core/theme/app_theme.dart), renkler: [`app_colors.dart`](track_calendar_tasks_habits/lib/core/theme/app_colors.dart).
- Ana sayfa bölüm renkleri (üçlü metafor ile uyumlu): `homeSectionCalendarBlue`, `homeSectionHabitsCoral`, `homeSectionTodosOrange`.
- Merkez **Ekle** FAB yüz rengi (koyu gri referans): `neoStackFace` (`#434D5E`) — yapılacaklar filtresinde **seçili** chip’ler bu tona hizalanır.

---

## 2. v0.1 — Tam yerel MVP

**Tanım:** Uygulama ilk kurulumdan itibaren giriş zorunluluğu olmadan; veri **yerelde** kalır; liste, ekleme, düzenleme, silme, seri ve es geç kuralları **çevrimdışı** test edilebilir.

---

### FR-01 — Alt navigasyon: üçgen köşe metaforu (Takvim · Alışkanlık · Yapılacaklar)

**Bağlam:** Alt barda merkezde **Ekle**; sağında tek sekme içinde üç mod arasında geçiş.

**Gereksinim:**

- Sağ sekmede **tek bir ikon alanı**; **üç mod ikonu** eşkenar üçgenin köşeleri gibi dizilir — **üçgen çizilmez**, yalnızca köşe konumlaması kullanılır:
  - **Üst köşe:** Takvim ikonu (renk: `homeSectionCalendarBlue`),
  - **Sol alt köşe:** Alışkanlık ikonu (`homeSectionHabitsCoral`),
  - **Sağ alt köşe:** Yapılacaklar ikonu (`homeSectionTodosOrange`).
- **Aktif mod ikonu:** Tam opasite + moda özgü renk + diğerlerine göre biraz daha büyük; pasif ikonlar küçük + düşük opasite.
- **Dokunma davranışı:**
  - **Tek dokunuş — odak dışındayken (Ana sayfa vb.):** Son ziyaret edilen odak bölümüne dönür (varsayılan: Takvim). Oturum süresince `static` değişkende tutulur.
  - **Tek dokunuş — zaten odak bölümündeyken:** Değişiklik yok, mevcut modda kalınır.
  - **Çift dokunuş (double tap):** Sıradaki moda geç — döngü: Takvim → Alışkanlık → Yapılacaklar → Takvim…
  - **Uzun basış:** Mod seçici (picker) açılır; kullanıcı doğrudan istediği modu seçer.
- **Semantics:** `Takvim görünümü`, `Alışkanlık görünümü`, `Yapılacaklar görünümü` ve seçili durum duyurusu.
- Dokunma hedefi minimum 48×48 dp.

**Kabul kriterleri:**

- [x] Üçgen çizilmez; yalnızca üç ikon köşe pozisyonlarında gösterilir.
- [x] Tek dokunuş; odak dışındayken son ziyaret edilen bölüme döner, odak içindeyken değişiklik yapmaz.
- [x] Çift dokunuşta döngüsel geçiş çalışır.
- [x] Uzun basışta picker açılır ve seçim sonrası ilgili moda gidilir.
- [x] Aktif mod ikonu pasiflerden belirgin biçimde büyüktür.
- [x] Tema renkleri PRD token’larıyla uyumludur.
- [x] Erişilebilirlik etiketleri VoiceOver / TalkBack ile doğrulanır.

---

### FR-02 — Profil ekranı tema uyumu

**Gereksinim:** Profil; `AppTheme` / `ColorScheme` / `AppTypography` ile kartlar, arka plan, butonlar ve ayırıcılar ana uygulama ile **görsel olarak tutarlı** (neo-brutalist / Material 3 karışımı mevcut dil korunur).

**Kabul kriterleri:**

- [ ] Profilde kullanılan yüzey renkleri `surface` ailesiyle uyumlu; metin kontrastı okunabilir.
- [ ] Navigasyon ve üst çubuk ile çakışan renk tutarsızlığı yok.

---

### FR-03 — Yeni alışkanlık: ikon ve ikon rengi

**Gereksinim:** Alışkanlık oluştururken:

- **İkon:** Önceden tanımlı bir setten seçim (ör. `IconData` code point veya `Icons.xxx` anahtarı string olarak saklanır: `icon_key`).
- **İkon rengi:** Kullanıcı seçimi (ARGB hex veya tema indeksi); alan: `icon_color_argb`.

**Kabul kriterleri:**

- [ ] Kayıtlı alışkanlık kartında seçilen ikon ve renk görünür.
- [ ] Veri modelinde ikon alanları dolu; varsayılan ikon + renk tanımlıdır.

---

### FR-04 — Veritabanı: takvim, alışkanlık, yapılacaklar ayrımı (buluta hazır)

**İlkeler:**

- **Ayrı tablolar** (veya ayrı entity koleksiyonları); geniş tek `records` tablosundan kaçınılmalı (senkron ve şema evrimi için).
- Ortak meta alanlar (her ana tabloda):  
  `id` (UUID, metin), `created_at`, `updated_at`, `deleted_at` (NULL = aktif), `local_revision` (integer, monoton artan), isteğe bağlı `device_id` (v0.2 için yer ayrılır).

#### 2.1. Tablo: `calendar_events`

| Alan | Tip | Açıklama |
|------|-----|----------|
| id | TEXT PK | UUID |
| title | TEXT | Başlık |
| description | TEXT? | Açıklama |
| starts_at | TEXT ISO8601 | Başlangıç (tarih+saat, yerel) |
| ends_at | TEXT ISO8601? | Bitiş |
| is_all_day | INTEGER 0/1 | |
| created_at, updated_at, deleted_at | TEXT / INT | |
| local_revision | INTEGER | |

#### 2.2. Tablo: `habits`

| Alan | Tip | Açıklama |
|------|-----|----------|
| id | TEXT PK | |
| title | TEXT | |
| description | TEXT? | |
| schedule_kind | TEXT | `weekly` \| `interval` |
| interval_days | INTEGER? | N günde bir; `schedule_kind=interval` iken zorunlu |
| weekly_days_mask | INTEGER? | Bit mask Pzt…Paz veya 7 bool JSON; `weekly` iken |
| anchor_date | TEXT ISO8601 date | İlk planlı gün (oluşturma veya kullanıcı seçimi) |
| target_progress | INTEGER | 0–100, tamamlanma eşiği |
| icon_key | TEXT | |
| icon_color_argb | INTEGER veya TEXT | |
| created_at, updated_at, deleted_at | | |
| local_revision | INTEGER | |

#### 2.3. Tablo: `todos`

| Alan | Tip | Açıklama |
|------|-----|----------|
| id | TEXT PK | |
| title | TEXT | |
| description | TEXT? | |
| due_date | TEXT ISO8601 date? | |
| priority | TEXT veya INT | `high` / `medium` / `low` — **UI’da öncelik için ikon kullanılmaz** (FR-07) |
| is_completed | INTEGER 0/1 | |
| completed_at | TEXT? | |
| created_at, updated_at, deleted_at | | |
| local_revision | INTEGER | |

#### 2.4. Tablo: `habit_day_logs` (planlı gün başına durum — senkron için granüler)

| Alan | Tip | Açıklama |
|------|-----|----------|
| id | TEXT PK | |
| habit_id | TEXT FK | |
| calendar_date | TEXT ISO8601 date | Yerel takvim günü |
| planned | INTEGER 0/1 | Bu gün planlı mı |
| progress | INTEGER 0–100 | |
| status | TEXT | `pending` \| `met` \| `missed` \| `skipped` \| `series_lapsed` |
| skip_source | TEXT? | v0.1: `free_weekly`; v0.2+: `ad` placeholder |
| created_at, updated_at, deleted_at | | |
| local_revision | INTEGER | |

#### 2.5. Tablo: `streak_snapshots` (isteğe bağlı özet; türetilebilir)

| habit_id | TEXT PK | |
| current_streak | INTEGER | Seçili güne göre gösterim için cache |
| longest_streak | INTEGER | |
| series_state | TEXT | `active` \| `broken` \| `closed` |
| series_closed_after | TEXT date? | Bu tarihten **sonraki** günlerde liste gizleme |
| updated_at | TEXT | |

**Kabul kriterleri:**

- [ ] CRUD işlemleri bu tablolar üzerinden yapılır; migration sürümü yönetilir.
- [ ] Soft delete ve `local_revision` senkron taslağı (v0.2) ile uyumludur.

---

### FR-05 — Planlama ve seri mantığı (N günde bir örnek; es geç haftada 1)

#### 2.5.1. Planlı günlerin üretimi

- `anchor_date` = \(D_0\) (tarih; saat yok).
- `schedule_kind = interval` ve `interval_days = N` ise planlı günler:  
  \(D_0, D_0 + N, D_0 + 2N, …\) (takvim günü olarak).

**Görünürlük (ana liste, seçili gün = \(S\)):**

- Alışkanlık, \(S\) için listelenir **yalnızca** \(S\) bir planlı günse ve:
  - \(S \ge D_0\) (anchor öncesi günlerde görünmez),
  - `series_state != closed` **veya** \(S \le\) `series_closed_after` kuralı PRD’de: seri kapandıktan sonra **ileri** günlerde gizle; geçmiş / ankor gününde geçmiş görünüm korunabilir (ürün kararı: geçmiş günlerde kart “seri bitti” durumu ile görünür).

**Örnek (kanonik kabul testi):**  
Anchor \(D_0\) = ayın 10’u, \(N = 2\). Planlı günler: 10, 12, 14, …

- 8 ve 9: anchor öncesi → **bu alışkanlık için planlı değil** (liste yok).
- 11: planlı gün değil → o gün “bugün yapılacak alışkanlık” listesinde **bu seri için slot yok** (PRD’ye uygun).
- 12: planlı → kullanıcı arayüzünde **tamamlanması beklenen** gün.

#### 2.5.2. Seri sayımı

- Seri, ardışık **planlı** günlerde hedefe (`target_progress`) ulaşma ile artar.
- 10’da tamamlandı ve 12’de tamamlandı → gösterilen seri **2** (ör. alev sayısı 2).

#### 2.5.3. Kaçırma ve serinin bitmesi

- 10’da tamamlandı, **12’de tamamlanmadı** (ve o gün henüz kapanmadıysa beklenir; 12 bittikten sonra) bir sonraki planlı gün **14**:
  - 14’e gelindiğinde, 12 planlı günü hedefe ulaşmadan kapatıldıysa → **seri biter**; UI’da “seri bitti” ve **`series_closed_after`** / `series_state = closed` güncellenir.
  - **Es geç** bu senaryoda devreye girebilir (aşağıda).

#### 2.5.4. Es geç (Skip)

- **Haftada 1** kullanım: hafta tanımı **ISO haftası, Pazartesi 00:00 — Pazar 23:59:59** (yerel saat dilimi).
- Es geç, **yalnızca planlı bir gün** için kullanılabilir; o gün `skipped` + `skip_source = free_weekly` olarak işlenir; **seri kırılmaz** (bir sonraki planlı güne köprü kurar).
- Aynı ISO haftasında ikinci es geç **pasif**; hafta değişince sıfırlanır.
- **v0.2 notu:** `skip_source` alanı ileride `ad` ile doldurularak reklam izlenmesi sonrası ek hak tanımına genişletilecek (v0.1’de sadece `free_weekly`).

**Kabul kriterleri:**

- [ ] Yukarıdaki 10 / 12 / 14 tarih senaryosu birim testi ile doğrulanır.
- [ ] Haftalık es geç sayacı doğru sıfırlanır.
- [ ] Seri bittiğinde ileri tarihlerde liste kuralları uygulanır; kullanıcıya “yeniden başlat” veya düzenleme akışı (minimal: seriyi sıfırlama) tanımlanır.

---

### FR-06 — Boş durumlar: emoji yok, ikon

**Gereksinim:** “Bu tarih için … yok” tipi metinlerde emoji kullanılmaz; `Icon` widget (Material veya uygulama ikon seti) ile görsel destek verilir.

**Kabul kriterleri:**

- [ ] Tüm boş durum bileşenleri ikon + metin kullanır.

---

### FR-07 — Önem derecesi: ikon kaldırma

**Gereksinim:** Öncelik / önem seçimi veya gösteriminde **ayrı ikonlar kullanılmaz**; renk şeridi, metin etiketi veya segment yeterlidir.

**Kabul kriterleri:**

- [ ] Öncelik satırlarında ikon yok; yalnızca renk / yazı.

---

### FR-08 — Yapılacaklar filtresi metin ve chip rengi

**Gereksinim:**

- Başlık metni tam olarak: **Yapılacakları Filtrele** (sadece “F” harfi büyük, Türkçe başlık biçimi).
- Seçili filtre chip’leri: arka plan / kontur, **merkez Ekle butonu yüzü** ile aynı koyu gri ton: `AppColors.neoStackFace` (`#434D5E`); üzerindeki metin okunaklı kontrast (ör. beyaz veya `neoStackOnFace`).

**Kabul kriterleri:**

- [ ] Metin birebir doğru.
- [ ] Seçili chip görseli FAB koyu gri ile eşleşir.

---

### FR-09 — İlk kurulum onboarding

**Gereksinim:** Uygulama **ilk indirme / ilk açılış** sonrası bir kez: takvim çubuğu, üç mod, ekleme akışı, seri ve es geç kısa anlatılır (2–4 ekran veya tek kaydırmalı sayfa + “Başla”).

**Kabul kriterleri:**

- [ ] `SharedPreferences` (veya eşdeğeri) ile “onboarding tamamlandı” bayrağı; tekrar gösterilmez (Ayarlar’dan sıfırlanabilir opsiyonel).

---

### FR-10 — Açılış deneyimi (beyaz ekran önleme)

**Gereksinim:**

- **Native splash:** Android `launch_background`, iOS `LaunchScreen` — arka plan `neoChromePlate` veya `surface` ile uyumlu; kısa süre beyaz flaş minimize.
- **İlk frame:** `MaterialApp` / `runApp` sonrası hemen tema dolgu + marka işareti veya skeleton; ağır init arka planda.

**Kabul kriterleri:**

- [ ] Soğuk başlatmada kullanıcı anlamlı bir görsel görür (düz beyaz ekran kabul edilmez).

---

## 3. v0.2 — Firebase ve genişleme

### FR-11 — Firebase Authentication

- E-posta/şifre ve istenirse Google ile giriş; oturum durumu profilde görünür.

### FR-12 — Veri senkronizasyonu

- **Yerel öncelik:** Çevrimdışı yapılan değişiklikler kuyruklanır; bağlantı gelince gönderilir.
- Bulut kaydı daha eskiyse: **yerel → buluta** aktarım (son yazan kazanır veya `local_revision` ile birleştirme politikası dokümante).
- **Çakışma:** Aynı `id` için iki taraf da güncellediyse kullanıcıya **seçim ekranı**: “Yereli tut”, “Bulutu tut”, mümkünse alan alan birleştir (ör. sadece `title` çakışması).

### FR-13 — Harici takvimler

- **Google Calendar**, **Apple Calendar** (EventKit), **Microsoft Outlook** (Microsoft Graph).
- **MVP önerisi:** Salt okunur **içe aktarma** ve yerel `calendar_events` ile eşleme; iki yönlü yazma sonraki alt sürüme bırakılabilir.
- OAuth / izin akışları platform gereksinimlerine uygun.

### FR-14 — Ana ekran widget’ları (ürün önerileri)

1. **Bugünün yapılacakları:** Tamamlanmamış ilk 5 madde; tik ile kapatma (iOS WidgetKit / Android App Widget).
2. **Seri özeti:** En yüksek aktif seri + seçilen alışkanlık ikonu.
3. **Hızlı tamamla:** Tek alışkanlık kısayolu; slider veya tek dokunuşla %100.
4. **Mini takvim:** Haftalık nokta görünümü; bugün ve planlı günler vurgulu.

### FR-15 — Rozet sistemi (ürün önerileri)

| Rozet | Tetikleyici | Örnek depolama |
|--------|-------------|----------------|
| İlk adım | İlk alışkanlık oluşturma | `badges_earned` |
| Ateş 3 | Üst üste 3 planlı gün tamamlama | |
| Ateş 7 | 7 planlı gün | |
| Su gibi | 7 gün içinde 10 yapılacak tamamlama | |
| Zamanında | 5 etkinliği bitişten önce tamamlama | |
| Haftalık plan | ISO haftasında tüm planlı alışkanlıklar | |
| Es geç ustası | Es geç kullanmadan 30 gün | (negatif ödül değil; dikkatli kopya) |
| Bulut | v0.2 ilk başarılı senkron | |

Tablo taslağı: `badges` (tanım), `user_badges` (user_id + badge_id + earned_at) — v0.2.

### FR-16 — Sosyal: arkadaşlık ve paylaşım

**Arama / ekleme:** Kullanıcı adı, e-posta veya telefon ile arama; **arkadaşlık isteği** gönderimi; **kabul / red** bildirimi (push v0.2+).

**Paylaşılan alışkanlık:** İki kullanıcı aynı şablonu paylaşır; ilerleme gizlilik seviyesine göre (sadece “tamamlandı” boolean veya yüzde).

**Paylaşılan yapılacaklar listesi:** Ortak liste koleksiyonu; üyeler madde ekler.

**Firestore taslağı (üst seviye):**

- `users/{uid}` — profil, görünen ad, `username` (benzersiz indeks), `phone_hash` / e-posta (KVKK / GDPR uyumu için minimum PII).
- `friend_requests/{id}` — from, to, status.
- `friendships/{id}` — sorted uids.
- `shared_habits/{id}` — üyeler, habit şablonu referansı, kurallar.
- `shared_todo_lists/{id}` — üyeler, `todos` alt koleksiyonu veya ayrı `shared_todos`.

**Kabul (v0.2):**

- [ ] İstek/kabul akışı uçtan uca çalışır.
- [ ] Paylaşılan içerikte yetkisiz okuma engellenir (Security Rules).

---

## 4. Kalite ve tanım (DoD özeti)

- v0.1: Kritik kullanıcı akışları çevrimdışı; seri örnek testi geçer; onboarding ve splash davranışı doğrulanır.
- v0.2: Auth + en az bir senkron senaryosu + çakışma UI demo testi; harici takvim için en az bir platformda pilot.