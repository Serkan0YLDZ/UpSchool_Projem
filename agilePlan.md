# myNewHabit MVP için Yeni Agile Planı (PRD Revizyonu)

> **Platform:** Flutter (Dart) · **Hedef:** Local'de çalışan, tam işlevsel MVP  
> **Renk Paleti:** Primary `#0077B6` · Secondary `#90E0EF` · Tertiary `#00B4D8` · Neutral `#F8FBFF`  
> **Font:** Plus Jakarta Sans (Google Fonts)

---

## 📍 Şu Anki Durum (Durum Özeti)

Şu ana kadar projenin Sprint 1, Sprint 2 ve Sprint 3 aşamaları kodlanmış durumdadır. Uygulamanın temel veri katmanı (`sqflite`), takvim barı ve ana sayfa listeleri inşa edilmiştir.

**ANCAK**, bu sprintler eski PRD'ye göre geliştirilmiş olduğu için:
1. Uygulamada "Kötü Alışkanlık" (Quit) özelliği kodlanmış durumdadır. Yeni PRD ile bu yapı tamamen projeden çıkarılmıştır.
2. Kayıt tipleri ve veri modelleri eski tasarıma göre (Örn: Alışkanlıkların 0-100% ilerlemesi yoktur, Todo listesinin filtreleri eksiktir) çalışmaktadır.

Bu nedenle plan, **Sprint 4'ten itibaren** tamamen yeni PRD'nin "V1 — MVP" kurallarına göre yeniden yapılandırılmıştır.

---

## 📋 Genel Bakış (Yeni MVP Yol Haritası)

| # | Sprint | Süre | Odak |
|---|--------|------|------|
| 4 | PRD Revizyonu & Veri Modeli Adaptasyonu | 1 hafta | Quit modelinin silinmesi, Event/Habit/Todo geçişi, DB migration |
| 5 | Ana Sayfa UI Revizyonu & İlerleme | 1 hafta | 0-100% progress, Todo filtreleri, Long Press etkileşimleri |
| 6 | Seri (Streak) Sistemi & Es Geçme | 1 hafta | Streak motoru, haftalık skip hakkı |
| 7 | Onboarding, Profil & MVP Çıkışı | 1 hafta | İlk açılış, bildirimler, QA testleri |

**Kalan MVP Süresi: ~4 Hafta**

---

## 🛠️ Sprint 4 — PRD Revizyonu & Veri Modeli Adaptasyonu

**Hedef:** İptal edilen özelliklerin projeden tamamen temizlenmesi, veritabanının yeni `Event`, `Habit`, `Todo` tiplerine göre yapılandırılması ve Ekleme menüsünün (Bottom Sheet) güncellenmesi.

### Kullanıcı Hikayeleri

| ID | Hikaye | Öncelik |
|----|--------|---------|
| US-401 | Geliştirici olarak, gereksiz "Kötü Alışkanlık" (Quit) kodlarını temizleyerek projeyi sadeleştirmeliyim. | 🔴 Kritik |
| US-402 | Kullanıcı olarak, "+" butonuna bastığımda "Takvime Ekle", "Yeni Alışkanlık" ve "Yapılacak Ekle" seçeneklerini görmeliyim. | 🔴 Kritik |
| US-403 | Kullanıcı olarak, yeni alışkanlık eklerken %0-100 arasında bir hedef ilerleme (Örn: "Günde 2 litre su" için %100 hedefine ulaşana kadar arttırılabilir bir yapı) belirleyebilmeliyim. | 🔴 Kritik |
| US-404 | Kullanıcı olarak, yapılacak (Todo) eklerken isteğe bağlı bir bitiş tarihi seçebilmeliyim. | 🟠 Yüksek |

### Teknik Görevler

- [x] `Quit` tipi, widget'ları (`QuitCard`), modelleri ve state logic'lerinin tamamen silinmesi.
- [x] `RecordModel`'in güncellenmesi: `type` alanı -> `event`, `habit`, `todo` olarak değiştirilmeli.
- [x] DB Şeması Güncellemesi: `target_progress`, `scheduled_date`, `end_time`, `due_date`, `description` vb. yeni kolonların `records` tablosuna eklenmesi. `completions` tablosuna `progress` kolonu eklenmesi.
- [x] Bottom Sheet Revizyonu 1: "Ne Eklemek İstersin?" kısmında 3 yeni seçeneğin listelenmesi.
- [x] Bottom Sheet Revizyonu 2: Seçilen tipe göre sadece ilgili alanların (Örn: Habit için `%` hedefi, Todo için bitiş tarihi) gösterildiği dinamik form yapısının oluşturulması.

### Kabul Kriterleri

