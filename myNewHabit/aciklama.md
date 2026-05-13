# myNewHabit — Proje Yapısı Açıklaması

> Flutter ile geliştirilmiş, **local-first** (önce çevrimdışı) alışkanlık ve görev takip uygulaması.  
> Durum yönetimi: **Provider** | Navigasyon: **go_router** | Veritabanı: **SQLite (sqflite)** | Bulut: **Firebase**

---

## 📁 Kök Dizin

```
myNewHabit/
```

| Dosya / Klasör | Açıklama |
|---|---|
| `pubspec.yaml` | Flutter bağımlılık tanım dosyası. Provider, go_router, sqflite, Firebase, google_fonts gibi tüm paketler burada listelenir. |
| `pubspec.lock` | Bağımlılıkların kilitlenmiş (sabit) sürümlerini tutan otomatik oluşturulan dosya. Elle düzenlenmez. |
| `analysis_options.yaml` | Dart statik analiz kuralları. `flutter_lints` paketi üzerinden kod kalitesi standartları tanımlanır. |
| `firebase.json` | Firebase CLI yapılandırması. Hangi Firebase servislerinin (Firestore vb.) kullanıldığını tanımlar. |
| `README.md` | Proje hakkında kısa tanıtım metni. |
| `.metadata` | Flutter SDK'nın proje meta verilerini sakladığı dosya. Elle düzenlenmez. |
| `.gitignore` | Git'e dahil edilmeyecek dosyaları listeler (build çıktıları, gizli anahtarlar vb.). |
| `.flutter-plugins-dependencies` | Flutter native plugin bağımlılık grafiği. Otomatik üretilir. |
| `my_new_habit.iml` | IntelliJ/Android Studio modül dosyası. IDE tarafından yönetilir. |

---

## 📁 lib/

Uygulamanın tüm Dart kaynak kodunu barındıran ana dizin.

---

### 📄 lib/main.dart

Uygulamanın **giriş noktası**. Şunları yapar:

- Firebase'i başlatır (`Firebase.initializeApp`)
- Türkçe tarih formatını etkinleştirir (`initializeDateFormatting('tr_TR')`)
- Ekranı sadece dikey modda kilitler
- `DatabaseHelper` singleton'ını erken açar (eager init)
- `RecordRepository`, `CompletionRepository`, `StreakRepository` ve `CloudSyncService` nesnelerini oluşturur
- `MultiProvider` ile tüm provider'ları ağaca bağlar
- `MaterialApp.router` ile `go_router` tabanlı navigasyonu başlatır

---

### 📄 lib/firebase_options.dart

Firebase'in platforma özel yapılandırma bilgilerini (`projectId`, `appId`, `apiKey` vb.) tutan otomatik oluşturulan dosya. `flutterfire configure` komutuyla üretilir.

---

## 📁 lib/core/

Uygulamanın **çekirdek altyapısını** oluşturan; iş mantığından bağımsız yardımcı bileşenler, tema, navigasyon ve genel widget'lar.

---

### 📁 lib/core/router/

| Dosya | Açıklama |
|---|---|
| `app_router.dart` | `go_router` ile tanımlanmış uygulama yönlendirme haritası. Ana shell, home, focus ve profil rotaları burada tanımlanır. |

---

### 📁 lib/core/theme/

Uygulamanın **Neo-Brutalist** tasarım sistemini tanımlayan dosyalar.

| Dosya | Açıklama |
|---|---|
| `app_colors.dart` | Uygulamanın tüm renk paletini tanımlar. Koyu kenarlıklar, vurgular, arka plan tonları gibi sabitler burada bulunur. |
| `app_spacing.dart` | Tutarlı boşluk sabitleri (padding, margin, gap değerleri). Kodda magic number kullanımını önler. |
| `app_theme.dart` | `ThemeData` nesnesi; renk şeması, button teması, input dekorasyonları ve genel Material widget stillerini birleştiren ana tema dosyası. |
| `app_typography.dart` | Yazı tipi hiyerarşisini tanımlar. Google Fonts'tan alınan fontlar ve metin stilleri (başlık, gövde, etiket vb.) burada tanımlanır. |

---

### 📁 lib/core/utils/

