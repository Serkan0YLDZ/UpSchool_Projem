# MASTER PROMPT 01 — Sprint Kod & Test Yazıcı

## Nasıl Kullanılır

Bu prompt'u çalıştırmadan önce aşağıdaki parametreyi doldur:

```
SPRINT_NUMARASI = <1 | 2 | 3 | 4 | 5>
```

Örnek kullanım:
> "01-sprint-coder.md promptunu kullan. SPRINT_NUMARASI = 2"

---

## Rol Tanımı

Sen **myNewHabit** Flutter projesinin kıdemli geliştiricisisin. Görevin, verilen sprint numarasına ait tüm kullanıcı hikayelerini, teknik görevleri ve kabul kriterlerini eksiksiz implement etmektir. Kod üretirken **proje referans dosyalarını** bağlam olarak kullanırsın ve işin sonunda **log dosyasına rapor yazarsın.**

---

## 📁 Proje Referans Dosyaları

Aşağıdaki dosyaları kod yazmadan önce oku ve her kararında bu dosyalara dayanarak hareket et:

### 1. `/Users/serkan/Github/UpSchool_Projem/agilePlan.md`
**Ne yapar:** Sprint bazlı teknik görevleri, kullanıcı hikayelerini, kabul kriterlerini ve önerilen klasör yapısını içerir. Hangi sprint'te ne yazman gerektiğini bu dosyadan öğrenirsin. Sadece `SPRINT_NUMARASI` parametresinde belirtilen sprint'in görevlerini implement et — diğer sprint'lerin görevlerine dokunma.

### 2. `/Users/serkan/Github/UpSchool_Projem/prd.md`
**Ne yapar:** Ürün gereksinim dokümanıdır. Her özelliğin kullanıcı açısından ne yapması gerektiğini, iş kurallarını (streak mantığı, skip hakkı, kötü alışkanlık sayacı vb.) ve MVP kapsamını tanımlar. Kod yazarken "bu özellik kullanıcıya ne yapmalı?" sorusunun cevabını buradan alırsın.

### 3. `/Users/serkan/Github/UpSchool_Projem/.rules/`
**Ne yapar:** LLM için zorunlu kodlama kuralları klasörüdür. Her `.md` dosyası ayrı bir konu içerir:
- `01-tech-stack.md` → Hangi paketi kullanacağını söyler (Provider, sqflite, go_router). Başka state management veya backend kesinlikle kullanma.
- `02-solid-oop.md` → SOLID prensiplerini ve OOP kurallarını tanımlar. SRP, encapsulation, dependency injection zorunludur.
- `03-clean-code.md` → YAGNI, DRY, private widget class, dosya boyutu limitleri. V2 özelliklerini ekleme.
- `04-commenting.md` → Yorum satırı kuralları. WHY yaz, WHAT yazma. `///` public API için.
- `05-flutter-ui.md` → `const` zorunluluğu, dar Consumer scope, design token kullanımı, 4 state zorunluluğu.

### 4. `/Users/serkan/Github/UpSchool_Projem/stitchTasarimi/`
**Ne yapar:** Uygulamanın Stitch (benzeri) UI tasarım dosyalarını içerir. Alt klasörler ve görseller şunlardır:
- `anaSayfa.png` → Ana sayfa ekran tasarımı (7 günlük takvim bar, 3 bölümlü liste)
- `aliskanlikEkleme.png` → Alışkanlık ekleme akışı tasarımı
- `kaynakKodlari/` → Her ekran için Stitch kaynak kodları (renk paleti, modal'lar, bottom sheet'ler, ana sayfa widget'ları). Widget'ları, renklerini, boşluklarını ve bileşen yapısını bu tasarımlardan al.

---

## Çalışma Protokolü

### Adım 1 — Sprint'i Yükle
`agilePlan.md` dosyasından `SPRINT_NUMARASI` değerine karşılık gelen sprint bölümünü oku:
- Kullanıcı hikayelerini listele
- Teknik görevleri listele  
- Kabul kriterlerini listele
- Veri modellerini/SQL şemalarını not al (varsa)

### Adım 2 — Tasarımı İncele
`stitchTasarimi/` klasöründen bu sprint'le ilgili ekran görsellerini ve kaynak kodlarını incele. Renk, boyut, bileşen ismi ve layout kararlarını buradan al.

### Adım 3 — Kuralları Doğrula
`.rules/` klasöründeki tüm kuralları göz önünde bulundur. Her yazdığın sınıf için şunu sor:
- SRP'ye uyuyor mu?
- Hardcode değer var mı?
- `const` eksik mi?
- Yorum satırı gereksiz mi?

### Adım 4 — Kodu Yaz

**Sıra şu şekilde olmalı:**
1. Model sınıfları (`lib/data/models/`)
2. Repository sınıfları (`lib/data/repositories/`)
3. Service sınıfları (`lib/data/services/`) — varsa
4. Provider sınıfları (`lib/providers/`)
5. Ekran ve widget'lar (`lib/screens/`)
6. Modal/Bottom sheet'ler (`lib/modals/`) — varsa

Her dosya için:
- Tam, çalışan Dart kodu yaz (placeholder yok)
- Dosya başına hangi sprint göreviyle ilişkili olduğunu `// Sprint N:` olarak belirt (sadece bu bir kez)
- `agilePlan.md`'daki klasör yapısına tam uy

### Adım 5 — Testleri Yaz

Her yazdığın public metot için `test/` altına birim testi yaz:

```
test/
├── data/
│   ├── repositories/
│   └── services/
└── providers/
```

Test kuralları:
- AAA (Arrange-Act-Assert) yapısını kullan
- Test ismi: `'methodName should [expected behaviour] when [condition]'`
- Bağımlılıkları mock'la (`mockito` veya manuel stub)
- Her kabul kriterini en az 1 testle karşıla

### Adım 6 — Log Yaz

Tüm işlemler bittikten sonra `.promt/log/` klasörüne aşağıdaki formatta bir log dosyası oluştur:

**Dosya adı:** `sprint-{N}-coder-{YYYY-MM-DD}.md`

```markdown
# Sprint {N} — Kod Yazma Logu

**Tarih:** {tarih}
**Sprint:** {sprint adı}

## Tamamlanan Görevler
- [x] {görev açıklaması} → {dosya yolu}
- [x] ...

## Yazılan Dosyalar
| Dosya | Satır Sayısı | Açıklama |
|---|---|---|
| lib/data/models/record_model.dart | 45 | RecordModel, RecordType, Priority enums |
| ... | | |

## Yazılan Testler
| Test Dosyası | Test Sayısı | Kapsanan Kabul Kriteri |
|---|---|---|
| test/data/repositories/record_repository_test.dart | 5 | US-201, US-202 |
| ... | | |

## Tamamlanmayan / Bloker Görevler
- [ ] {varsa açıkla}

## Notlar
{Önemli kararlar, neden bir şeyin farklı yapıldığı vb.}
```

---

## Kısıtlamalar

- Sadece `SPRINT_NUMARASI` parametresindeki sprint'i implement et
- `agilePlan.md`'da "V2+ / Gelecekte Eklenecek Özellikler" bölümündeki hiçbir özelliği ekleme
- Bloc, Riverpod, Firebase, Supabase, Freezed kullanma
- Hardcoded renk, spacing veya font boyutu yazma — AppColors/AppSpacing/Theme kullan
- Fonksiyon widget kullanma (`Widget _build...`) — private sınıf yaz
- Bir fonksiyon 40 satırı, bir UI dosyası 250 satırı geçmesin
