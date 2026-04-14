# Ürün Gereksinim Dokümanı (PRD)
**Ürün:** Akıllı Fiş Okuyucu ve Bütçe Yöneticisi
**Belge Sürümü:** 1.0 (MVP)
**Rol:** Kıdemli Mobil Ürün Yöneticisi & Sistem Mimarı

---

## 1. Yönetici Özeti (Executive Summary)

**Vizyon:** Kullanıcıların kişisel finansal verilerini üçüncü taraf sunuculara veya bulut hizmetlerine emanet etme endişesi duymadan, harcamalarını zahmetsizce takip edebilmelerini sağlamak.

**Problem:** Pazardaki mevcut bütçe takip uygulamaları ya manuel giriş gerektirerek ciddi bir kullanıcı eforu talep ediyor ya da OCR/Kategorizasyon işlemleri için fiş görüntülerini bulut sunucularına göndererek ciddi gizlilik endişeleri yaratıyor. 

**Çözüm:** "%100 Gizlilik ve Çevrimdışı Çalışma" prensibiyle tasarlanmış bu mobil uygulama, cihaz içi (on-device) OCR teknolojilerini (Apple Vision & Google ML Kit) kullanarak fişleri saniyeler içinde okur. Sunucu bağımlılığı olmadan, yerel makine gücü ve Regex/Kelime Eşleştirme algoritmalarıyla verileri kategorize eder ve tamamen lokal bir veritabanında saklar.

---

## 2. Hedef Kitle ve Kullanıcı Personaları

**Persona 1: "Gizlilik Odaklı" Görkem (32, Yazılım Geliştirici)**
* **Motivasyon:** Kişisel verilerinin şirketler tarafından profillenmesinden ve satılmasından nefret eder. Finansal verilerinin kendi cihazından dışarı çıkmasını kesinlikle istemez.
* **Acı Noktası (Pain Point):** Pazardaki iyi uygulamaların hepsi üyelik ve bulut senkronizasyonu dayatıyor.
* **Beklentisi:** Ağ bağlantısı kapalıyken bile çalışabilen, şeffaf ve hızlı bir araç.

**Persona 2: "Bütçe Disiplinli" Ayşe (28, Bankacı/Finans Uzmanı)**
* **Motivasyon:** Aylık bütçesini kuruşu kuruşuna takip etmek ister. Mutfak, ulaşım, eğlence harcamalarını net olarak görmek onun için önemlidir.
* **Acı Noktası (Pain Point):** Her akşam market veya kafe fişlerini Excel'e girmek çok zamanını alıyor. Sık sık unutuyor veya üşeniyor.
* **Beklentisi:** Fişi okutur okutmaz tutarın ve kategorinin anında önüne gelmesi ve minimum eforla harcamasını kaydedebilmesi.

---

## 3. MVP Kapsamı (In-Scope)

İlk lansmanda yer alacak temel özellikler:
1.  **Yerel OCR Motoru Entegrasyonu:** iOS için `Apple Vision Framework`, Android için `Google ML Kit Text Recognition` kullanılarak cihaz üzerinde çevrimdışı metin çıkarma.
2.  **Akıllı Metin Ayrıştırma (Regex & Keyword):** OCR'dan gelen raw (ham) metinden Toplam Tutar, Tarih ve İşletme Adı gibi verileri Regex ile yakalama. İşletme veya ürün adlarındaki anahtar kelimelerle (Örn: "Migros", "Şok" -> Market) temel kategorizasyon.
3.  **Manuel Onay ve Düzenleme Arayüzü:** Yapısal olmayan fiş formatlarından kaynaklanabilecek OCR veya Regex hatalarına karşı, kullanıcıya veriyi kaydetmeden önce hızlıca düzenleme imkanı sunan teyit ekranı.
4.  **Cihaz İçi Dashboard (Gösterge Paneli):** Aylık harcama toplamını, gün bazlı grafiği ve kategori bazlı pasta grafiğini (Pie Chart) gösteren, SQLite/Realm tabanlı lokal raporlama.

---

## 4. Kapsam Dışı (Out of Scope / Gelecek Fazlar)