| Dosya | Açıklama |
|---|---|
| `agent_arch_debug_log.dart` | Geliştirme/debug aşamasında mimari hipotezleri test etmek için kullanılan log yardımcısı. Production'da etkisiz. |
| `debug_session_log.dart` | Firebase başlatma ve uygulama yaşam döngüsü boyunca geliştirici debug loglarını konsola basan yardımcı. |
| `calendar_date.dart` | Tarih normalleştirme yardımcı fonksiyonları. Saat bilgisini sıfırlayarak sadece gün bazlı karşılaştırma yapar. |
| `neo_picker.dart` | Neo-Brutalist tasarım diline uygun, özel yapılmış tarih/saat seçici widget. Native date picker yerine kullanılır. |

---

### 📁 lib/core/widgets/

Uygulama genelinde kullanılan **yeniden kullanılabilir UI bileşenleri**.

| Dosya | Açıklama |
|---|---|
| `app_button.dart` | Uygulamaya özel kalın kenarlıklı, gölgeli Neo-Brutalist primary/secondary buton bileşeni. |
| `app_card.dart` | Genel amaçlı kart konteyneri. Tutarlı kenarlık, gölge ve padding sağlar. |
| `app_badge.dart` | Durum veya sayı göstermek için kullanılan küçük etiket (badge) bileşeni. |
| `brutalist_badge.dart` | Kalın kenarlıklı, köşeli Neo-Brutalist tarzda özel badge bileşeni. |
| `brutalist_container.dart` | Neo-Brutalism'in temel yapı taşı: kalın siyah kenarlık, offset solid shadow kutusu. |
| `empty_state_widget.dart` | Liste veya ekran boş olduğunda gösterilen boş durum illüstrasyonu ve metin bileşeni. |

---

## 📁 lib/data/

Uygulamanın **veri katmanı**. Veritabanı, modeller, repository'ler, servisler ve kimlik doğrulama burada tanımlanır.

---

### 📁 lib/data/auth/

Kimlik doğrulama soyutlaması. Strateji (Strategy) deseni kullanılmıştır.

| Dosya | Açıklama |
|---|---|
| `auth_backend.dart` | `AuthBackend` abstract sınıfı/arayüzü. Tüm auth implementasyonları bu kontratı uygular. |
| `auth_user.dart` | Giriş yapmış kullanıcıyı temsil eden basit veri modeli (`uid`, `email`, `displayName` vb.). |
| `firebase_auth_backend.dart` | `AuthBackend` arayüzünün Firebase Auth ile gerçek implementasyonu. Google, Apple ve e-posta girişini destekler. |
| `mock_auth_backend.dart` | Test ve geliştirme ortamı için sahte (fake) auth implementasyonu. Firebase gerektirmez. |

---

### 📁 lib/data/database/

| Dosya | Açıklama |
|---|---|
| `database_helper.dart` | SQLite veritabanı yöneticisi (Singleton). Tabloları oluşturur, migrasyon yönetir; `records`, `completions`, `streaks`, `sync_meta` tablolarını barındırır. |

---

### 📁 lib/data/models/

Uygulamanın **veri modelleri** (PODO — Plain Old Dart Objects).

| Dosya | Açıklama |
|---|---|
| `record_model.dart` | Bir alışkanlık veya yapılacak görevi temsil eder. Tür (habit/todo), isim, öncelik, zamanlama, tekrar günleri, renk gibi alanları içerir. |
| `completion_model.dart` | Belirli bir tarihteki alışkanlık tamamlanma kaydı. `recordId` ve `date` ile tanımlanır. |
| `streak_model.dart` | Bir alışkanlığın güncel seri (streak) bilgisini tutar: mevcut seri uzunluğu, en uzun seri, son kontrol tarihi. |
| `sync_meta_row.dart` | Bulut senkronizasyonunun son çalışma zamanını ve durumunu tutan meta veri satırı. |

---

### 📁 lib/data/repositories/

**Repository deseni** — veri kaynağını (SQLite) iş mantığından soyutlar.

