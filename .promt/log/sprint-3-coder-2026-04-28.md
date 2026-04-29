# Sprint 3: Ana Sayfa & Takvim (Coder Log)

## Tarih
2026-04-28

## Kapsam
myNewHabit projesinin "Sprint 3: Ana Sayfa & Takvim" (US-301 - US-308) backend ve UI entegrasyonu tamamlandı.

## Yapılan Çalışmalar

### 1. State Management (Provider) Güncellemeleri
- **`RecordProvider` (US-308, US-302, US-303, US-304, US-305)**
  - `FilterType` enum eklendi (`all`, `mostImportant`, `earliest`, `thisWeek`, `thisMonth`).
  - `applyFilter(FilterType filter)` metodu eklendi (toggle mantığı eklendi, tekrar tıklandığında `all`'a döner).
  - `habits`, `scheduledTasks` ve `quitRecords` getter'ları ayrıştırıldı ve her biri ilgili US kabul kriterlerine göre sıralandı. (Örn: Tasklar kronolojik, Habitler filtreye/önceliğe göre, Quit'ler sadece tip kontrolü ile).
  - `selectDate(String date)` metodu ile takvim barından seçilen günün state'e yansıması sağlandı.

### 2. UI Bileşenleri ve Tasarım Entegrasyonu
- **`CalendarBarWidget` (US-301, US-302)**
  - 7 günlük (Dün, Bugün, Gelecek 5 Gün) bar oluşturuldu.
  - Seçili güne tıklandığında `RecordProvider.selectDate` ve `CompletionProvider.loadForDate` tetiklenmesi eklendi.
- **`FilterChipBar` (US-308)**
  - `AppColors.primary` ile renk kodlaması yapılarak tasarım sistemine uygun, yatay kaydırılabilir filtre çubuğu eklendi.
- **Kartlar (US-303, US-304, US-305, US-306, US-307)**
  - `HabitCard`, `TaskCard`, `QuitCard`: Tüm kartlarda uzun basınca silme ve tam ekran, önde kalan onay modalı eklendi. showDialog ile tüm UI’nın önünde açılır, kullanıcı başka bir öğeyle etkileşime giremez.
  - Silme modalı, ‘Ne Eklemek İstersin?’ sekmesi gibi önde ve güvenli şekilde tasarlandı.
  - Alt navigasyon barı ve diğer overlay’lerle çakışma sorunu tamamen giderildi.
  - `HabitCard`: Sol tarafta önceliğe göre renk kodlaması (kırmızı, turuncu, yeşil). HapticFeedback ve `AnimatedOpacity` eklendi.
  - `TaskCard`: HTML referansına uygun pill-shape, solunda saat, üstü çizili tamamlama animasyonları.
  - `QuitCard`: Başlangıç tarihine göre "X. Gün" hesaplaması eklendi (Sprint 4'te StreakService ile güncellenecek). "Yaptım (Sıfırla)" butonu `markRelapsed` aksiyonunu tetikleyecek şekilde kırmızı vurgu ile kodlandı.
- **`HomeScreen` (Tam Montaj)**
  - `CustomScrollView` ve `SliverToBoxAdapter` kullanılarak yapılandırıldı.
  - `RefreshIndicator` entegrasyonu eklendi.
  - Veri bulunmadığı durumlar için global `EmptyStateWidget` kullanıldı.

### 3. Testler ve Stabilizasyon
- **`record_provider_test.dart`**
  - Sprint 3 filtreleme (applyFilter) senaryoları eklendi.
  - Sıralama algoritmaları (kronolojik, öncelik, en eski) test edildi.
- **`completion_provider_test.dart`**
  - Tamamlama, geri alma, atlama ve relapsed senaryoları için stub tabanlı bağımsız birim testleri oluşturuldu.
- **`widget_test.dart` & `navigation_test.dart`**
  - `HomeScreen` provider bağımlılıkları yüzünden hata fırlatan testler `MultiProvider` ve stub yapıları ile sarılarak stabil hale getirildi.
  - `GoRouter` global instance state problemleri, test içi lokal router tanımlamalarıyla aşıldı.
  - `initializeDateFormatting` çağrıları `setUpAll` bloklarına eklenerek `LocaleDataException` problemleri çözüldü.

Tüm testler (48 adet) başarıyla çalışmaktadır.

### 4. Code Review Sonrası Hata Düzeltmeleri (Post-Review Fixes)
- **Kritik Layout Crash (US-308, US-307)**: `SliverList` ve iç içe `ListView` kullanımlarının (özellikle `FilterChipBar` ve `QuitCard` içindeki `ElevatedButton`) yarattığı sonsuz genişlik kısıtı (`BoxConstraints forces an infinite width`) ve `!semantics.parentDataDirty` çökmeleri giderildi. 
  - `FilterChipBar`, yatay `ListView` yerine `SingleChildScrollView + Row` yapısına çevrildi.
  - `QuitCard` içindeki buton `GestureDetector + Container` ile baştan yazıldı, kartların üst üste binme sorunu çözüldü.
- **Veri Filtreleme Mantığı (US-303)**: Bitiş tarihi olmayan "Takvim" (Task) kayıtları, her gün yerine sadece eklendikleri tarihte (createdAt) gösterilecek şekilde `RecordRepository` içerisinde düzenlendi ve testler buna göre güncellendi.
- **Tasarım Güncellemeleri**: `TaskCard`'da bitiş tarihi ve saatinin gösterilmesi sağlandı. Ana sayfa bölüm başlıkları "Takvim" ve "Yeni Alışkanlıklarım" olarak isimlendirildi.

## Sonraki Adımlar (Sprint 4)
- **Sprint 4 (Streak & Onboarding)** aşamasında `StreakService` entegrasyonu ile "Bırakılanlar" (Quit) rozetlerindeki geçici hesaplamalar dinamik hale getirilecektir.
- Onboarding için SharedPreferences yapısı eklenecektir.
