# myNewHabit MVP için Agile Planı

> **Platform:** Flutter (Dart) · **Hedef:** Local'de çalışan, tam işlevsel MVP  
> **Renk Paleti:** Primary `#0077B6` · Secondary `#90E0EF` · Tertiary `#00B4D8` · Neutral `#F8FBFF`  
> **Font:** Plus Jakarta Sans (Google Fonts)

---

## 📋 Genel Bakış

| # | Sprint | Süre | Odak |
|---|--------|------|------|
| 1 | Proje Kurulumu & Tasarım Sistemi | 1 hafta | Flutter altyapısı, navigasyon, design tokens |
| 2 | Veri Katmanı & Kayıt Tipleri | 1 hafta | SQLite (sqflite), 3 kayıt tipi CRUD |
| 3 | Ana Sayfa & Takvim | 1 hafta | 7 günlük bar, liste hiyerarşisi |
| 4 | Seri Sistemi & Akıllı Ekleme | 1 hafta | Streak, es geçme, onboarding |
| 5 | Bildirimler & MVP Tamamlama | 1 hafta | Push bildirimler, QA, polish |

**Toplam MVP Süresi: ~5 Hafta**

---

## 🚀 Sprint 1 — Proje Kurulumu & Tasarım Sistemi

**Hedef:** Sıfırdan çalışan bir Flutter projesi; navigasyon, design tokens ve temel widget'lar hazır.

### Kullanıcı Hikayeleri

| ID | Hikaye | Öncelik |
|----|--------|---------|
| US-101 | Geliştirici olarak projeyi klonladığımda `flutter run` komutuyla çalıştırabilmeliyim. | 🔴 Kritik |
| US-102 | Tasarımcı olarak renk paleti ve tipografinin kodda merkezi `AppTheme` olarak tanımlı olmasını istiyorum. | 🔴 Kritik |
| US-103 | Kullanıcı olarak alt navigasyon barından Ana Sayfa, Ekle ve Profil ekranlarına geçiş yapabilmeliyim. | 🔴 Kritik |

### Teknik Görevler

- [x] `flutter create myNewHabit` ile proje oluştur
- [x] `pubspec.yaml` bağımlılıkları ekle:
  ```yaml
  dependencies:
    sqflite:
    path:
    flutter_local_notifications: 
    provider:          # State management
    go_router:       # Navigasyon
    google_fonts:    # Plus Jakarta Sans
    intl:            # Tarih formatlama
    shared_preferences: 
    uuid:
  ```
- [x] `lib/core/theme/app_colors.dart` → Renk sabitlerini tanımla
- [x] `lib/core/theme/app_typography.dart` → Plus Jakarta Sans + text style'ları
- [x] `lib/core/theme/app_spacing.dart` → 4px grid spacing sabitleri
- [x] `lib/core/theme/app_theme.dart` → `ThemeData` merkezi tanım
- [x] `lib/core/widgets/` → Temel widget'lar: `AppButton`, `AppCard`, `AppBadge` ✅ · `AppIconButton` ⚠️ eksik
- [x] `go_router` ile navigasyon kur: **Ana Sayfa** (🏠) · **Ekle** (+) · **Profil** (👤)
- [x] `BottomNavigationBar` veya `NavigationBar` (Material 3) kurulumu — pill-shaped custom nav bar
- [ ] Splash screen & app icon placeholder

### Kabul Kriterleri

- [x] `flutter run` komutu hatasız çalışır (iOS Simulator veya Android Emulator)
- [x] 3 tab görünür ve tıklanabilir
- [x] Primary renk `#0077B6` tüm butonlarda doğru görünür
- [x] Plus Jakarta Sans yüklü ve metinlerde aktif

---

## 🗄️ Sprint 2 — Veri Katmanı & Kayıt Tipleri

**Hedef:** `sqflite` ile local veritabanı; Yeni Alışkanlık, Takvime Ekle (Görev/Plan) ve Kötü Alışkanlık tiplerinin tam CRUD'u.

### Kullanıcı Hikayeleri

