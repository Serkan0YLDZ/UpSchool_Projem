# Ürün Gereksinim Dokümanı (PRD)
**Ürün:** Akıllı Belge Okuyucu ve Harcama Takipçisi (Mobil)
**Belge Sürümü:** 1.1 (MVP - PDF odaklı)
**Rol:** Kıdemli Mobil Ürün Yöneticisi & Sistem Mimarı

---

## 1. Yönetici Özeti (Executive Summary)

**Vizyon:** Kullanıcıların harcamaya dair belgelerini (özellikle e-Fatura/e-Arşiv **PDF**) uygulamaya yükleyip; şirket, tarih ve tutar gibi bilgileri **tamamen cihaz içinde (offline)** otomatik çıkararak (AI/OCR + ayrıştırma) zahmetsizce takip edebilmelerini sağlamak.

**Problem:** Pazardaki mevcut bütçe takip uygulamaları ya manuel giriş gerektirerek ciddi bir kullanıcı eforu talep ediyor ya da OCR/Kategorizasyon işlemleri için fiş görüntülerini bulut sunucularına göndererek ciddi gizlilik endişeleri yaratıyor. 

**Çözüm:** "%100 Gizlilik ve Çevrimdışı Çalışma" prensibiyle tasarlanmış bu **Flutter** mobil uygulama, kullanıcının yüklediği PDF belgelerden metni çıkarır; gerekirse sayfayı görsele çevirip cihaz içi OCR çalıştırır. Sunucu bağımlılığı olmadan, yerel cihaz gücü + kural tabanlı ayrıştırma + (ileride) on-device modellerle, **Şirket/Ünvan**, **Toplam Tutar**, **Tarih**, **Belge Tipi** gibi alanları otomatik algılar ve verileri cihazdaki lokal veritabanında saklar.

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
1.  **Flutter Mobil Uygulama (Mobile-first UI):** Tasarım ve ekranlar mobil odaklı olacak. Görsel referanslarda paylaşılan “liste + arama + filtre” yaklaşımına benzer modern bir arayüz.
2.  **Belge Yükleme (MVP: PDF):** Kullanıcı cihazından PDF seçip uygulamaya ekleyebilir (e-Fatura / e-Arşiv gibi).
3.  **PDF’ten Veri Çıkarma (Offline):**
    * **Metin tabanlı PDF** ise: PDF içindeki metin katmanından metin çıkarımı.
    * **Tarama/scan PDF** ise: Sayfa render → cihaz içi OCR → metin çıkarımı.
4.  **Akıllı Ayrıştırma (Kural Tabanlı + Genişleyebilir):** Çıkarılan metinden **Şirket/Ünvan**, **Toplam Tutar**, **Tarih**, (varsa) **Vergi No**, **Belge No** gibi alanları pattern/keyword tabanlı ayrıştırma ile yakalama.
5.  **Manuel Onay ve Düzenleme Arayüzü:** Otomatik algılamanın hata payına karşı, kaydetmeden önce kullanıcı alanları hızlıca düzenleyebilir.
6.  **Belge Görüntüleme:** Kullanıcı yüklediği PDF’yi uygulama içinde açıp görüntüleyebilir.
7.  **Filtreleme ve Arama:** Kullanıcı yüklediği belgeleri/harcamaları; belge tipi (MVP: “e-Fatura PDF”), şirket adı, tarih aralığı ve tutar aralığına göre filtreleyebilir; anahtar kelimeyle arayabilir.
8.  **Lokal Veritabanı ve Dosya Saklama:** Meta veriler lokal DB’de; PDF dosyaları uygulama sandbox’ında saklanır (internet çıkışı olmadan). 

---

## 4. Kapsam Dışı (Out of Scope / Gelecek Fazlar)

Aşağıdaki özellikler MVP lansmanında **kesinlikle yer almayacaktır**:
* Kullanıcı hesapları, login/register mekanizmaları.
* Bulut senkronizasyonu veya cihazlar arası veri transferi.
* Açık Bankacılık (Open Banking) veya banka API entegrasyonları.
* Görüntü (jpg/png) yükleme ve kamera ile fiş fotoğrafı çekme (MVP sonrası).