Aşağıdaki özellikler MVP lansmanında **kesinlikle yer almayacaktır**:
* Kullanıcı hesapları, login/register mekanizmaları.
* Bulut senkronizasyonu veya cihazlar arası veri transferi.
* Açık Bankacılık (Open Banking) veya banka API entegrasyonları.

**Gelecek Faz Planlaması:**
* **Faz 2 (Cloud LLM Entegrasyonu - Opt-In):** Kullanıcının *açık rızası* ile, ayrıştırılamayan karmaşık fiş metinlerinin anonimleştirilerek (isim, lokasyon silinerek) OpenAI/Anthropic gibi bir Cloud LLM'e sadece kategori tahmini için gönderilmesi.
* **Faz 3 (Local LLM Entegrasyonu):** Donanım kapasiteleri arttıkça, on-device SLM (Small Language Model - örn. Llama-3-8B-Instruct via MLC) entegrasyonu yapılarak, internet bağlantısı olmadan %100 gizlilikle gelişmiş yapay zeka kategorizasyonunun sağlanması.

---

## 5. Fonksiyonel Gereksinimler (Kullanıcı Hikayeleri)

### Epik 1: Kamera ve Görüntü Yakalama
* **Task 1.1:** Kullanıcı olarak, uygulamaya ilk girdiğimde kamera izinlerini yönetebilmek istiyorum, böylece sadece onay verdiğimde cihazımın kamerası kullanılsın.
* **Task 1.2:** Kullanıcı olarak, uygulama içinden net bir şekilde fotoğraf çekebilmek veya galeriden fotoğraf seçebilmek istiyorum, böylece elimdeki veya dijital olarak sakladığım fişleri işleyebileyim.
* **Task 1.3:** Kullanıcı olarak, çektiğim fotoğrafı kırpabilmek (crop) istiyorum, böylece arka plandaki gereksiz nesneleri çıkararak OCR doğruluğunu artırabileyim.

### Epik 2: Cihaz İçi OCR ve Veri Ayrıştırma (Regex Engine)
* **Task 2.1:** Sistem Mimarı (Backend mantığı) olarak, görseldeki metni sadece cihazın işlemcisini kullanarak (ML Kit/Vision) çıkarmak istiyorum, böylece veriler asla internete gitmesin.
* **Task 2.2:** Kullanıcı olarak, tarama bittikten sonra OCR'ın "TOPLAM", "TUTAR", "KDV" gibi anahtar kelimeleri ve "DD/MM/YYYY" formatlarını Regex ile bularak ekrana getirmesini istiyorum, böylece manuel olarak fiyat veya tarih aramak zorunda kalmayayım.
* **Task 2.3:** Kullanıcı olarak, okunan işletme adının veya fiş satırlarının sistemdeki bir "Anahtar Kelime Sözlüğü" (JSON list) ile eşleşerek "Market", "Akaryakıt", "Restoran" gibi kategorilere otomatik atanmasını istiyorum, böylece kategorizasyonla uğraşmayayım.

### Epik 3: Teyit, Düzenleme ve Lokal Kayıt
* **Task 3.1:** Kullanıcı olarak, tarama sonrası karşıma gelen formda (Tutar, Tarih, Kategori, Not) değişiklik yapabilmek istiyorum, böylece Regex algoritmasının yanıldığı durumlarda veriyi anında düzeltebileyim.
* **Task 3.2:** Kullanıcı olarak, işlemi "Kaydet" butonuna bastığımda verilerin sadece cihazımın yerel veritabanına yazılmasını istiyorum, böylece veri gizliliğim %100 sağlansın.

### Epik 4: Bütçe Takibi ve Dashboard
* **Task 4.1:** Kullanıcı olarak, ana ekranda (Dashboard) içinde bulunduğum ayın toplam harcamasını büyük puntolarla görebilmek istiyorum, böylece aylık durumumu bir bakışta anlayabileyim.
* **Task 4.2:** Kullanıcı olarak, harcamalarımı kategori bazlı pasta grafiği (Pie chart) şeklinde görebilmek istiyorum, böylece paramın en çok nereye gittiğini analiz edebileyim.
* **Task 4.3:** Kullanıcı olarak, geçmiş harcamalarımı bir liste halinde görebilmek ve üzerlerine tıklayarak silebilmek/düzenleyebilmek istiyorum, böylece hata yaparsam geçmiş kayıtları yönetebileyim.

---

