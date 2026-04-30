# myNewHabit — Ürün Gereksinim Dokümanı (PRD)
**Son Güncelleme:** Sprint 3 Sonrası Revizyon

> Bu PRD iki ana bölümden oluşur:
> - **V1 — MVP (Local):** Flutter uygulaması, local SQLite, sunucu veya auth gerektirmez.
> - **V2 — Production:** Firebase Auth, Firestore, takvim senkronizasyonu, sosyal özellikler.

---

## Ürün Vizyonu

myNewHabit; takvim yönetimi, yapılacaklar listesi ve alışkanlık takibini tek çatı altında birleştiren, sadeliği ve estetiği ön planda tutan bir günlük yönetim aracıdır. Kullanıcılar; günlük planlarını organize eder, tekrar eden alışkanlıklarını takip eder ve yapılacaklar listelerini yönetir.

> **⛔ Kapsam Dışı (Tüm Versiyonlar):** "Kötü alışkanlık / bırakma takibi" özelliği projeden tamamen çıkarılmıştır.

---

---

# 🟦 V1 — MVP (Local Çalışan Uygulama)

**Hedef:** Sunucu, auth veya internet bağlantısı gerektirmeksizin cihaz üzerinde tam işlevsel çalışan uygulama.

---

## 1. Uygulama Genel Yapısı

### 1.1. Alt Navigasyon

Uygulama üç ana sekmeye sahiptir:

| Tab | İkon | Açıklama |
|-----|------|----------|
| 🏠 Ana Sayfa | home | Takvim, Alışkanlıklar ve Yapılacaklar |
| ➕ Ekle | add_circle | Yeni kayıt ekleme bottom sheet |
| 👤 Profil | person | Özet istatistikler |

---

## 2. Ana Sayfa Düzeni

Ana sayfa **dikey olarak üç bölümden** oluşur ve tek sayfa üzerinde yukarıdan aşağıya sıralanır.

---

### 2.1. Takvim Barı (En Üst)

```
◀  Paz  Pzt  Sal  ●Çar●  Per  Cum  Cmt  ▶       [📅]
```

- Yatay kaydırılabilir (`ScrollableCalendarBar`).
- Varsayılan merkez: **Bugün**.
- Kaydırma aralığı: **Bugünden 10 gün öncesi ↔ 10 gün sonrası** (toplam 21 gün görünür havuz, ekranda ~7 gün).
- Sağ köşede **Takvim Görünümü ikonu** (📅) bulunur; ilerleyen versiyonlarda tam takvim ekranına açılır.
- Seçili gün: `#0077B6` dolu daire, bugün ise ek "bugün" etiketi.
- Gün değiştiğinde aşağıdaki tüm bölümler seçili güne göre yeniden render edilir.

---

### 2.2. Takvim Etkinlikleri Bölümü

Seçili günün **saatli planları** (Takvime Ekle tipi kayıtlar) kronolojik sıraya göre listelenir.

**Kart anatomisi:**
- Sol: saat etiketi (Örn: `14:30`) (Eğer varsa bitiş saati (veya başka günse bitişi o günün tarihi görünür) de gösterilir)
- Orta: başlık + opsiyonel açıklama
- Sağ: tamamlama checkbox'ı
- Sol bordür rengi: tamamlandıysa yeşil, tamamlanmadıysa öncelik rengi

**Boş durum:** "Bu gün için planlanmış etkinlik yok."

---

### 2.3. Alışkanlık Takibi Bölümü

Seçili güne göre kullanıcının **o güne atanmış tekrar eden alışkanlıkları** listelenir.

**İlerleme Mekanizması:**
- Her alışkanlığın 0–100 arası bir tamamlanma yüzdesi vardır.
- Kullanıcı; kart üzerindeki yüzde düğmesine veya progress slider'a basarak değeri günceller.
- Örnek: "Günde 2 litre su iç" → `%60`
- Tamamlama eşiği: `%100` işaretlendiğinde kart "tamamlandı" görünümüne geçer.

**Seri (Streak) Sistemi:**
- Bir alışkanlık `%100` tamamlandığında o günün serisi devam eder.
- Kart üzerinde 🔥 + gün sayısı rozeti gösterilir (Örn: `🔥 14`).
- **Es Geçme Hakkı:** Her alışkanlık için haftada 1 kez "Bugün Es Geç" seçeneği; seri korunur.