- [x] Kötü alışkanlıklarla ilgili hiçbir kod parçası, model veya arayüz öğesi kalmamıştır.
- [x] Yeni modellerle DB'ye sorunsuz bir şekilde Event, Habit, Todo eklenebilmektedir ve `flutter run` hatasız çalışır.

---

## 🎨 Sprint 5 — Ana Sayfa UI Revizyonu & İlerleme Mekanizmaları

**Hedef:** Ana sayfadaki 3 ana bölümü yeni PRD'ye göre yeniden inşa etmek; 0-100% ilerleme çubuklarını ve Yapılacaklar (Todo) listesinin filtreleme sistemini aktif etmek.

### Kullanıcı Hikayeleri

| ID | Hikaye | Öncelik |
|----|--------|---------|
| US-501 | Kullanıcı olarak, "Alışkanlık Takibi" bölümündeki görevlerimi %0'dan %100'e kadar yüzdelik olarak (buton veya slider ile) ilerletebilmeliyim. | 🔴 Kritik |
| US-502 | Kullanıcı olarak, alışkanlık %100 olduğunda kartın görsel olarak "tamamlandı" durumuna geçtiğini görmeliyim. | 🔴 Kritik |
| US-503 | Kullanıcı olarak, "Yapılacaklar" bölümünü "En Önemli" veya "En Yakın Bitiş Tarihi"ne göre sıralayabilmeliyim. | 🟠 Yüksek |
| US-504 | Kullanıcı olarak, "Yapılacaklar" bölümünde zaman aralığı (Bugün, Bu Hafta, Tümü) seçebilmeliyim. | 🟠 Yüksek |
| US-505 | Kullanıcı olarak, ana sayfadaki herhangi bir kaydın üzerine **uzun bastığımda** onu düzenleyebilmeli veya silebilmeliyim. | 🔴 Kritik |

### Teknik Görevler