| Dosya | Açıklama |
|---|---|
| `record_repository.dart` | `RecordRepository` abstract sınıfı + `SqfliteRecordRepository` implementasyonu. Alışkanlık/görev CRUD işlemleri. |
| `completion_repository.dart` | `CompletionRepository` abstract sınıfı + `SqfliteCompletionRepository`. Tamamlanma kaydı ekleme, sorgulama ve silme. |
| `streak_repository.dart` | `StreakRepository` abstract sınıfı + `SqfliteStreakRepository`. Seri verilerini okuma ve güncelleme. |

---

### 📁 lib/data/services/

Üst düzey iş mantığı servisleri.

| Dosya | Açıklama |
|---|---|
| `streak_service.dart` | Bir alışkanlığın seri hesaplama mantığını barındırır. Hangi günlerde tamamlanma gerektiğini, serinin kırılıp kırılmadığını hesaplar. |
| `cloud_sync_service.dart` | Yerel SQLite verisini Firebase Firestore ile iki yönlü senkronize eder. Senkronizasyon stratejisi ve çakışma çözümü burada tanımlanır. |
| `cloud_sync_executor.dart` | `CloudSyncService`'i belirli aralıklarla veya tetikleyiciyle çalıştıran zamanlayıcı/executor sarmalayıcısı. |

---

### 📁 lib/data/utils/

| Dosya | Açıklama |
|---|---|
| `habit_schedule.dart` | Bir alışkanlığın belirli bir tarihe denk gelip gelmediğini hesaplayan zamanlama yardımcı fonksiyonları (günlük, haftalık, belirli günler). |
| `completion_row_id.dart` | `completions` tablosundaki bileşik birincil anahtarı (`recordId + date`) üreten deterministik ID yardımcısı. |

---

## 📁 lib/modals/

Kullanıcı etkileşimlerini yöneten **bottom sheet ve dialog** bileşenleri.

| Dosya | Açıklama |
|---|---|
| `naming_modal.dart` | Yeni kayıt oluştururken ilk adım olan isim girişi modalı. Hem alışkanlık hem yapılacak iş türünü destekler. |
| `add_record_modal.dart` | Yeni alışkanlık veya görev ekleme akışını başlatan üst düzey modal. Tür seçimi burada yapılır. |
| `habit_details_sheet.dart` | Alışkanlık detaylarını (tekrar günleri, bildirim saati, renk, hedef) giren bottom sheet. |
| `todo_details_sheet.dart` | Yapılacak iş detaylarını (bitiş tarihi, saat, öncelik, not) giren Neo-Brutalist bottom sheet. |
| `edit_record_sheet.dart` | Mevcut bir alışkanlık veya görevi uzun basılı tutarak düzenleme imkânı sunan bottom sheet. Hem habit hem todo alanlarını destekler. |
| `task_timing_sheet.dart` | Görev zamanlaması için özel tarih ve saat seçici içeren bottom sheet. `neo_picker.dart` bileşenini kullanır. |
| `focus_mode_picker_sheet.dart` | Odak modu (focus session) süresi seçimi için gösterilen picker bottom sheet. |
| `streak_stats_dialog.dart` | Bir alışkanlığın mevcut seri ve en uzun seri istatistiklerini gösteren küçük dialog bileşeni. |

---

## 📁 lib/providers/

**Provider** (ChangeNotifier) tabanlı durum yönetimi katmanı. UI ile veri katmanı arasındaki köprü.

| Dosya | Açıklama |
|---|---|
| `record_provider.dart` | Tüm kayıt (alışkanlık/görev) listesini yönetir. Ekleme, güncelleme, silme işlemlerini `RecordRepository` üzerinden yapar ve UI'ı bilgilendirir. |
| `completion_provider.dart` | Belirli tarihler için tamamlanma durumlarını yönetir. Toggle (işaretleme/kaldırma) işlemi sonrası streak hesabını tetikler. |
| `streak_provider.dart` | Seri verilerini saklar ve `StreakService` ile günceller. Completion değişikliklerinden sonra otomatik reconcile yapar. |
| `auth_session_provider.dart` | Kullanıcı oturum durumunu yönetir. Giriş, çıkış ve oturum değişim olaylarını dinler. |
| `sync_status_provider.dart` | Bulut senkronizasyonunun son durumunu (başarılı/hatalı/çalışıyor) UI'a açar. |

---

## 📁 lib/screens/

Uygulamanın gezinebilir **ekranları**.

---

### 📁 lib/screens/shell/

