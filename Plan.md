# Plan.md — Kullanıcı Hikayelerine Bölünmüş Teknik Adımlar

> **Tek doğruluk kaynağı:** `PRD.md` — Bu dosya PRD'den türetilmiş, kullanıcı hikayesi odaklı uygulama yol haritasıdır.
> Teknik görev detayları için → `agilePlan.md`

---

## Vizyon & Hedef

Takvim etkinlikleri, tekrarlayan alışkanlıklar ve yapılacakları tek Flutter uygulamasında birleştiren günlük yönetim aracı.

| Sürüm | Odak | Durum |
|---|---|---|
| **v0.1** | Tam yerel, internetsiz, mock'suz; SQLite ile kalıcı veri | ✅ Tamamlandı |
| **v0.2** | Firebase Auth, çok cihazlı senkron, AI asistan, harici takvim, widget'lar, rozetler, sosyal | 🔜 Planlandı |

---

## v0.1 — Tamamlanan Kullanıcı Hikayeleri

### Epic E1 — Veri Modeli & Migrasyon

| Hikaye | Kabul Kriteri |
|---|---|
| Geliştirici olarak ayrı tablolarla şema oluşturabilmeliyim. | `calendar_events`, `habits`, `todos`, `habit_day_logs` tabloları + migration ✅ |
| Geliştirici olarak `habit_day_logs` ile planlı gün başına durum tutabilmeliyim. | CRUD + soft delete + `local_revision` ✅ |

### Epic E2 — Shell & Üçgen Navigasyon

| Hikaye | Kabul Kriteri |
|---|---|
| Üç mod ikonunu üçgenin köşeleri gibi görmek istiyorum (üçgen çizilmez). | `Stack` + `Positioned` köşe ikonu ✅ |
| Çift dokunuşla Takvim→Alışkanlık→Yapılacaklar döngüsü yapabilmeliyim. | `onDoubleTap` döngüsel geçiş ✅ |
| Uzun basışla mod seçici açabilmeliyim. | `FocusModePickerSheet` ✅ |
| Ekran okuyucuda anlamlı etiket duyabilmeliyim. | `Semantics` etiketleri ✅ |

### Epic E3 — Üç Mod Ekranı & Formlar

| Hikaye | Kabul Kriteri |
|---|---|
| Takvim etkinliği ekleyip seçili güne göre listeleyebilmeliyim. | Takvim çubuğu + günlük filtre ✅ |
| Alışkanlık eklerken ikon ve renk seçebilmeliyim. | 4 adımlı akış; `icon_key`, `icon_color_argb` ✅ |
| Haftalık veya N günde bir tekrar tanımlayabilmeliyim. | `schedule_kind`, `interval_days`, `weekly_days_mask` ✅ |
| Yapılacak ekleyip tamamlayabilmeliyim. | `is_completed` + `completed_at` ✅ |

### Epic E4 — Seri Motoru & Es Geç

| Hikaye | Kabul Kriteri |
|---|---|
| Planlı günlerde hedefe ulaştığımda seri sayısı artsın. | Full Replay streak hesabı; birim testi (10/12/14 senaryosu) ✅ |
| Haftada bir kez es geç ile seriyi koruyabilmeliyim. | `skip_source = free_weekly`; ISO hafta sayacı ✅ |
| Seri bittiğinde bunu arayüzde anlayabilmeliyim. | `series_state = closed`; UI gösterimi ✅ |

> ⚠️ **Şu an pasif:** Es geç UI butonu v0.1'de kaldırıldı. Backend (`habit_day_logs.skip_source`) hazır; v0.2'de tekrar bağlanacak.

### Epic E5 — Polish

