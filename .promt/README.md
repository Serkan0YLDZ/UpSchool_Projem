# myNewHabit — Master Prompt Sistemi (`.promt/`)

Bu klasör, **myNewHabit** Flutter projesini geliştirirken LLM'lere verilen üç master prompt'u içerir.

---

## Master Prompt'lar

### `01-sprint-coder.md` — Sprint Kod & Test Yazıcı
**Parametre:** `SPRINT_NUMARASI = <1|2|3|4|5>`  
**Ne yapar:** Verilen sprint numarasına ait tüm teknik görevleri, modelleri, repository'leri, provider'ları, ekranları ve testleri sıfırdan yazar. `agilePlan.md`'daki kabul kriterlerini, `prd.md`'daki iş kurallarını ve `stitchTasarimi/` tasarımlarını bağlam olarak kullanır. Biter bitmez `log/` klasörüne rapor yazar.

**Nasıl çalıştırılır:**
> "01-sprint-coder.md promptunu kullan. SPRINT_NUMARASI = 1"

---

### `02-code-reviewer.md` — Kod Analiz & Test Çalıştırıcı
**Parametreler:**  
`HEDEF = <"sprint" | "dosya">`  
`SPRINT_NUMARASI = <1|2|3|4|5>` (HEDEF=sprint ise)  
`DOSYA_YOLU = <lib/...>` (HEDEF=dosya ise)  

**Ne yapar:** Yazılmış kodu tüm `.rules/` kuralları açısından statik analiz eder, test kapsamını değerlendirir, eksik testleri yazar ve `flutter test` çıktısını yorumlar. Kod değiştirmez — sadece raporlar ve onay ister.

**Nasıl çalıştırılır:**
> "02-code-reviewer.md promptunu kullan. HEDEF = sprint, SPRINT_NUMARASI = 2"  
> "02-code-reviewer.md promptunu kullan. HEDEF = dosya, DOSYA_YOLU = lib/providers/record_provider.dart"

---

### `03-bug-fixer.md` — Bug Analiz & Fix
**Parametreler:**  
`BUG_TANIMI = "<ne oluyor, ne olması gerekiyordu>"`  
`DOSYA_YOLU = <lib/...>` (opsiyonel)  
`HATA_MESAJI = "<stack trace>"`  (opsiyonel)  
`SPRINT = <1|2|3|4|5>` (opsiyonel)  

**Ne yapar:** Sprint bağımsızdır — istediğin zamanda çalıştırılabilir. Kök nedeni (root cause) bulur, minimal bir düzeltme planı hazırlar, onay aldıktan sonra fix'i uygular, regresyon testi yazar ve log'a kaydeder.

**Nasıl çalıştırılır:**
> "03-bug-fixer.md promptunu kullan. BUG_TANIMI = Streak tamamlama sonrası artmıyor. HATA_MESAJI = Expected 1 but got 0"

---

## Log Sistemi

Her prompt çalıştığında `log/` klasörüne bir rapor yazar. Bu loglar:
- Bir sonraki LLM'in projenin mevcut durumunu anlamasını sağlar
- Hangi dosyaların yazıldığını, hangi testlerin eklendiğini gösterir
- Bug fix geçmişini tutar

---

## Proje Referans Dosyaları (Tüm Prompt'larda Kullanılır)

| Dosya / Klasör | Konum | Açıklama |
|---|---|---|
| Agile Plan | `/agilePlan.md` | Sprint görevleri, kabul kriterleri, klasör yapısı |
| PRD | `/prd.md` | İş kuralları, kullanıcı hikayeleri, MVP kapsamı |
| Kurallar | `/.rules/` | SOLID, Clean Code, YAGNI, yorum, Flutter performans kuralları |
| Tasarım | `/stitchTasarimi/` | UI görselleri ve Stitch kaynak kodları |

---

## Önerilen Geliştirme Akışı

```
1. Sprint 1 → 01-sprint-coder.md (SPRINT_NUMARASI=1)
2. Sprint 1 bitince → 02-code-reviewer.md (HEDEF=sprint, SPRINT_NUMARASI=1)
3. Bulunan bug'lar için → 03-bug-fixer.md (BUG_TANIMI=...)
4. Sprint 2'ye geç → 01-sprint-coder.md (SPRINT_NUMARASI=2)
5. ...
```