| Dosya | Açıklama |
|---|---|
| `main_shell.dart` | Alt navigasyon çubuğunu (bottom nav) ve sayfa geçişlerini yöneten ana scaffold shell. `go_router` ile `ShellRoute` olarak kullanılır. |

---

### 📁 lib/screens/home/

Ana ekran — günlük alışkanlık ve görev listesi.

| Dosya | Açıklama |
|---|---|
| `home_screen.dart` | Ana ekranın gövdesi. Takvim çubuğu, filtreler ve alışkanlık/görev listesini birleştirir. |
| `visible_habits_for_date.dart` | Seçilen tarihe göre görünmesi gereken alışkanlıkları filtreleyen saf fonksiyon. |

#### 📁 lib/screens/home/widgets/

| Dosya | Açıklama |
|---|---|
| `calendar_bar_widget.dart` | Yatay kaydırmalı, haftalık takvim çubuğu. Gün seçimi ve bugünü vurgulama özelliklidir. |
| `habit_card.dart` | Alışkanlık öğesini gösteren kart. Tamamlama toggle'ı, seri rozeti ve uzun basış düzenleme menüsü içerir. |
| `todo_card.dart` | Yapılacak iş öğesini gösteren kart. Öncelik rengi, bitiş saati ve tamamlama checkbox'ı içerir. |
| `event_card.dart` | Takvim olaylarını gösteren kart bileşeni. |
| `filter_chip_bar.dart` | "Hepsi / Alışkanlıklar / Yapılacaklar" gibi filtre seçeneklerini gösteren yatay chip çubuğu. |
| `todo_filter_button.dart` | Yapılacak işler için sıralama ve filtreleme seçenekleri sunan özel buton/sheet. |

---

### 📁 lib/screens/focus/

| Dosya | Açıklama |
|---|---|
| `focus_section.dart` | Odak modu bölümü için barrel export dosyası. |
| `focus_section_screen.dart` | Odak modu (Pomodoro tarzı çalışma zamanlayıcısı) ekranı. Zamanlayıcı, mod seçimi ve oturum takibini yönetir. |

---

### 📁 lib/screens/habit/