**Filtreleme:** Bölüm başlığının sağında mini filtre: `Tümü | Tamamlanan | Bekleyen`

**Boş durum:** "Bu güne atanmış alışkanlık yok."

---

### 2.4. Yapılacaklar Listesi Bölümü

Seçili güne ait görevler **checkbox listesi** olarak gösterilir.

**Kart anatomisi:**
- Sol: öncelik renk şeridi (Kırmızı=Yüksek, Turuncu=Orta, Gri=Düşük)
- Checkbox: tamamlandı mı?
- Başlık + opsiyonel eğer bitiş tarihi varsa bitiş tarihi etiketi
- Sağ: bitiş tarihi varsa küçük tarih badge'i

**Filtreleme:**
"Yapılacaklar Listesi" başlığının **sağında** filtre menüsü bulunur. İki boyutlu filtreleme:

| Boyut | Seçenekler |
|-------|-----------|
| Sıralama | En Önemli · En Yakın Bitiş Tarihi |
| Zaman Aralığı | Bugün · Bu Hafta · Bu Ay · Tümü |

> Filtre uygulandığında sadece bitiş tarihi olan kayıtlar ilgili zaman filtresinde görünür. Bitiş tarihi olmayan kayıtlar "Tümü" filtresinde her zaman görünür.

**Boş durum:** "Bu gün için yapılacak yok."

---

### 2.5. Uzun Basma (Long Press) ile Düzenleme / Silme

**En kritik etkileşim kuralı:** Kullanıcı, üç bölümdeki herhangi bir karta **uzun basarsa** context menü açılır.

- **Düzenle:** İlgili kayıt tipinin dolu halde edit bottom sheet'i açılır.
- **Sil:** Tam ekran onay modalı açılır (diğer UI elementlerinin önünde).
  - Modal: "Bu kaydı silmek istediğine emin misin?" + **İptal** / **Sil** butonları.
  - Silme işlemi ilgili completion ve streak kayıtlarını da temizler.

---

## 3. Kayıt Tipleri

### 3.1. Takvime Ekle (Görev / Etkinlik)

| Alan | Detay |
|------|-------|
| Başlık | Zorunlu |
| Tarih & Saat | Zorunlu (tarih seçici + saat seçici) |
| Bitiş Saati | Opsiyonel |
| Açıklama | Opsiyonel |

→ Ana sayfada **Takvim Etkinlikleri** bölümünde görünür.

---

### 3.2. Yeni Alışkanlık (Tekrar Eden Görev)

| Alan | Detay |
|------|-------|
| Başlık | Zorunlu |
| Önem Derecesi | Yüksek · Orta · Düşük |
| Tekrar Günleri | Haftanın belirli günleri VEYA her X günde bir |
| İlerleme Hedefi | 0–100 arası, kullanıcı tanımlı (Örn: "80% yeterli") — opsiyonel |
| İkon / Emoji | Opsiyonel |

→ Ana sayfada **Alışkanlık Takibi** bölümünde görünür.

---

### 3.3. Yapılacak (To-Do)

| Alan | Detay |
|------|-------|
| Başlık | Zorunlu |
| Önem Derecesi | Yüksek · Orta · Düşük |
| Bitiş Tarihi | Opsiyonel (tarihe basılırsa tarih seçici açılır) |
| Açıklama | Opsiyonel |
| Tekrar | Yok (tek seferlik checkbox) |

→ Ana sayfada **Yapılacaklar Listesi** bölümünde görünür.

---

## 4. Kayıt Ekleme Akışı (Bottom Sheet)

```
Adım 1: "Ne Eklemek İstersin?"
 ┌──────────────────┐
 │ 📅 Takvime Ekle  │
 │ 🔁 Yeni Alışkanlık│
 │ ☑️ Yapılacak Ekle │
 └──────────────────┘

Adım 2: İsimlendirme + Hızlı Öneri Chip'leri

Adım 3: Tip'e özel detay ekranı (saat / gün seçici / öncelik)
```

- Ekranda gereksiz alan gösterilmez: "Saat Ekle" seçilirse saat seçici açılır, seçilmezse görünmez.
- Hızlı öneri chip'leri: "💧 Su İç", "📖 Kitap Oku", "🏃 Spor Yap" vb.

---

## 5. İlk Açılış (Onboarding)

