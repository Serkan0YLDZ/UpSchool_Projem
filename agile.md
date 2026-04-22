# Flutter PDF Harcama Takibi (Offline) — Agile Plan (MVP)

Bu doküman, [prd.md](/Users/serkan/Github/UpSchool_Projem/prd.md) gereksinimlerine dayanarak MVP’yi sprint bazlı teslim edebilmek için hazırlanmış Agile planıdır.

## MVP varsayımları (kilit kararlar)

- **Platform**: Flutter (iOS/Android)
- **Belge formatı**: MVP’de **sadece PDF** (e-Fatura / e-Arşiv PDF)
- **AI/çıkarım**: **tamamen cihaz içi (offline)** (bulut yok)
- **Veri saklama**: **sadece cihaz içi DB + dosyalar** (backend yok)
- **Görüntü/kamera**: MVP sonrası faz

## Ürün kapsamı (MVP)

- PDF yükleme (dosya seçme)
- PDF görüntüleme (in-app)
- PDF’ten metin çıkarımı
  - Metin katmanı varsa doğrudan
  - Scan PDF ise sayfa render + on-device OCR
- Alan çıkarımı v1: **şirket/ünvan**, **tarih**, **toplam tutar** (opsiyonel: vergi no, belge no)
- Kullanıcı teyidi/düzenleme formu
- Listeleme + arama + filtreleme (şirket, tarih aralığı, tutar aralığı, belge tipi)
- Lokal veritabanı + dosya saklama

## Mimari yaklaşım (MVP)

- **UI**: Liste/filtre, detay, PDF ekle-akışı
- **Domain**: `Document`, `ExtractedFields`, `Filters` modelleri + use-case’ler
- **Data**:
  - Lokal DB (öneri: Drift(SQLite) veya Isar)
  - Dosya saklama (app documents directory / sandbox)
  - PDF görüntüleme/render
  - OCR adaptörü (iOS Vision / Android ML Kit) — Flutter paketi / platform kanal üzerinden
- **Offline-first ilkeleri**:
  - Hiçbir HTTP isteği yok
  - Arama/filtreleme tamamen lokal

## Veri modeli (öneri)

- `documents`
  - `id` (uuid)
  - `createdAt`
  - `sourceType` (MVP: `pdf`)
  - `documentType` (MVP: `eInvoicePdf`)
  - `filePath` (sandbox)
  - `vendorName`
  - `invoiceDate`
  - `totalAmount`
  - `currency` (varsayılan TRY)
  - `taxId` (nullable)
  - `documentNo` (nullable)
  - `rawExtractTextHash` / `rawExtractPreview` (opsiyonel; gizlilik/performans dengesi)

> Not: İleride görüntü geldiğinde `pageThumbnails`, `imageCaptureMeta` gibi alanlar eklenebilir.

## UI akışları (MVP)

- **Home/List**: arama kutusu + filtre butonu + belge kartları
- **Add PDF**: dosya seç → işleniyor → teyit/düzenle → kaydet
- **Detail**: alanlar + “PDF’yi aç”
- **Filters**: tarih/tutar aralığı, şirket, belge tipi

## Sprint planı (epikler → story’ler → kabul kriterleri)

### Sprint 0 (1 hafta) — Setup & spike’lar

Amaç: Teknik belirsizlikleri eritmek ve MVP’nin temel “işlenebilir” hattını ispatlamak.

- Proje iskeleti (Flutter), klasörleme, state management kararı
- Lokal DB seçimi spike (Drift vs Isar)
- PDF viewer + PDF render spike
- PDF metin katmanından text extract spike
- Scan PDF için OCR entegrasyonu spike

**Sprint 0 kabul kriterleri**
- iOS/Android’de sample PDF açılabiliyor
- Sample PDF’ten metin (varsa) çekilebiliyor
- Scan PDF’ten en az 1 sayfa OCR ile metin çıkarılabiliyor

### Sprint 1 (1–2 hafta) — Belge ekleme + saklama