**Gelecek Faz Planlaması:**
* **Faz 2 (Görüntü Desteği):** Kamera ile fotoğraf çekme + galeriden görüntü seçme (jpg/png) ve aynı offline çıkarım hattından geçirme.
* **Faz 3 (Gelişmiş On-Device AI):** Kural tabanlı ayrıştırmanın yanı sıra on-device sınıflandırma/NER yaklaşımları ile belge tipi tespiti, alan çıkarımı ve daha yüksek doğruluk.
* (Opsiyonel) **Faz X (Opt-in Bulut):** Sadece kullanıcı açık rızası ile, çözülemeyen belgeler için bulut fallback (MVP’de yok).

---

## 5. Fonksiyonel Gereksinimler (Kullanıcı Hikayeleri)

### Epik 1: Belge Ekleme (MVP: PDF)
* **Task 1.1:** Kullanıcı olarak, cihazımdan bir PDF seçip uygulamaya ekleyebilmek istiyorum, böylece e-Fatura/e-Arşiv belgelerimi kaydedebileyim.
* **Task 1.2:** Kullanıcı olarak, yüklediğim belgeye bir başlık/not ekleyebilmek istiyorum, böylece sonradan kolay bulabileyim.
* **Task 1.3:** Kullanıcı olarak, yükleme sırasında/sonrasında belgenin türünü (MVP: e-Fatura PDF) görebilmek istiyorum, böylece listemi filtreleyebileyim.

### Epik 2: PDF’ten Metin Çıkarma (Offline)
* **Task 2.1:** Sistem olarak, PDF metin katmanı varsa onu okuyup metni çıkarabilmeliyim, böylece hızlı ve doğru alan çıkarımı yapılabilsin.
* **Task 2.2:** Sistem olarak, PDF tarama/scan ise sayfayı render edip cihaz içi OCR ile metni çıkarabilmeliyim, böylece farklı PDF türleri desteklensin.
* **Task 2.3:** Sistem olarak, çıkarım sırasında hiçbir veri cihaz dışına çıkmamalı, böylece gizlilik korunmalı.

### Epik 3: Alan Çıkarma + Teyit/Düzenleme + Lokal Kayıt
* **Task 3.1:** Kullanıcı olarak, yükleme sonrası çıkan formda (Şirket, Tutar, Tarih, Belge No, Vergi No, Not) alanlarını düzenleyebilmek istiyorum, böylece otomatik algılamanın yanıldığı durumları düzeltebileyim.
* **Task 3.2:** Kullanıcı olarak, kaydet dediğimde hem meta verilerin hem de belgenin cihaz içi depolama + lokal DB’ye yazılmasını istiyorum, böylece çevrimdışı erişebileyim.
* **Task 3.3:** Kullanıcı olarak, daha önce yüklediğim belgeyi açıp PDF’yi görüntüleyebilmek istiyorum, böylece belgeyi tekrar kontrol edebileyim.

### Epik 4: Listeleme, Filtreleme ve Özet Ekranları
* **Task 4.1:** Kullanıcı olarak, belgelerimi/harcamalarımı bir liste halinde görebilmek istiyorum, böylece hızlıca gezineyim.
* **Task 4.2:** Kullanıcı olarak, şirket adına göre arama yapabilmek istiyorum, böylece belirli bir harcamayı bulayım.
* **Task 4.3:** Kullanıcı olarak, tarih aralığı ve tutar aralığına göre filtreleyebilmek istiyorum, böylece analiz yapabileyim.
* **Task 4.4:** Kullanıcı olarak, seçtiğim filtrelere göre toplam harcama tutarını ve temel özetleri görebilmek istiyorum, böylece period bazlı kontrol yapabileyim.

---

## 6. Fonksiyonel Olmayan Gereksinimler (NFRs)