- Kullanıcı uygulamayı ilk açtığında boş ekran **görmez**.
- Popüler alışkanlık önerileri sunulur (tek tıkla ekle).
- "Boş Başla" seçeneği de mevcut.
- `SharedPreferences` ile bir kez gösterilir.

---

## 6. Profil Ekranı (Minimal MVP)

- Toplam aktif alışkanlık sayısı
- Bugünkü tamamlanma yüzdesi (`CircularProgressIndicator`)
- En uzun seri rekoru
- Toplam tamamlanan yapılacak sayısı
- Bildirim yönetme ayarları
---

## 7. Bildirimler

| Bildirim | Zamanlama |
|----------|-----------|
| Saatli etkinlik hatırlatıcı | Etkinlikten X dakika önce |
| Akşam motivasyon bildirimi | Her gün 21:00 — eksik alışkanlık sayısı ile dinamik mesaj |

---

## 8. V1 Veritabanı Şeması (SQLite — sqflite)

```sql
-- Ana kayıt tablosu (3 tip birlikte)
CREATE TABLE records (
  id              TEXT PRIMARY KEY,
  type            TEXT NOT NULL,       -- 'event' | 'habit' | 'todo'
  title           TEXT NOT NULL,
  description     TEXT,
  icon            TEXT,
  priority        TEXT,                -- 'low' | 'medium' | 'high'
  -- Alışkanlık alanları
  repeat_days     TEXT,                -- JSON: '["MON","WED","FRI"]'
  interval_days   INTEGER,             -- Alternatif: her X günde bir
  target_progress INTEGER DEFAULT 100, -- Tamamlanmış sayılan % eşiği
  -- Takvim etkinliği alanları
  scheduled_date  TEXT,                -- 'yyyy-MM-dd'
  scheduled_time  TEXT,                -- 'HH:mm'
  end_time        TEXT,                -- 'HH:mm' (opsiyonel)
  -- To-do alanları
  due_date        TEXT,                -- 'yyyy-MM-dd' (opsiyonel)
  -- Ortak alanlar
  created_at      TEXT NOT NULL,
  is_active       INTEGER DEFAULT 1,
  sort_order      INTEGER DEFAULT 0    -- Gelecekte sürükle-bırak için
);

-- Günlük tamamlama / ilerleme kayıtları
CREATE TABLE completions (
  id          TEXT PRIMARY KEY,
  record_id   TEXT NOT NULL,
  date        TEXT NOT NULL,           -- 'yyyy-MM-dd'
  status      TEXT NOT NULL,           -- 'done' | 'skipped' | 'partial'
  progress    INTEGER DEFAULT 0,       -- 0-100 (alışkanlıklar için)
  note        TEXT,                    -- Opsiyonel kullanıcı notu
  FOREIGN KEY (record_id) REFERENCES records(id) ON DELETE CASCADE
);

-- Seri (streak) bilgileri — sadece alışkanlıklar için
CREATE TABLE streaks (
  record_id              TEXT PRIMARY KEY,
  current_streak         INTEGER DEFAULT 0,
  longest_streak         INTEGER DEFAULT 0,
  last_done_date         TEXT,
  skip_used_this_week    INTEGER DEFAULT 0,
  skip_week_start        TEXT,         -- Hangi haftanın skip'i kullanıldı
  FOREIGN KEY (record_id) REFERENCES records(id) ON DELETE CASCADE
);
```

> **Not:** `ON DELETE CASCADE` sayesinde bir kayıt silindiğinde ilgili completion ve streak kayıtları otomatik temizlenir.

---

## 9. V1 Definition of Done

| Kriter | Durum |
|--------|-------|
| `flutter run` ile local'de çalışır (iOS/Android) | ⬜ |
| 3 kayıt tipi eklenebilir / düzenlenebilir / silinebilir | ⬜ |
| Kaydırılabilir takvim barı (±10 gün) çalışır | ⬜ |
| Takvim etkinlikleri bölümü seçili güne göre gösterilir | ⬜ |
| Alışkanlık takibi 0-100% progress ile çalışır | ⬜ |
| Yapılacaklar listesi checkbox + filtreleme çalışır | ⬜ |
| Uzun basma ile düzenleme / silme akışı çalışır | ⬜ |
| Streak motoru doğru hesaplar | ⬜ |
| Es geçme hakkı sistemi çalışır | ⬜ |
| İlk açılış onboarding ekranı görünür | ⬜ |
| Saatli etkinlik bildirimi tetiklenir | ⬜ |
| Veriler uygulama restart'ta korunur (sqflite) | ⬜ |
| iPhone SE (375px) boyutunda kırılma yok | ⬜ |