Amaç: “PDF ekle → sakla → listede gör → aç” döngüsünü bitirmek.

- PDF import (dosya seçici) + sandbox’a kopyalama
- `documents` tablosu + CRUD
- “Ekle” akışı: seç → kaydet
- Detail ekranında PDF açma

**Sprint 1 kabul kriterleri**
- PDF eklenince listede görünür
- Uygulama kapanıp açılsa da kayıtlar durur
- Detaydan PDF görüntülenir

### Sprint 2 (1–2 hafta) — Çıkarım hattı + teyit/düzenleme

Amaç: PDF’ten alan çıkarımı + kullanıcı teyidiyle kayıt kalitesini güvenceye almak.

- Extract pipeline
  - Metin katmanı varsa text extract
  - Yoksa render + OCR
- Alan çıkarımı v1 (vendor/tarih/tutar)
- Teyit/düzenleme formu + kaydetme
- Hata durumları (çıkarılamadı → manuel giriş)

**Sprint 2 kabul kriterleri**
- Örnek e-Fatura PDF’lerinde vendor/tarih/tutar otomatik doluyor (başlangıç hedefi: en az %60 doğruluk)
- Kullanıcı alanları düzenleyip kaydedebiliyor

### Sprint 3 (1 hafta) — Arama/filtre + özet

Amaç: Kullanıcının veriye erişimini “bul, filtrele, özetle” seviyesine taşımak.

- Liste arama (vendor name)
- Filtre ekranı: tarih aralığı, tutar aralığı, belge tipi
- Filtrelenmiş toplam/özet gösterimi

**Sprint 3 kabul kriterleri**
- Filtreler doğru sonuç döndürür ve performanslıdır
- Özet metrikleri filtreye göre güncellenir

### Sprint 4 (1 hafta) — Kalite, performans, yayın hazırlığı

Amaç: MVP’yi stabil hale getirip yayınlanabilir kaliteye getirmek.

- Performans optimizasyonu (render/OCR süreleri, caching)
- Veri bütünlüğü, dosya silme/temizlik politikaları
- UI polish (referans tasarıma yaklaşım)
- E2E senaryolar (manuel test checklist)

**Sprint 4 kabul kriterleri**
- Ortalama PDF ekleme→çıkarım→kayıt akışı kabul edilebilir sürede (hedef: <10–15 sn, cihaz/PDF’e bağlı)
- Çökme yok; hatalar kullanıcıya anlaşılır

## MVP exit criteria (yayınlama için minimumlar)

- Offline modda uçtan uca akışlar çalışıyor (uçak modunda)
- PDF import + görüntüleme sorunsuz
- En az 20 farklı PDF ile regresyon kontrolü yapıldı (metin + scan karışık)
- Kritik hatalar (crash, veri kaybı, bozuk dosya) kapatıldı

## Backlog (MVP sonrası)

- Kamera ile fiş çekme + galeri görüntüsü (jpg/png)
- Belge tipi otomatik sınıflandırma (market fişi, e-fatura, vb.)
- Gelişmiş alan çıkarımı (kalemler, KDV, kalem bazlı analiz)
- Export/Paylaş (CSV/PDF)
- Opt-in bulut fallback (sadece açık rıza ile)

## Riskler ve mitigasyon

- **Scan PDF’lerde OCR doğruluğu değişken**
  - Mitigasyon: manuel teyit, extractor iterasyonu, örnek doküman seti
- **PDF ekosistemi çeşitliliği (encoding/metin katmanı)**
  - Mitigasyon: iki aşamalı pipeline (text→OCR fallback), çoklu test dokümanları
- **Performans (özellikle OCR)**
  - Mitigasyon: sayfa sayısı limitleri, arka planda işleme, progress UI

## Test planı (özet)

- Örnek doküman seti: 10+ farklı e-Fatura PDF (metin), 10+ scan PDF
- Senaryolar: ekle→çıkar→düzelt→kaydet→filtrele→görüntüle
- Offline test: uçak modunda tüm akışlar