1.  **Gizlilik ve Güvenlik (Privacy First):** * Uygulama hiçbir şekilde dışarıya (internet) HTTP isteği yapmamalıdır (App Store/Google Play in-app güncellemeleri hariç). Analytics veya Crashlytics dahi MVP'de kapalı tutulacak veya tamamen opt-in olacaktır.
2.  **Performans (Hız):** * Kamera deklanşörüne basıldığı andan itibaren OCR işlemi ve Regex ayrıştırması modern cihazlarda **maksimum 2.5 saniye** içinde tamamlanıp Düzenleme ekranına geçmelidir.
3.  **Pil ve Depolama Optimizasyonu:**
    * Tarama işlemi sırasında işlemci yoğun kullanılacağı için, OCR modülü sadece fotoğraf çekildiğinde aktif edilmeli, sürekli video stream üzerinden OCR *yapılmamalıdır*.
    * Fiş fotoğrafları veri işlendikten sonra cihazda yer kaplamaması için (kullanıcı opsiyonel olarak "Fotoğrafları Sakla" demedikçe) **otomatik olarak silinmelidir**.
4.  **Hata Toleransı (Robustness):**
    * Fiş buruşuksa veya OCR hiçbir tutar (Regex match) bulamazsa, uygulama çökmemeli; "Tutar okunamadı, lütfen manuel giriniz" şeklinde zarif bir hata (graceful degradation) vermelidir.
5.  **Offline-first:** PDF okuma, alan çıkarımı, listeleme/filtreleme ve görüntüleme internet olmadan çalışmalıdır.

---

## 7. MVP Kullanıcı Akışı (User Flow)

1.  **Uygulama Açılışı:** Splash Screen -> Doğrudan **Belge Listesi / Özet** ekranı (Login yok).
2.  **Eylem Başlatma:** Belirgin `[ + ]` (Yeni Belge Ekle) butonuna tıklama.
3.  **Dosya Seçimi:** Kullanıcı cihazdan bir **PDF** seçer.
4.  **İşlem Bekleme:** Ekranda "Belgeniz cihazınızda işleniyor..." şeklinde kısa bir loading animasyonu çıkar.
5.  **Teyit ve Düzenleme Formu:**
    * **Şirket/Ünvan:** (Otomatik doldurulmuş)
    * **Belge Tipi:** e-Fatura PDF (MVP)
    * **Tutar:** (Otomatik doldurulmuş, değiştirilebilir)
    * **Tarih:** (Otomatik doldurulmuş, değiştirilebilir)
    * (Opsiyonel) **Belge No / Vergi No / Not**
    * **Buton:** `[ ✓ Kaydet ]`
6.  **Sonuç:** Meta veri lokal DB’ye, PDF dosyası uygulama içi depolamaya yazılır. Kullanıcı listeye geri döner; yeni kaydı görür ve PDF’yi açabilir.

---

## 8. Başarı Kriterleri (Success Metrics)

MVP'nin pazarda geçerliliğini ve algoritmalarımızın sağlığını ölçmek için (kullanıcı anketleri ve mağaza yorumları üzerinden) takip edilecek 3 ana KPI:

* **KPI 1: OCR Regex Doğruluk Oranı (Hedef: >%75)**
    * Kullanıcıların taradıkları fişlerde "Toplam Tutar" bilgisinin, manuel bir düzeltmeye gerek kalmadan form ekranına doğru bir şekilde yansıma oranı.
* **KPI 2: Time-to-Record / Fiş Başına Harcanan Zaman (Hedef: < 10 Saniye)**
    * Kullanıcının uygulamayı açması, fotoğraf çekmesi, teyit ekranını onaylayıp işlemi bitirmesi arasında geçen ortalama süre. (Geleneksel manuel kayıt uygulamalarına karşı en büyük silahımız bu hızdır).
* **KPI 3: 1. Hafta Elde Tutma (W1 Retention Rate) (Hedef: >%40)**
    * Uygulamayı yükleyip ilk fişini okutan bir kullanıcının, sonraki 7 gün içinde uygulamaya dönüp en az bir fiş daha okutma/kaydetme oranı. Sistemin bir "alışkanlık" yaratıp yaratmadığının ana göstergesidir.

---

## 9. Teknik Varsayımlar ve Notlar (MVP)

* **Platform:** Flutter (iOS/Android).
* **Çalışma modu:** Tamamen cihaz içi / offline-first.
* **Belge formatı:** MVP’de PDF (e-Fatura/e-Arşiv PDF). Görüntü (kamera/galeri) MVP sonrası.
* **Veri saklama:** Lokal veritabanı + dosyalar uygulama sandbox’ında (sunucu yok).