## 6. Fonksiyonel Olmayan Gereksinimler (NFRs)

1.  **Gizlilik ve Güvenlik (Privacy First):** * Uygulama hiçbir şekilde dışarıya (internet) HTTP isteği yapmamalıdır (App Store/Google Play in-app güncellemeleri hariç). Analytics veya Crashlytics dahi MVP'de kapalı tutulacak veya tamamen opt-in olacaktır.
2.  **Performans (Hız):** * Kamera deklanşörüne basıldığı andan itibaren OCR işlemi ve Regex ayrıştırması modern cihazlarda **maksimum 2.5 saniye** içinde tamamlanıp Düzenleme ekranına geçmelidir.
3.  **Pil ve Depolama Optimizasyonu:**
    * Tarama işlemi sırasında işlemci yoğun kullanılacağı için, OCR modülü sadece fotoğraf çekildiğinde aktif edilmeli, sürekli video stream üzerinden OCR *yapılmamalıdır*.
    * Fiş fotoğrafları veri işlendikten sonra cihazda yer kaplamaması için (kullanıcı opsiyonel olarak "Fotoğrafları Sakla" demedikçe) **otomatik olarak silinmelidir**.
4.  **Hata Toleransı (Robustness):**
    * Fiş buruşuksa veya OCR hiçbir tutar (Regex match) bulamazsa, uygulama çökmemeli; "Tutar okunamadı, lütfen manuel giriniz" şeklinde zarif bir hata (graceful degradation) vermelidir.

---

## 7. MVP Kullanıcı Akışı (User Flow)

1.  **Uygulama Açılışı:** Splash Screen -> Doğrudan **Dashboard** ekranı (Login yok).
2.  **Eylem Başlatma:** Alt ortadaki belirgin, büyük `[ + ]` (Yeni Fiş Oku) FAB (Floating Action Button) butonuna tıklama.
3.  **Kamera View:** Kamera açılır (gerekirse izin istenir). Kullanıcı fişi kadrajlar ve fotoğrafı çeker.
4.  **İşlem Bekleme:** Ekranda "Fişiniz güvenle, cihazınızda inceleniyor..." şeklinde kısa bir loading animasyonu çıkar.
5.  **Teyit ve Düzenleme Formu:** * **İşletme/Açıklama:** "Migros A.Ş." (Otomatik doldurulmuş)
    * **Kategori:** "Market" (Eşleşmeden gelmiş, dropdown ile değiştirilebilir)
    * **Tutar:** "₺450.50" (Regex ile bulunmuş, değiştirilebilir)
    * **Tarih:** "12/04/2026" (Regex ile bulunmuş, değiştirilebilir)
    * **Buton:** `[ ✓ Kaydet ]`
6.  **Sonuç:** Veri SQLite'a yazılır, kullanıcı "İşlem Başarılı" toast mesajı ile güncellenmiş grafikleri göreceği Dashboard ekranına geri yönlendirilir.

---

## 8. Başarı Kriterleri (Success Metrics)

MVP'nin pazarda geçerliliğini ve algoritmalarımızın sağlığını ölçmek için (kullanıcı anketleri ve mağaza yorumları üzerinden) takip edilecek 3 ana KPI:

* **KPI 1: OCR Regex Doğruluk Oranı (Hedef: >%75)**
    * Kullanıcıların taradıkları fişlerde "Toplam Tutar" bilgisinin, manuel bir düzeltmeye gerek kalmadan form ekranına doğru bir şekilde yansıma oranı.
* **KPI 2: Time-to-Record / Fiş Başına Harcanan Zaman (Hedef: < 10 Saniye)**
    * Kullanıcının uygulamayı açması, fotoğraf çekmesi, teyit ekranını onaylayıp işlemi bitirmesi arasında geçen ortalama süre. (Geleneksel manuel kayıt uygulamalarına karşı en büyük silahımız bu hızdır).
* **KPI 3: 1. Hafta Elde Tutma (W1 Retention Rate) (Hedef: >%40)**
    * Uygulamayı yükleyip ilk fişini okutan bir kullanıcının, sonraki 7 gün içinde uygulamaya dönüp en az bir fiş daha okutma/kaydetme oranı. Sistemin bir "alışkanlık" yaratıp yaratmadığının ana göstergesidir.