- [x] **Takvim Etkinlikleri Bölümü:** Saat/tarih etiketli, Event modeline uygun yeni kart tasarımı (Checkbox'lı).
- [x] **Alışkanlık Takibi Bölümü:** Kart üzerinde `Slider` veya ilerleme butonlarıyla `%` değerinin güncellenebilmesi. Tamamlanma durumunun `%100` eşiğine bağlanması (Eski Checkbox'ın kaldırılması).
- [x] **Yapılacaklar Listesi Bölümü:** Sadece `Todo`'ların gösterildiği yapı. Sağ üstte 2 boyutlu (Sıralama x Zaman Aralığı) filtrenin UI ve logic olarak eklenmesi.
- [x] Tüm kartlarda **Uzun Basma (Long Press)** etkileşiminin eklenmesi:
  - Uzun basınca "Düzenle" için dolu formun (Bottom Sheet) açılması.
  - "Sil" tıklandığında uygulamanın en önünde açılan tam ekran onay modalının tasarlanması.

### Kabul Kriterleri

- [x] Alışkanlıklar %100 olmadan "Tamamlandı" statüsüne geçmez, %100 olunca yeşil/tamamlandı durumuna geçer.
- [x] Todo filtreleri veri anında yenilenecek şekilde tıklandığında çalışır.
- [x] Her kart uzun basılarak güvenli şekilde silinebilir/düzenlenebilir. UI kırılmaz.

---

## 🔥 Sprint 6 — Seri (Streak) Sistemi & Es Geçme Hakkı

**Hedef:** Alışkanlıklar için streak motorunun kurulması, rozet gösterimi ve haftalık "Es Geç" (Skip) mekaniği.

### Kullanıcı Hikayeleri

| ID | Hikaye | Öncelik |
|----|--------|---------|
| US-601 | Kullanıcı olarak, bir alışkanlığı %100 tamamladığımda serim (🔥) artmalı ve kartın üstünde rozet olarak görünmelidir. | 🔴 Kritik |
| US-602 | Kullanıcı olarak, bir alışkanlığı tamamlamadığımda ve yeni güne geçildiğinde serimin sıfırlandığını görmeliyim. | 🔴 Kritik |
| US-603 | Kullanıcı olarak, alışkanlıklarımı haftada 1 kez seri bozulmadan "Es Geç"ebilmeliyim. | 🟠 Yüksek |
| US-604 | Kullanıcı olarak, streak rozetinin üzerine dokunduğumda "En uzun serin: X gün" bilgisini okuyabilmeliyim. | 🟡 Orta |

### Teknik Görevler

- [ ] `StreakService` oluşturulması veya mevcut altyapının yeni `%100 completion` mantığına göre uyarlanması.
- [ ] Gün atlandığında (gece yarısı kontrolü veya uygulama açılış kontrolü) serinin sıfırlanması mantığının kodlanması.
- [ ] `HabitCard` üzerinde haftada 1 kullanılabilecek "Es Geç" butonunun aktif edilmesi. `streaks` tablosundaki `skip_used_this_week` durumunun güncellenmesi.
- [ ] Streak rozetine dokunulduğunda "En uzun serin: X gün" bilgisinin `Tooltip` veya küçük `Dialog` ile gösterilmesi.

### Kabul Kriterleri

- [ ] %100 olan alışkanlıkların serisi veritabanında artar ve UI'a yansır.
- [ ] Es Geç (Skip) kullanıldığında seri aynı kalır, buton o hafta için pasifleşir.
- [ ] Gece yarısını geçen tamamlanmamış alışkanlıkların serisi 0'a iner.

---

## 🚀 Sprint 7 — Onboarding, Profil, Bildirimler & MVP Çıkışı

**Hedef:** İlk açılış deneyimi, profil istatistikleri, lokal bildirimler ve uygulamanın tüm cihazlarda hatasız çalıştığının test edilmesi.

### Kullanıcı Hikayeleri

| ID | Hikaye | Öncelik |
|----|--------|---------|
| US-701 | Kullanıcı olarak, uygulamayı ilk açtığımda popüler alışkanlıkları tek tıkla listeme ekleyebilmeliyim. | 🟠 Yüksek |
| US-702 | Kullanıcı olarak, profil ekranımda toplam tamamlanan görev sayımı ve ilerlememi görebilmeliyim. | 🟠 Yüksek |
| US-703 | Kullanıcı olarak, belirlediğim saatli etkinliklerden (Event) önce cihazımda bildirim almalıyım. | 🔴 Kritik |
| US-704 | Kullanıcı olarak, her gün 21:00'de o gün tamamlamadığım alışkanlıklarımın sayısını içeren bir özet bildirim almalıyım. | 🟠 Yüksek |

### Teknik Görevler

- [ ] `OnboardingScreen` kodlanması ve default alışkanlıkların `SharedPreferences` ile entegrasyonu (Sadece ilk açılışta gösterilir).
- [ ] `ProfileScreen`'in V1 için tamamlanması (Toplam aktif alışkanlık, en uzun seri, bugünkü tamamlama `%` barı).
- [ ] `flutter_local_notifications` kurulumu ve `zonedSchedule` ile saatli Event bildirimlerinin ayarlanması.
- [ ] Akşam 21:00 özet bildirimi için local background task yapılandırması (Eksik alışkanlık sayısı sorgusu).
- [ ] iOS/Android küçük ekranlarda (Örn: iPhone SE 375px genişlik) UI testlerinin yapılması ve QA bug-fix.
- [ ] `README.md` ve kurulum dokümanlarının güncellenmesi.

### Kabul Kriterleri

- [ ] Uygulama temiz kurulup ilk kez açıldığında boş sayfa göstermez, öneriler sunar.
- [ ] Zamanı gelen Event bildirimi cihaz kilitliyken veya uygulama arkadayken de gösterilir.
- [ ] Tüm akış (Ekle -> Listele -> İlerle -> Sil) çökmeksizin test edilir ve MVP "Definition of Done" statüsüne ulaşır.

---

## 📊 V1 - MVP Definition of Done

Aşağıdaki tüm koşullar sağlandığında uygulamanın Local Çalışan MVP sürümü tamamlanmış sayılır:

| Kriter | Durum |
|--------|-------|
| `flutter run` ile local'de çalışır (iOS/Android) | ⬜ |
| Event, Habit, Todo tipleri eklenebilir / düzenlenebilir / silinebilir | ⬜ |
| Kötü alışkanlık kodları tamamen silinmiştir | ⬜ |
| Alışkanlık takibi %0-100 progress sistemi ile çalışır | ⬜ |
| Yapılacaklar (Todo) listesi çoklu filtrelemeyle hatasız çalışır | ⬜ |
| Uzun basma ile "Düzenle/Sil" akışı çalışır | ⬜ |
| Streak motoru ve Es geçme hakkı sistemi hatasız hesaplar | ⬜ |
| İlk açılış onboarding ekranı ve default veriler görünür | ⬜ |
| Saatli etkinlik bildirimi belirlenen saatte tetiklenir | ⬜ |
| Veriler uygulama restart edildiğinde korunur (SQLite) | ⬜ |
| iPhone SE (375px) boyutunda UI taşması yoktur | ⬜ |

---

## 🔮 V2+ — Gelecekte Eklenecek Özellikler

> Firebase entegrasyonları, Google/Apple Takvim senkronizasyonları, Arkadaş listeleri ve Ortak alışkanlık takibi gibi özellikler MVP çıkışından sonra planlanacaktır. V2 yol haritası `prd.md` içinde detaylandırılmıştır.