| ID | Hikaye | Öncelik |
|----|--------|---------|
| US-201 | Kullanıcı olarak "Ne Eklemek İstersin?" bottom sheet'inden üç tip arasında seçim yapabilmeliyim. | 🔴 Kritik |
| US-202 | Yeni Alışkanlık eklerken isim girebilmeli, tekrar sıklığı (Gün seçimi veya X günde bir) ve önem derecesi belirleyebilmeliyim. | 🔴 Kritik |
| US-203 | Takvime Ekle modülünde başlangıç tarihi/saati ve opsiyonel bitiş tarihi/saati seçebilmeliyim. | 🔴 Kritik |
| US-204 | Kötü Alışkanlık eklerken sadece isim girerek kayıt oluşturabilmeliyim; sistem otomatik sayaç başlatır. | 🔴 Kritik |
| US-205 | Kayıtlarımı düzenleyip silebilmeliyim. | 🟠 Yüksek |

### Veri Modeli

```sql
-- Tüm kayıt tipleri tek tabloda (type ayrımı ile)
CREATE TABLE records (
  id            TEXT PRIMARY KEY,
  type          TEXT NOT NULL,   -- 'habit' | 'task' | 'quit'
  title         TEXT NOT NULL,
  icon          TEXT,
  priority      TEXT,            -- 'low' | 'medium' | 'high'
  repeat_days   TEXT,            -- JSON: '["MON","TUE"]'
  interval_days INTEGER,         -- Örn: 3 (3 günde bir)
  scheduled_time TEXT,           -- 'HH:mm' formatı
  end_date      TEXT,            -- ISO date
  created_at    TEXT NOT NULL,
  is_active     INTEGER DEFAULT 1
);

-- Günlük tamamlama kayıtları
CREATE TABLE completions (
  id          TEXT PRIMARY KEY,
  record_id   TEXT NOT NULL,
  date        TEXT NOT NULL,    -- 'yyyy-MM-dd'
  status      TEXT NOT NULL,    -- 'done' | 'skipped' | 'relapsed'
  FOREIGN KEY (record_id) REFERENCES records(id)
);

-- Seri (streak) bilgileri
CREATE TABLE streaks (
  record_id              TEXT PRIMARY KEY,
  current_streak         INTEGER DEFAULT 0,
  longest_streak         INTEGER DEFAULT 0,
  last_done_date         TEXT,
  skip_used_this_week    INTEGER DEFAULT 0,
  FOREIGN KEY (record_id) REFERENCES records(id)
);
```

### Dart Model Sınıfları

```dart
// lib/data/models/record_model.dart
enum RecordType { habit, task, quit }
enum Priority   { low, medium, high }

class RecordModel {
  final String id;
  final RecordType type;
  final String title;
  final String? icon;
  final Priority? priority;
  final List<String> repeatDays; // ['MON','TUE',...]
  final int? intervalDays;       // 3 günde bir vb.
  final String? scheduledTime;
  final DateTime? endDate;
  final DateTime createdAt;
  final bool isActive;
}
```

### Teknik Görevler

- [ ] `lib/data/database/database_helper.dart` → `sqflite` singleton, migration sistemi
- [ ] `lib/data/repositories/record_repository.dart` → `create`, `update`, `delete`, `getAll`, `getByDate`
- [ ] `lib/data/repositories/completion_repository.dart` → `markDone`, `markSkipped`, `markRelapsed`, `getByDate`
- [ ] **Bottom Sheet: 1. Adım** — "Ne Eklemek İstersin?" → 3 tip seçimi (tasarıma uygun)
- [ ] **Bottom Sheet: 2. Adım** — "Buna ne ad verelim?" + hızlı öneri chip'leri
- [ ] **Bottom Sheet: Alışkanlık Detayları** → Gün seçici + Önem derecesi
- [ ] **Bottom Sheet: Görev Zamanlaması** → `showDatePicker` + `showTimePicker` + bitiş tarihi toggle
- [ ] **Bottom Sheet: Kötü Alışkanlık** → Sadece isim + kaydet
- [ ] `Provider` ile `RecordProvider`, `CompletionProvider` state yönetimi

### Kabul Kriterleri

- [ ] Her 3 tip için kayıt eklenebilir, DB'de görünür
- [ ] Düzenleme formu mevcut verilerle açılır
- [ ] Silme işlemi ilgili completion kayıtlarını da temizler
- [ ] Uygulama yeniden başlatıldığında veriler kaybolmaz (sqflite persist)

---

## 🏠 Sprint 3 — Ana Sayfa & Takvim

**Hedef:** 7 günlük takvim barı, liste hiyerarşisi (Saatli → Rutin → Bırakılanlar) ve tamamlama eylemleri.

### Kullanıcı Hikayeleri

