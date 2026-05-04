# Sprint 5 — Hata Çözümleri ve UI/UX İyileştirmeleri Logu

**Tarih:** 2026-05-05
**Sprint:** Sprint 5 - Ana Sayfa UI Revizyonu & İlerleme Mekanizmaları (Bug Fixes)

## Tamamlanan Görevler (Bug Fixes)
Bu oturumda, uygulamanın kullanıcı deneyimini doğrudan etkileyen ve önceki çalışmalardan kalan 4 ana UI/UX hatası kalıcı olarak giderilmiştir:

- [x] **Bug 1: Düzenle (Edit) Menüsünün Navigation Bar Altında Kalması**
  - Tüm kayıt tipleri (Todo, Habit, Event) için düzenleme formunu açan `_showEditSheet` modalında `useRootNavigator: true` ayarı eklendi. Artık bottom sheet açıldığında, uygulamanın alt kısmında yer alan yüzen Navigation Bar, formun üzerinde istenmeyen bir katman oluşturmuyor.
- [x] **Bug 2: Düzenle Menüsünde Eksik Form Alanları**
  - Orijinal düzenle formu yalnızca başlık (Title) güncellemeye izin veriyordu. Form genişletildi; `RecordModel` yapısının kopyalanarak güncellenmesini sağlayacak ekstra alanlar eklendi:
    - Yapılacaklar (Todo) için: *Bitiş Tarihi (Due Date)* seçici.
    - Etkinlik (Event) için: *Başlangıç Tarihi/Saati* ve *Bitiş Tarihi/Saati* seçicileri.
    - Alışkanlıklar (Habit) için: *Tekrar Günleri* ve *Aralık (Interval)* değişkenleri.
- [x] **Bug 3: "Yapılacakları Filtrele" Alt Menüsünün Ekrana Sığmaması (Overflow Hatası)**
  - Ana ekrandaki filtre butonuna tıklandığında açılan `_showFilterSheet` yapısı, özellikle küçük ekranlarda `OVERFLOWED BY 183 PIXELS` hatasına (sarı-siyah şerit) neden oluyordu.
  - Formun yüksekliğini içeriklere göre ayarlayabilmesi için `isScrollControlled: true` eklendi.
  - İçerikler `SingleChildScrollView` ile sarmalandı. Böylece dar ekranlarda kaydırılabilir, sağlam bir liste sunulması sağlandı.
  - **Filtre UI İyileştirmesi:** "Durum" (Yapılanlar, Yapılacaklar) filtreleme menüsünün en tepesine taşındı ve gereksiz olan "Tümü" seçeneği filtreden kaldırılarak UI daha da sadeleştirildi. Ayrıca filtre durumu doğrudan UI'da reactivity ile yansıtılacak şekilde `Consumer<RecordProvider>` yapısı içine alındı.
- [x] **Bug 4: Alışkanlık İlerlemesinin (Progress) Yeni Günlerde Sıfırlanmış Görünmemesi**
  - Daha önce yatay takvim widget'ı üzerinden (örn. Pazartesi'den Salı'ya) tıklandığında, `RecordProvider.selectDate` ile sadece günün görevleri listeleniyor, ancak tamamlanma istatistikleri güncellenmiyordu.
  - `calendar_bar_widget.dart` dosyası güncellenerek takvimdeki tarihlere tıklandığında hem kayıtların hem de `CompletionProvider.loadForDate` çağrımı üzerinden o günün ilerleme yüzdelerinin baştan getirilmesi sağlandı.

## Güncellenen / Yazılan Dosyalar
| Dosya | Açıklama |
|---|---|
| `lib/modals/edit_record_sheet.dart` | Tüm `RecordModel` ayarlarının düzenlenebileceği modüler bir kayıt düzenleme sistemine dönüştürüldü. Navigation bar çakışmasını engellemek için Root Navigator aktifleştirildi. |
| `lib/screens/home/home_screen.dart` | `_showFilterSheet` alt menüsü taşmaları engelleyecek hale getirildi. Filtre seçim mekanizması (Durumların üste çıkartılması, Tümü seçeğinin silinmesi) ve Consumer bağlantıları ile gerçek zamanlı UI güncellemeleri tamamlandı. |
| `lib/screens/home/widgets/calendar_bar_widget.dart` | Takvim elementlerinin üzerine tıklandığında, UI'ın sadece görevleri değil, progress'leri (ilerlemeleri) de yenilemesini sağlamak için onTap olayına CompletionProvider tetikleyicisi eklendi. |
| `lib/providers/record_provider.dart` | FilterType logic değişkenleri (`activeFilter` -> `activeFilters` listesi olarak) yeniden düzenlenerek compile uyarıları kaldırıldı. Encapsulation standartları iyileştirildi. |
| `test/providers/record_provider_test.dart` | Güncellenen `toggleFilter` gibi yapılarla uyumlu hale getirildi, unit testlerin syntax hataları ve uyum sorunları giderilerek projenin sıfır hataya ve yeşil duruma düşmesi sağlandı. |

## Kod Kalitesi ve Test Durumu
- `flutter analyze`: **Hiçbir hata bulunmuyor.**
- `flutter test`: **46 test başarılı. %100 Pass.**

## Özet
Kritik kullanıcı deneyimi bloklayıcıları (modal kesintileri ve form overflow sorunları) ile veri taşıma tutarsızlıkları tamamen çözülmüştür. Bu iyileştirmelerin ardından uygulama içi veri tutarlılığı maksimumda tutulurken sorunsuz test kapsamı korunmuştur.