---

---

# 🟩 V2 — Production (Backend + Sunucu)

> V1 MVP tamamlanıp onaylandıktan sonra başlanacaktır. Bu bölüm mimari yönlendirme ve önceliklendirme amaçlıdır.

---

## 1. Kimlik Doğrulama — Firebase Authentication

**Firebase Authentication** kullanılacaktır.

**V2'de desteklenecek giriş yöntemleri:**
- Google ile Giriş
- Apple ile Giriş
- E-posta / Şifre
- (Opsiyonel) Telefon numarası ile OTP

**Mimari not:** Flutter tarafında `firebase_auth` paketi kullanılır. Kullanıcı giriş yapmamışsa veriler local SQLite'ta tutulmaya devam eder; giriş yapıldığında Firestore'a senkronize edilir.

---

## 2. Bulut Veritabanı — Firebase Firestore

Google'ın önerilen bulut veritabanı çözümü **Cloud Firestore**'dur (gerçek zamanlı senkronizasyon, offline destek, ölçeklenebilir). Profil bölümünde verilerin senkronize edilip edilmediğin görüntülenebilir.

### Koleksiyon Yapısı

```
users/
  {userId}/
    profile/          → displayName, email, createdAt
    records/          → kayıtlar (event | habit | todo)
      {recordId}/
        completions/  → günlük tamamlama kayıtları
        streak/       → streak belgesi
    settings/         → bildirim tercihleri, tema, dil

groups/               → Sosyal özellik (V2.3+)
  {groupId}/
    members/
    shared_records/
    activity_feed/
```

**Neden Firestore?**
- Offline-first çalışır (cihaz çevrimdışıyken yerel önbellekte günceller, çevrimiçi olunca senkronize eder).
- Gerçek zamanlı stream desteği (arkadaş aktiviteleri anlık görünür).
- `firebase_firestore` Flutter paketi ile kolay entegrasyon.

---

## 3. Takvim Senkronizasyonu

| Sağlayıcı | API | Durum |
|-----------|-----|-------|
| Google Calendar | Google Calendar API v3 | V2.1 |
| Apple Calendar | EventKit (iOS native) | V2.1 |
| Microsoft Outlook | Microsoft Graph API | V2.2 |

**Senkronizasyon mantığı:** Çift yönlü (myNewHabit → Takvim ve Takvim → myNewHabit). Çakışma yönetimi: "Son güncellenen kazanır" politikası (V2.1 için).

---

## 4. Sosyal Özellikler (Arkadaşlarla Paylaşım)

> Özellikle **to-do listesi** ve **alışkanlık takibi** arkadaşlarla paylaşılabilir olacak şekilde tasarlanacaktır.

### 4.1. Arkadaş Sistemi
- Kullanıcı adı veya e-posta veya telefon numarası ile arkadaş ekleme
- Arkadaşlık isteği / kabul akışı

### 4.2. Paylaşılan Alışkanlıklar
- Bir alışkanlığı "Ortak Hedef" olarak işaretle
- Gruba davet et (Örn: "30 Gün Spor" meydan okuması)
- Grup içi ilerleme tablosu (kim ne kadar tamamladı)

### 4.3. Paylaşılan Yapılacaklar Listesi
- Bir listeyi arkadaşla paylaş
- Ortak liste: her iki kullanıcı da görev ekleyebilir / tamamlayabilir
- Gerçek zamanlı güncelleme (Firestore stream)

---

## 5. V2 Ek Özellikler

| Özellik | Versiyon | Açıklama |
|---------|----------|----------|
| Ana Ekran Widget'ları | V2.1 | iOS/Android widget: alışkanlıkları uygulamayı açmadan tamamla |
| Kategorizasyon & Etiketler | V2.1 | Renk kodlu etiketler (Sağlık, İş, Kişisel Gelişim) |
| Sürükle & Bırak Sıralama | V2.1 | Aynı öncelik grubunda manuel sıralama |
| Gelişmiş Analitik | V2.2 | Aylık/yıllık grafikler, `fl_chart` |
| Gamification | V2.3 | Rozetler, seviye sistemi, haftalık challenge |
| Dark Mode | V2.1 | Sistem temasına göre otomatik geçiş |

---