| ID | Hikaye | Öncelik |
|----|--------|---------|
| US-301 | Uygulama açıldığında "Bugün" seçili 7 günlük takvim barını görürüm. | 🔴 Kritik |
| US-302 | Farklı bir güne tıkladığımda o günün kayıtları listelenir. | 🔴 Kritik |
| US-303 | Saatli planlarım kronolojik sırada üst bölümde görünür. | 🔴 Kritik |
| US-304 | Rutin alışkanlıklarım önem sırasına göre orta bölümde listelenir. | 🔴 Kritik |
| US-305 | "Bırakılanlar" bölümüm alt kısımda; "Bugün de yapılmadı" onay kutularıyla görünür. | 🔴 Kritik |
| US-306 | Tamamladığım alışkanlığı işaretleyebilir, geri alabilirim. | 🔴 Kritik |
| US-307 | Kötü alışkanlık kartında "Yaptım" butonuna basarsam sayaç sıfırlanır. | 🔴 Kritik |
| US-308 | Filtreleme: "En Önemli", "En Erken", "Bu hafta/ay/bugün" seçenekleri çalışmalı. | 🟠 Yüksek |


### Teknik Görevler

- [ ] **`CalendarBarWidget`** → `ListView.builder` (horizontal) · Seçili gün `#0077B6` dairesi · `AnimatedContainer`
- [ ] **`HomeScreen`** → `Consumer<RecordProvider>` ile seçili güne göre veri çekme
- [ ] **`ScheduledSection`** → `Column` içinde saatli görevler; saat etiketi solda, ikon ortada
- [ ] **`HabitCard`** → `Checkbox` toggle · Seri rozeti · Öncelik rengi sol bordür (`Container` + `BoxDecoration`)
- [ ] **`QuitCard`** → Kaçınılan gün sayacı ("🔥 14 Gün") · "Yaptım (Sıfırla)" kırmızı `ElevatedButton`
- [ ] **`FilterChipBar`** → `SingleChildScrollView` + `FilterChip` row: En Önemli · En Erken · Bu Hafta · Bu Ay
- [ ] Filtreleme mantığını `RecordProvider` içine ekle
- [ ] Tamamlama toggle animasyonu → `AnimatedOpacity` + checkmark `Icon` fade-in
- [ ] Boş durum → `EmptyStateWidget` ("Bugün için kayıt yok, ➕ ekleyelim!")
- [ ] Tüm kayıt kartlarında (alışkanlık, görev, bırakılan) uzun basınca silme

#### UX Polish
- Silme onay modalları, alt bar ve diğer UI öğelerinin önünde, tam ekran ve dikkat çekici şekilde açılır.

### Kabul Kriterleri

- [ ] Takvim barında "Bugün" her zaman seçili başlar
- [ ] Geçmiş günlere tıklandığında o günün tamamlama durumları görünür
- [ ] Üç bölüm doğru sırayla render edilir
- [ ] Kötü alışkanlık "Yaptım" sonrası sayaç `0`'a döner
- [ ] Filtre değiştiğinde liste anlık güncellenir (`notifyListeners`)

---

## 🔥 Sprint 4 — Seri Sistemi, Es Geçme & Akıllı Ekleme (Onboarding)

**Hedef:** Streak motoru, es geçme hakkı, kötü alışkanlık gün sayacı ve ilk açılış onboarding'i.

### Kullanıcı Hikayeleri

| ID | Hikaye | Öncelik |
|----|--------|---------|
| US-401 | Bir alışkanlığı üst üste yaptığımda 🔥 serisi artar ve kart üzerinde gösterilir. | 🔴 Kritik |
| US-402 | Bir günü atlarsam serim sıfırlanır; ama "Es Geç" hakkımı kullanırsam seri devam eder. | 🔴 Kritik |
| US-403 | Her alışkanlık için haftada 1 "Bugün Es Geç" hakkım olduğunu bilirim. | 🟠 Yüksek |
| US-404 | Kötü alışkanlık için son ihlalden bu yana kaç gün geçtiği görünür; "1. Gün", "2. Gün"... | 🔴 Kritik |
| US-405 | Uygulamayı ilk açtığımda popüler alışkanlıkları tek tıkla ekleyebilirim. | 🟠 Yüksek |
| US-406 | İlk açılışta boş ekran görmem; varsayılan alışkanlık önerileri gelir. | 🟠 Yüksek |

### Teknik Görevler