> ⚠️ Klasör şu an boş. Alışkanlığa özel detay veya istatistik ekranı için ayrılmıştır (ilerleyen sprint'lerde dolacak).

---

### 📁 lib/screens/profile/

| Dosya | Açıklama |
|---|---|
| `profile_screen.dart` | Profil ekranı. Kullanıcı bilgileri, bulut senkronizasyon durumu ve çıkış işlemlerini barındırır. |

#### 📁 lib/screens/profile/widgets/

| Dosya | Açıklama |
|---|---|
| `profile_sign_in_row.dart` | Kullanıcının giriş durumunu (anonim / giriş yapılmış) gösteren özet satır bileşeni. |
| `profile_email_sign_in_sheet.dart` | E-posta ve şifre ile giriş / kayıt olma bottom sheet'i. |
| `profile_cloud_sync_card.dart` | Bulut senkronizasyon durumunu, son senkronizasyon zamanını ve "Şimdi Senkronize Et" butonunu gösteren kart. |
| `profile_benefits_card.dart` | Oturum açmanın faydalarını listeleyen bilgilendirme kartı (veri yedekleme, çoklu cihaz vb.). |

---

## 📁 lib/debug/

> ⚠️ Klasör şu an boş. Geliştirici/debug yardımcı araçları için ayrılmıştır.

---

## 📁 firebase/

| Dosya | Açıklama |
|---|---|
| `firestore.rules` | Firebase Firestore güvenlik kuralları. Hangi kullanıcının hangi verilere erişebileceğini tanımlar. |

---

## 📁 test/

Otomatik test dosyaları. `lib/` dizininin yapısını yansıtır.

| Dosya | Açıklama |
|---|---|
| `widget_test.dart` | Genel widget testleri ve uygulama smoke testi. |
| `scratch_db_test.dart` | Veritabanı davranışını doğrulayan geçici/deneme test dosyası. |

### 📁 test/core/theme/
| Dosya | Açıklama |
|---|---|
| `app_colors_test.dart` | Renk sabitlerinin doğru tanımlandığını doğrulayan birim testleri. |

### 📁 test/data/auth/
| Dosya | Açıklama |
|---|---|
| `mock_auth_backend_test.dart` | `MockAuthBackend`'in beklenen davranışları sergilediğini doğrulayan birim testleri. |

### 📁 test/data/database/
| Dosya | Açıklama |
|---|---|
| `sync_meta_test.dart` | `sync_meta` tablosu okuma/yazma işlemlerini doğrulayan birim testleri. |

### 📁 test/data/repositories/
| Dosya | Açıklama |
|---|---|
| `record_repository_test.dart` | Record CRUD operasyonlarını in-memory SQLite ile test eder. |
| `record_repository_stub.dart` | Test izolosyonu için sahte `RecordRepository` implementasyonu. |
| `completion_repository_test.dart` | Completion kayıt ekleme/sorgulama testleri. |
| `completion_repository_stub.dart` | Test için sahte `CompletionRepository`. |
| `streak_repository_stub.dart` | Test için sahte `StreakRepository`. |

### 📁 test/data/services/
| Dosya | Açıklama |
|---|---|
| `streak_service_test.dart` | `StreakService`'in seri hesaplama ve kırılma mantığını doğrulayan kapsamlı birim testleri. |

### 📁 test/providers/
| Dosya | Açıklama |
|---|---|
| `record_provider_test.dart` | `RecordProvider` durum yönetimini stub repository'lerle test eder. |
| `completion_provider_test.dart` | `CompletionProvider`'ın toggle ve streak tetikleme davranışını test eder. |
| `sync_status_provider_test.dart` | `SyncStatusProvider`'ın senkronizasyon durum geçişlerini doğrular. |

### 📁 test/screens/
| Dosya | Açıklama |
|---|---|
| `navigation_test.dart` | `go_router` tabanlı sayfa gezintisini widget testleriyle doğrular. |
| `profile_screen_test.dart` | Profil ekranının farklı oturum durumlarında doğru render edildiğini test eder. |

---

## 📁 Platform Klasörleri

Flutter'ın her platforma özgü native yapılandırma ve proje dosyalarını barındırır.

| Klasör | Açıklama |
|---|---|
| `android/` | Android native proje. `build.gradle`, manifest, Firebase google-services.json buradadır. |
| `ios/` | iOS native proje. Xcode workspace, Info.plist, Firebase GoogleService-Info.plist buradadır. |
| `web/` | Web platformu yapılandırması. `index.html` ve web-specific ayarlar. |
| `macos/` | macOS desktop native proje dosyaları. |
| `linux/` | Linux desktop native proje dosyaları. |
| `windows/` | Windows desktop native proje dosyaları. |

---

## 📁 Diğer Özel Klasörler

| Klasör | Açıklama |
|---|---|
| `.dart_tool/` | Dart toolchain tarafından otomatik yönetilen cache ve yapılandırma. Elle düzenlenmez. |
| `.idea/` | IntelliJ / Android Studio IDE ayarları. Run configuration ve proje ayarlarını içerir. |
| `build/` | Derleme çıktıları. `.gitignore`'da listelenmiştir, repo'ya dahil edilmez. |
| `coverage/` | `flutter test --coverage` çalıştırıldığında üretilen lcov kapsam raporları. |

---

## 🏛️ Mimari Özet

```
┌─────────────────────────────────────────────┐
│                  UI Katmanı                 │
│    screens/  •  modals/  •  core/widgets/   │
├─────────────────────────────────────────────┤
│              Durum Yönetimi                 │
│               providers/                   │
├─────────────────────────────────────────────┤
│               Veri Katmanı                  │
│  repositories/  •  services/  •  models/   │
├─────────────────────────────────────────────┤
│            Altyapı / Sürücüler              │
│   database/ (SQLite)  •  auth/ (Firebase)  │
└─────────────────────────────────────────────┘
```

- **Bağımlılık yönü:** UI → Provider → Repository (abstract) ← Concrete Implementation  
- **DIP ilkesi:** Tüm repository'ler abstract sınıf üzerinden kullanılır; concrete sınıf `main.dart`'ta enjekte edilir.  
- **Local-first:** Tüm veriler önce SQLite'a yazılır; senkronizasyon arka planda Firebase'e akar.