| Hikaye | Kabul Kriteri |
|---|---|
| Profil ekranı geri kalan uygulamayla görsel olarak tutarlı olsun. | `AppTheme` token'larına bağlı ✅ |
| Boş listelerde emoji yerine ikon görebileyim. | `EmptyStateWidget` ikon + metin ✅ |
| Öncelik seçiminde gereksiz ikon görmeyeyim. | Renk şeridi / metin yeterli ✅ |
| "Yapılacakları Filtrele" başlığı ve seçili chip koyu gri olsun. | `neoStackFace` chip rengi ✅ |
| İlk açılışta kısa rehber görebileyim. | Onboarding + `SharedPreferences` bayrağı ✅ |
| Açılışta beyaz flaş yerine markalı görünüm görebileyim. | Native splash + tema dolgu ✅ |

---

## v0.2 — Planlanan Kullanıcı Hikayeleri

### Epic E6 — Firebase Auth

| Hikaye | Öncelik |
|---|---|
| Firebase ile oturum açıp kapatabilmeliyim (e-posta veya Google). | Yüksek |
| Profil ekranında oturum durumumu görebilmeliyim. | Orta |

### Epic E7 — Çok Cihazlı Senkron & Çakışma

| Hikaye | Öncelik |
|---|---|
| Çevrimdışı değişikliklerim bağlantı gelince buluta gitsin. | Yüksek |
| Çakışmada "yerel mi bulut mu?" seçeneği sunulsun. | Orta |

### Epic E8 — Harici Takvim

| Hikaye | Öncelik |
|---|---|
| Google/Apple/Outlook'tan etkinlik içe aktarabilmeliyim (pilot: bir kaynak). | Orta |

### Epic E9 — Ana Ekran Widget'ları

| Hikaye | Öncelik |
|---|---|
| Ana ekranda bugünün yapılacaklarını görebilmeliyim (iOS/Android widget). | Orta |
| Seri özetimi ana ekran widget'ında görebilmeliyim. | Düşük |

### Epic E10 — Rozetler

| Hikaye | Öncelik |
|---|---|
| İlk alışkanlığımı oluşturduğumda rozet kazanmalıyım. | Orta |
| 3/7 günlük seride rozet kazanmalıyım. | Orta |

### Epic E11 — Sosyal & Paylaşım

| Hikaye | Öncelik |
|---|---|
| Arkadaşlık isteği gönderip kabul edebilmeliyim. | Orta |
| Paylaşılan bir alışkanlık veya yapılacaklar listesi oluşturabilmeliyim. | Düşük |

### Epic E12 — AI Asistan ⭐ YENİ

| Hikaye | Öncelik |
|---|---|
| Giriş yapmış kullanıcı olarak AI sekmesine erişebilmeliyim. | Yüksek |
| Günlük planımı sabah/öğle/akşam bloklarıyla AI'dan alabilmeliyim. | Yüksek |
| Yeni alışkanlıklarım için AI hatırlatıcısı görmek istiyorum. | Yüksek |
| Takvimimdeki boş saatlerde öncelik sıralı yapılacak önerileri görmek istiyorum. | Orta |

**Teknik özet:**
- Servis: Google AI Studio / Gemini API
- Erişim: Giriş zorunlu (v0.2); abonelik v0.3'te eklenecek
- İkon: `Icons.auto_awesome_rounded`, renk: `neoStackFace` (#434D5E)
- Mimari: `ai_repository` → `ai_planner_service` → `AiAssistantScreen`

---

## Sürüm Geçiş Kriterleri

### v0.1 → v0.2 Geçişi İçin

- [x] Tüm FR-01…FR-10 kabul kriterleri karşılandı.
- [x] `flutter analyze` kritik uyarı yok.
- [x] Kritik kullanıcı akışları çevrimdışı test edildi.
- [x] `git tag v0.1` ve push.

### v0.2 Çıkış Kriterleri

- [ ] Firebase Auth (e-posta veya Google) uçtan uca.
- [ ] En az bir senkron senaryosu + çakışma UI demo testi.
- [ ] AI sekmesi giriş guard'ı + günlük plan çalışıyor.
- [ ] Harici takvim için en az bir platformda pilot.
