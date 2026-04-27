# Sprint 2 Log: Veri Katmanı & Kayıt Tipleri

## Tarih: 2026-04-26

### Yapılan İşler:
1. **Veri Modelleri Oluşturuldu:**
   - `RecordModel`: Alışkanlık, Görev, Kötü Alışkanlık türlerini destekleyen ortak model.
   - `CompletionModel`: Günlük tamamlama durumlarını tutan model.
   - `StreakModel`: Alışkanlık serilerini takip eden model.

2. **Veritabanı Altyapısı (SQLite/sqflite):**
   - `DatabaseHelper` singleton'ı kuruldu.
   - Test izolasyonu sağlamak amacıyla in-memory database destegi (`DatabaseHelper.forTesting()`) eklendi.
   - Foreign Key Constraint'leri ve basamaklı silme (CASCADE DELETE) özelliği aktif edildi.

3. **Repository Katmanı:**
   - `RecordRepository` arayüzü ve `SqfliteRecordRepository` SQLite implementasyonu eklendi.
   - `CompletionRepository` arayüzü ve `SqfliteCompletionRepository` implementasyonu eklendi.

4. **Provider'lar (State Management):**
   - `RecordProvider` ve `CompletionProvider` yazılarak, repository katmanı ile UI arasındaki bağ kuruldu.
   - `main.dart` içerisine `MultiProvider` yapısı eklendi.

5. **Modallar ve UI Akışları:**
   - Kayıt ekleme akışı bottom-sheet yapısıyla entegre edildi:
     - `showAddRecordModal` (Tip Seçimi)
     - `showNamingModal` (İsim Verme)
     - `showHabitDetailsSheet` (Alışkanlık Detayları)
     - `showTaskTimingSheet` (Görev Zamanlama)
     - `showQuitSheet` (Kötü Alışkanlık Bırakma)
   - `main_shell.dart` içerisindeki navigasyon çubuğu (Floating Action Button / Bottom Nav Bar) üzerinden modal zinciri aktif edildi.

6. **Birim Testler:**
   - `RecordRepository`, `CompletionRepository` ve `RecordProvider` testleri yazıldı (`sqflite_common_ffi` ile).
   - Test izolasyonu problemleri in-memory veritabanı örnekleriyle çözüldü ve tüm testlerin başarıyla geçtiği onaylandı.

### Sonuç:
Sprint 2 başarıyla tamamlandı. Offline çalışan bir veritabanı altyapısı, dependency injection prensiplerine uygun mimari ve test-driven bir geliştirme ile sağlam bir taban atıldı. Sonraki adımda (Sprint 3) ana sayfa UI entegrasyonu, takvim şeridi ve gün bazlı listeleme işlemlerine geçilecektir.

---

### Değişmeliler.md Ek Geliştirmeleri (27 Nisan 2026)
Sprint 2 tamamlandıktan sonra alınan geri bildirimler doğrultusunda şu eklemeler yapıldı:
- **Veritabanı & Modeller:** `RecordModel` ve veritabanı şemasına "X günde bir" tekrar mekanizması için `interval_days` (INTEGER) eklendi. `getByDate` filtresi bu mantığa göre baştan yazıldı.
- **UI Revizyonları (Add Record):** "Görev / Plan" ibaresi **"Takvime Ekle"**, "Alışkanlık" ise **"Yeni Alışkanlık"** olarak değiştirildi ve emojileri yenilendi.
- **UI Revizyonları (Habit Details):** Belirli gün seçme işlemine alternatif olarak "X günde bir" açılır menüsü eklendi. XOR mantığı kurularak kullanıcı aynı anda hem gün hem aralık seçmesi engellendi ve en az biri seçilmeden kaydetmesi kapatıldı.
- **UI Revizyonları (Task Timing):** "Takvime Ekle" modülünde eskiden sadece saat sorulurken artık **Başlangıç Tarihi ve Saati** ile **Bitiş Tarihi ve Saati** sorulabilir hale getirildi. Veritabanındaki `createdAt` mantığı artık kullanıcının seçtiği başlangıç tarihi olarak ayarlandı.
- **UI Revizyonları (Kötü Alışkanlık):** Kullanıcıya gereksiz yere iki kez isim sorulması engellendi. "Naming Modal" atlanıp direkt `showQuitSheet` açıldı.
- **Birim Testleri:** Tüm bu değişiklikler yeni test case'leri yazılarak (`intervalDays` filtreleri vb.) `%100` başarıyla doğrulandı.