**Streak Engine (`lib/data/services/streak_service.dart`)**
- [ ] `recalculateStreak(String recordId)` → Geçmiş completion'lardan streak hesapla
- [ ] `markDone()` çağrıldığında streak otomatik güncellenir
- [ ] Gece yarısı kontrolü: `flutter_local_notifications` + WorkManager benzeri yaklaşım
- [ ] `canSkip(String recordId) → bool` → Bu hafta skip hakkı kaldı mı?
- [ ] `useSkip(String recordId)` → Skip kullan, streak koru

**Kötü Alışkanlık Sayacı**
- [ ] `getDaysSinceLastRelapse(String recordId) → int` → Son "relapsed" tarihten bugüne gün farkı
- [ ] `QuitCard` widget'ına entegre

**Onboarding**
- [ ] `lib/data/defaults/default_habits.dart` → 8 popüler alışkanlık listesi (isim + emoji ikon)
- [ ] İlk açılış kontrolü → `SharedPreferences.getBool('onboarding_shown')`
- [ ] **`OnboardingScreen`** → `PageView` veya `ListView` ile öneri kartları + "Ekle" butonları + "Boş Başla"
- [ ] Seçilen öneriler `RecordRepository.create()` ile DB'ye eklenir

**UX Polish**
- [ ] Streak rozetine `GestureDetector` → `Tooltip`: "En uzun serin: X gün"
- [ ] Skip sonrası kart `ColorFiltered` ile soluklaşır

### Kabul Kriterleri

- [ ] 3 gün üst üste tamamla → streak 3 görünür
- [ ] 1 gün atla → streak 0 olur
- [ ] Skip kullan → streak korunur, bu hafta skip butonu disabled
- [ ] Kötü alışkanlık "Yaptım" → sayaç 0, ertesi gün "1. Gün"
- [ ] İlk açılışta onboarding görünür, 2. açılışta görünmez

---

## 🔔 Sprint 5 — Bildirimler, QA & MVP Tamamlama

**Hedef:** Lokal bildirimler, son polish, uçtan uca test ve MVP çıktısı.

### Kullanıcı Hikayeleri

| ID | Hikaye | Öncelik |
|----|--------|---------|
| US-501 | Saatli görevim için belirlediğim saatte lokal bildirim alırım. | 🔴 Kritik |
| US-502 | Gün sonu (ör: 21:00) eksik alışkanlıklarım için motivasyonel bir bildirim gelir. | 🟠 Yüksek |
| US-503 | Bildirim iznini ilk açılışta vermek istemiyorsam sonra verebilmeliyim. | 🟡 Orta |
| US-504 | Uygulama çökmeden tüm temel akışlarda sorunsuz çalışır. | 🔴 Kritik |

### Teknik Görevler

**Bildirimler (`lib/data/services/notification_service.dart`)**
- [ ] `flutter_local_notifications` kurulum (iOS + Android izin akışı)
- [ ] `scheduleTaskReminder(RecordModel record)` → `zonedSchedule` ile belirli saatte bildirim
- [ ] `scheduleEveningReminder()` → Her gün 21:00 eksik alışkanlık sayısıyla dinamik mesaj
- [ ] Kayıt silindiğinde → `cancelNotification(id)` ile ilgili bildirimi iptal et
- [ ] Bildirim izni reddedilirse `SnackBar` ile uygulama içi uyarı

**Profil Ekranı (Minimal MVP)**
- [ ] Toplam aktif alışkanlık sayısı
- [ ] En uzun seri rekoru
- [ ] Bugünkü tamamlanma yüzdesi → `CircularProgressIndicator` (custom renk)

**QA & Polish**
- [ ] Tüm ekranlar iPhone SE (375px) ve büyük ekranlarda `flutter run` ile test
- [ ] `ThemeData` içinde `brightness: Brightness.light` + dark mode hazırlığı
- [ ] Boş durum widget'ları her bölüm için
- [ ] Hata yönetimi: DB hataları `ScaffoldMessenger.showSnackBar` ile göster
- [ ] Loading state: `CircularProgressIndicator` veri yüklenirken
- [ ] Haptic feedback: `HapticFeedback.lightImpact()` tamamlama toggle'ında

**Dokümantasyon**
- [ ] `README.md` → Kurulum adımları, `flutter pub get && flutter run` talimatı
- [ ] `pubspec.yaml` tüm bağımlılıklar açıklamalı

### Kabul Kriterleri

