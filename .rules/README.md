# myNewHabit — LLM Kuralları (`/.rules`)

Bu klasördeki kurallar, **myNewHabit** Flutter projesinde kod üretirken yapay zekanın (LLM) uyması gereken standartları tanımlar. Her dosya belirli bir konuya odaklanır ve birbirini tamamlar.

---

## Kural Dosyaları

| Dosya | Konu | Özet |
|---|---|---|
| [01-tech-stack.md](./01-tech-stack.md) | Teknoloji Yığını & Proje Yapısı | Stack, klasör yapısı, isimlendirme kuralları, tasarım token'ları |
| [02-solid-oop.md](./02-solid-oop.md) | SOLID & OOP Prensipleri | SRP, OCP, LSP, ISP, DIP, kapsülleme, composition |
| [03-clean-code.md](./03-clean-code.md) | Temiz Kod & YAGNI | YAGNI, DRY, private widget sınıfları, boyut limitleri, enum kuralları |
| [04-commenting.md](./04-commenting.md) | Yorum Satırı Kuralları | Ne zaman yaz, ne zaman yazma, `///` vs `//`, stil tablosu |
| [05-flutter-ui.md](./05-flutter-ui.md) | Flutter & UI Performans | `const`, dar Consumer, ListView.builder, design system, animasyon |

---

## Hızlı Başvuru — En Kritik Kurallar

### ❌ Asla Yapma
- V2+ özelliklerini (Supabase, kategoriler, widget'lar, social) MVP'ye ekleme
- Widget içinde `DatabaseHelper` veya `sqflite` çağrısı yapma
- Hardcode renk, font büyüklüğü veya spacing değeri kullanma
- `Widget _buildSomething()` fonksiyon widget'ı yaz
- Kodu açıklayan (WHAT) yorum yaz — `print()` kullan

### ✅ Her Zaman Yap
- `const` constructor kullan — widget değişmiyorsa `const` şarttır
- `Consumer<T>` scope'unu dar tut — sadece değişen widget'ı sar
- Provider'daki state'i `private` tut, `get` ile aç
- State, loading, error ve empty — 4 durumu da handle et
- Enum'lar için `extension` ile bool getter yaz

---

## Referans Teknoloji Kararları

```
State Management : Provider (ChangeNotifier)   ← Bloc/Riverpod YASAK
Navigation       : go_router                    ← Navigator 1.0 YASAK
Database         : sqflite (local only)         ← Firebase/Supabase YASAK
Fonts            : google_fonts (Plus Jakarta Sans)
```
