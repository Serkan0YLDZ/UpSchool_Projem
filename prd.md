# myNewHabit için Ürün Gereksinim Dokümanı (PRD) - MVP Versiyonu 1.0

## 1. Ürün Vizyonu ve Kapsamı
Bu uygulama, yeni alışkanlıklar edinmek, günlük işlerini organize etmek veya kötü alışkanlıklardan (bağımlılıklardan) kurtulmak isteyen kullanıcılar için tasarlanmış, sadelik ve estetiği ön planda tutan bir günlük yönetim aracıdır. MVP aşamasında, kullanıcıların hayatlarını organize etmeleri ve motivasyonlarını kaybetmeden gelişimlerini takip etmeleri hedeflenmektedir.

## 2. Temel Özellikler (MVP)

### 2.1. Ana Sayfa ve Takvim Yönetimi
* **7 Günlük Takvim Barı:** Ekranın en üstünde; *Dün, Bugün ve Gelecek 5 Gün* listelenir.
* **Varsayılan Görünüm:** Uygulama açıldığında "Bugün" seçili gelir. Günler arası geçiş tek dokunuşla yapılır.
* **Liste Hiyerarşisi:**
    * **Üst Bölüm:** Zamana bağlı (saatli) görevler kronolojik sırada listelenir.
    * **Orta Bölüm:** Zamana bağlı olmayan (rutin) alışkanlıklar önem sırasına göre listelenir.
    * **Alt Bölüm:** "Bırakılanlar" (Kötü alışkanlık/bağımlılık takibi - *Bugün de yapılmadı* onay kutuları).

### 2.2. Kayıt Tipleri ve Özellikleri
Kullanıcı bir kayıt oluştururken aşağıdaki **üç** ana türden birini seçer:

| Özellik | 1. Yeni Alışkanlık (Zamana Bağlı Olmayan) | 2. Takvime Ekle (Zamana Bağlı) | 3. Bırakma / Kötü Alışkanlık (Reverse Track) |
| :--- | :--- | :--- | :--- |
| **Zamanlama** | Gün içinde herhangi bir saat. | Belirli bir tarih ve saatte. | Zaman bağımsız (Eylemden kaçınma). |
| **Tekrar (Sıklık)** | Haftanın belirli günleri **veya** X günde bir. | Tek seferlik. | Sürekli aktif (Bozulana kadar). |
| **Önem Sırası** | Yüksek, Orta, Düşük. | Zaman önceliklidir. | Her zaman en yüksek öncelik. |
| **Başarı Kriteri** | Eylemi gerçekleştirmek ve işaretlemek. | Görevi vaktinde tamamlamak. | **Eylemi yapmamak** (Son ihlalden bu yana geçen gün sayacı). |

### 2.3. Akıllı Kayıt Ekleme ve İlk Katılım 
* Kullanıcı uygulamayı ilk açtığında boş ekran görmez. Ekranda *"Her gün 20 sayfa kitap oku"*, *"Günde 2 litre su iç"* gibi tek tıkla eklenebilecek varsayılan popüler alışkanlıklar sunulur.
* Kullanıcı detaylı ekleme yapmak istediğinde; "Saat ekle" seçilirse saat seçici açılır, "Tekrarla" seçilirse sıklık ayarları gelir. Ekran kalabalık görünmez.

### 2.4. Seri ve "Es Geçme" Mantığı
Alışkanlıkların sürdürülebilirliği için esnek bir takip sistemi kurulmuştur:
* **Seri Sistemi:** Bir alışkanlık üst üste yapıldığında ateş ikonu/sayacı artar (Örn: 🔥 14 Gün).
* **Es Geçme Hakkı:** Kullanıcılar hasta olabilir veya acil durumlar yaşayabilir. Kullanıcıya her alışkanlık için (örneğin haftada 1 kez) "Bugün Es Geç" butonu sunulur. 
* **Kötü Alışkanlık Sayacı:** "Bırakma" kayıtlarında sistem farklı çalışır. Hedef "1. Gün, 2. Gün" şeklinde yukarı saymaktır. Kullanıcı "Yaptım" butonuna basarsa sayaç sıfırlanır ve baştan başlar.

### 2.5. Bildirimler
* Zamana bağlı görevler için hatırlatıcılar.
* Gün sonunda eksik kalan alışkanlıklar için motivasyonel "Günü tamamla" uyarısı.

---

## 3. Teknik Gereksinimler ve Filtreleme Mantığı
Ana sayfadaki zamana bağlı olmayan kayıtlar için şu filtreleme opsiyonları bulunacaktır:
1.  En Önemli
2.  En Erken Bitmesi Gereken
3.  Bu ay, bu hafta veya bugün bitmesi gerekenler

### UX Notu
- Silme işlemleri, kullanıcıdan tam ekran ve önde kalan bir onay modalı ile onay alınarak yapılır. Modal, alt bar ve diğer UI öğelerinin önünde açılır.
---

## 4. Gelecekte Eklenecek Özellikler (V2 ve Sonrası)

* **Kapsamlı 'Ne Nasıl Yapılır?' Turu:** Uygulama büyüdüğünde, yeni gelen kullanıcılar için uygulamanın tüm özelliklerini öğreten interaktif bir ilk katılım turu.
* **Ana Ekran Widget'ları (iOS / Android):** Kullanıcıların uygulamayı açmadan, telefonlarının ana ekranından alışkanlıklarını "Tamamlandı" olarak işaretleyebilmesi ve güncel serilerini görebilmesi.
* **Kategorizasyon:** Alışkanlık ve görevleri "Sağlık", "İş", "Kişisel Gelişim" gibi etiketlerle (istediği renk kodları ile) ayırma ve bu etiketlere göre filtreleme.
* **Ortak Hedefler:** Arkadaşlarla gruplar kurarak bir alışkanlığı beraber kazanma veya bir bağımlılığı beraber bırakma (Örn: Arkadaşlar arası "30 Gün Şeker Kullanmama" meydan okuması ve ilerleme tablosu).
* **Daha İyi Sıralama:** Aynı önem seviyesindeki işleri sürükle bırak yöntemiyle manuel sıralama.
* **Gelişmiş Veri Analitiği:** Aylık ve yıllık detaylı başarı/gelişim raporları.