- [ ] Saatli görev bildirimi doğru saatte tetiklenir (simulator'da test)
- [ ] Akşam 21:00 bildirimi `zonedSchedule` ile ayarlı
- [ ] Uygulama 375px genişlikte içerik kırılmaz
- [ ] Tüm 3 kayıt tipi: ekle → listele → tamamla → sil akışı hatasız
- [ ] `flutter run` ile fresh clone çalışır

---

## 🗂️ Klasör Yapısı (Önerilen)

```
myNewHabit/
├── lib/
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_spacing.dart
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_card.dart
│   │       ├── app_badge.dart
│   │       └── empty_state_widget.dart
│   ├── data/
│   │   ├── database/
│   │   │   └── database_helper.dart
│   │   ├── models/
│   │   │   ├── record_model.dart
│   │   │   ├── completion_model.dart
│   │   │   └── streak_model.dart
│   │   ├── repositories/
│   │   │   ├── record_repository.dart
│   │   │   └── completion_repository.dart
│   │   ├── services/
│   │   │   ├── streak_service.dart
│   │   │   └── notification_service.dart
│   │   └── defaults/
│   │       └── default_habits.dart
│   ├── providers/
│   │   ├── record_provider.dart
│   │   └── completion_provider.dart
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── calendar_bar_widget.dart
│   │   │   │   ├── habit_card.dart
│   │   │   │   ├── task_card.dart
│   │   │   │   ├── quit_card.dart
│   │   │   │   └── filter_chip_bar.dart
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   ├── modals/
│   │   ├── add_record_modal.dart       # 1. Adım — Tip seçimi
│   │   ├── naming_modal.dart           # 2. Adım — İsimlendirme
│   │   ├── habit_details_sheet.dart    # Alışkanlık detayları
│   │   ├── task_timing_sheet.dart      # Görev zamanlaması
│   │   └── quit_sheet.dart
│   └── main.dart
├── assets/
│   └── fonts/
├── pubspec.yaml
└── README.md
```

---

## 📊 MVP Definition of Done

Aşağıdaki tüm koşullar sağlandığında MVP tamamlanmış sayılır:

| Kriter | Durum |
|--------|-------|
| `flutter run` ile local'de çalışır (iOS/Android) | ⬜ |
| 3 kayıt tipi eklenebilir/düzenlenebilir/silinebilir | ⬜ |
| 7 günlük takvim barı + 3 bölümlü liste çalışır | ⬜ |
| Streak motoru doğru hesaplar | ⬜ |
| Es geçme hakkı sistemi çalışır | ⬜ |
| Kötü alışkanlık gün sayacı çalışır | ⬜ |
| İlk açılış onboarding ekranı görünür | ⬜ |
| Saatli görev bildirimi tetiklenir | ⬜ |
| Veriler uygulama restart'ta korunur (sqflite) | ⬜ |
| iPhone SE (375px) boyutunda kırılma yok | ⬜ |

---

## 🔮 V2+ — Gelecekte Eklenecek Özellikler

> Bu özellikler MVP kapsamı **dışındadır**. MVP onaylandıktan sonra backlog'a alınacaktır.

| Özellik | Açıklama | Tahmini Sprint |
|---------|----------|----------------|
| **iOS/Android Widget'ları** | `home_widget` paketi ile ana ekrandan tamamlama işaretleme ve seri görüntüleme | V2 · 2 sprint |
| **Kategorizasyon & Etiketler** | "Sağlık", "İş", "Kişisel Gelişim" renk kodlu etiketler ve filtreleme | V2 · 1 sprint |
| **Sürükle & Bırak Sıralama** | `ReorderableListView` ile aynı öncelik seviyesindeki kayıtları manuel sıralama | V2 · 1 sprint |
| **Ortak Hedefler (Social)** | Arkadaşlarla grup oluşturma, meydan okuma, ilerleme tablosu | V3 · 4 sprint |
| **Gelişmiş Veri Analitiği** | Aylık/yıllık başarı raporları, `fl_chart` ile grafikler | V2 · 2 sprint |
| **İnteraktif Onboarding Turu** | Uygulama büyüyünce tüm özellikleri anlatan `tutorial_coach_mark` destekli tur | V2 · 1 sprint |
| **Bulut Senkronizasyonu** | Supabase/Firebase ile çoklu cihaz desteği | V3 · 3 sprint |
| **Gamification** | Rozetler, seviye sistemi, haftalık challenge'lar | V3 · 2 sprint |
