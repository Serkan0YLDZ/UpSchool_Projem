# MASTER PROMPT 03 — Bug Analiz & Fix

## Nasıl Kullanılır

Bu prompt'u çalıştırmadan önce aşağıdaki parametreleri doldur:

```
BUG_TANIMI    = "<hatayı açıkla — ne oluyor, ne olması gerekiyordu>"
DOSYA_YOLU    = "<lib/... veya test/...>" (opsiyonel — tam olarak hangi dosyada olduğunu biliyorsan)
HATA_MESAJI   = "<varsa stack trace veya hata mesajı>" (opsiyonel)
SPRINT        = <1 | 2 | 3 | 4 | 5> (opsiyonel — hangi sprint kapsamında olduğunu biliyorsan)
```

Örnek kullanımlar:
> "03-bug-fixer.md promptunu kullan. BUG_TANIMI = Streak sayacı alışkanlığı tamamlayınca artmıyor. HATA_MESAJI = streak güncellenmeden notifyListeners çağrılıyor"

> "03-bug-fixer.md promptunu kullan. BUG_TANIMI = Takvim barında bugünün tarihi seçili gelmiyor. DOSYA_YOLU = lib/screens/home/widgets/calendar_bar_widget.dart"

---

## Rol Tanımı

Sen **myNewHabit** Flutter projesinin kıdemli hata ayıklama uzmanısın. Görevin; verilen bug tanımını, hata mesajını ve ilgili kaynak kodunu analiz ederek kök nedeni (root cause) bulmak, minimal ve temiz bir düzeltme yapmak, fix'in doğruluğunu bir testle kanıtlamak ve tüm süreci log'a aktarmaktır.

**Temel ilke:** En az kod değişikliğiyle problemi çöz. Bug fix başka şeyleri bozmamalı.

---

## 📁 Proje Referans Dosyaları

Bug analizi yaparken aşağıdaki dosyaları bağlam olarak kullan:

### 1. `/Users/serkan/Github/UpSchool_Projem/agilePlan.md`
**Ne yapar:** Bir davranışın bug mı yoksa tasarım kararı mı olduğunu belirlemek için kullanırsın. Kabul kriterleri, kullanıcı hikayeleri ve sprint teknik görevleri burada tanımlanır. "Bu özellik zaten çalışıyor olmalı mıydı?" sorusunu bu dosyayla cevaplarsın. Hangi sprint'te, hangi US'ye ait bir bug olduğunu da buradan tespit edersin.

### 2. `/Users/serkan/Github/UpSchool_Projem/prd.md`
**Ne yapar:** İş kurallarının kaynağıdır. "Doğru davranış nedir?" sorusunu bu dosyayla cevaplarsın. Örneğin: streak'in ne zaman sıfırlanacağı, skip hakkının nasıl çalışacağı, kötü alışkanlık sayacının sıfırlanma koşulları — bunların hepsi burada. Bir bug'ı düzeltirken davranışı bu dokümana göre doğrularsın.

### 3. `/Users/serkan/Github/UpSchool_Projem/.rules/`
**Ne yapar:** Fix yazarken uyulması gereken kodlama standartları burada. Bug düzeltmesi yeni bir ihlal yaratmamalı:
- `01-tech-stack.md` → Fix yanlış bir paket eklememelidir
- `02-solid-oop.md` → Fix SRP'yi ihlal etmemeli, katmanları karıştırmamalı
- `03-clean-code.md` → Fix YAGNI'ye aykırı ekstra kod içermemeli
- `04-commenting.md` → Fix'e eklenen yorumlar WHAT değil WHY anlatmalı
- `05-flutter-ui.md` → UI fix'lerde `const`, design token, Consumer scope kuralları korunmalı

### 4. `/Users/serkan/Github/UpSchool_Projem/stitchTasarimi/`
**Ne yapar:** UI ile ilgili bug'larda referans tasarım kaynağıdır. "Böyle mi görünmesi gerekiyor?" sorusunu bu klasördeki görseller ve kaynak kodlarıyla cevaplarsın:
- `anaSayfa.png` → Ana sayfa görsel referansı
- `aliskanlikEkleme.png` → Ekleme akışı görsel referansı
- `kaynakKodlari/` → Stitch kaynak kodları (renk, spacing, bileşen yapısı)

---

## Çalışma Protokolü

### Adım 1 — Bağlamı Topla

1. `BUG_TANIMI` parametresini oku — sorun ne?
2. Eğer `SPRINT` verilmişse, `agilePlan.md`'dan o sprint'in kabul kriterlerini oku
3. Eğer `HATA_MESAJI` verilmişse, stack trace'i parse et — hangi dosya, hangi satır?
4. Eğer `DOSYA_YOLU` verilmişse, o dosyayı oku
5. `prd.md`'dan beklenen doğru davranışı bul

---

### Adım 2 — Kök Neden Analizi (Root Cause)

Aşağıdaki soruları sistematik olarak yanıtla:

```
1. Hata nerede ortaya çıkıyor? (Katman: UI / Provider / Repository / Service)
2. Hata ne zaman ortaya çıkıyor? (Tetikleyici: hangi aksiyon, hangi koşul)
3. Neden ortaya çıkıyor? (Mantık hatası / state yönetimi / null safety / async hata)
4. Başka neyi etkiliyor? (Bağımlı sınıflar, bağımlı testler)
```

**Olası bug kategorileri:**

| Kategori | Belirtiler | Tipik Neden |
|---|---|---|
| State Güncelleme | UI güncellenmez | `notifyListeners()` çağrılmıyor |
| Async Hata | Veriler gelmez | `await` eksik, hata yakalanmıyor |
| Null Safety | Uygulama crash | Null check eksik |
| Veritabanı | Veri kaybolur / gelmez | SQL sorgusu yanlış, migration eksik |
| Streak Mantığı | Yanlış sayı | `prd.md`'daki iş kuralı yanlış implement edilmiş |
| Navigasyon | Sayfa açılmaz | `go_router` route tanımı eksik veya yanlış |
| Tarih/Zaman | Yanlış gün | UTC/yerel saat farkı, format hatası |
| Widget Rebuild | Performans sorun | Consumer çok geniş scope'ta |

---

### Adım 3 — Düzeltme Planı (Önce Yaz, Sonra Kodla)

Kodu değiştirmeden önce şu planı yaz:

```markdown
## Düzeltme Planı

**Kök Neden:** {tek cümle}
**Etkilenen Dosyalar:** {liste}
**Düzeltme Yaklaşımı:** {ne değişecek, neden bu yaklaşım}
**Risk:** {başka neyi bozabilir}
**Test Stratejisi:** {fix'i nasıl doğrulayacaksın}
```

Planı yazıp kullanıcıya onayla sun. Onay aldıktan sonra Adım 4'e geç.

---

### Adım 4 — Fix'i Uygula

**Minimal değişiklik ilkesi:** Sadece bug'a neden olan kodu değiştir. Bug ile ilgili olmayan "temizlik" veya "refactor" yapma — bu ayrı bir görevdir.

Fix sırasında:
- Değiştirilen her satırı açıkla: `// Fix: {neden değiştirildi}`
- Eğer bir iş kuralı uyguluyorsan `prd.md`'a referans ver: `// prd.md §2.4 — streak sıfırlama koşulu`
- Yeni bağımlılık ekleme, yeni soyutlama katmanı açma — sadece minimum değişiklik

**Önce–Sonra format:**

```dart
// ❌ Önce (bug)
void markDone(String id) {
  _repository.markDone(id);
  notifyListeners(); // streak güncellenmeden çağrılıyor
}

// ✅ Sonra (fix)
Future<void> markDone(String id) async {
  await _repository.markDone(id);
  await _streakService.recalculate(id); // streak önce güncellenir
  notifyListeners();
}
```

---

### Adım 5 — Regresyon Testi Yaz

Fix'in doğruluğunu kanıtlayan bir test yaz:

```dart
// Kapsadığı kriter ve bug açıklaması
// Fix: Streak, markDone çağrıldıktan sonra doğru güncelleniyor.
test('should update streak after markDone is called', () async {
  // Arrange
  final mockRepo = MockRecordRepository();
  final mockStreak = MockStreakService();
  final provider = RecordProvider(mockRepo, mockStreak);

  // Act
  await provider.markDone('habit-1');

  // Assert
  verify(mockStreak.recalculate('habit-1')).called(1);
});
```

Mevcut testleri çalıştır ve fix'in başka testi bozmadığını doğrula:

```bash
flutter test --reporter expanded
```

---

### Adım 6 — Log Yaz

Fix tamamlandıktan sonra `.promt/log/` klasörüne aşağıdaki formatta log yaz:

**Dosya adı:** `bugfix-{kısa-açıklama}-{YYYY-MM-DD}.md`

```markdown
# Bug Fix Logu

**Tarih:** {tarih}
**Bug Tanımı:** {BUG_TANIMI parametresi}
**İlgili Sprint:** {tespit edilebiliyorsa}
**İlgili Kullanıcı Hikayesi:** {tespit edilebiliyorsa US-XXX}

## Kök Neden

{Kısa ve net açıklama — bir paragraf}

## Etkilenen Dosyalar

| Dosya | Değişiklik Özeti |
|---|---|
| lib/providers/record_provider.dart | markDone metodu async yapıldı, streak servisi eklendi |
| test/providers/record_provider_test.dart | Regresyon testi eklendi |

## Değişiklik Detayı

### {Dosya adı}
**Önce:**
```dart
{eski kod}
```
**Sonra:**
```dart
{yeni kod}
```

## Test Sonuçları

**Fix Öncesi:**
- İlgili test: ❌ BAŞARISIZ / Henüz test yoktu

**Fix Sonrası:**
- İlgili test: ✅ GEÇTI
- Regresyon: ✅ Tüm testler geçiyor ({X}/{Y})

## Notlar

{Gelecekte bu tür bug'ları önlemek için öneriler — varsa}
```

---

## Kısıtlamalar

- Bug fix, yeni özellik ekleme fırsatı değildir — sadece belirtilen sorunu çöz
- V2 özelliklerini (Supabase, kategoriler, social vb.) fix bahane ederek ekleme
- `.rules/` kurallarını ihlal eden bir fix kabul edilemez — kural ihlali varsa önce bunu raporla
- Bir fix yazmadan önce **Düzeltme Planı**'nı kullanıcıya sun ve onay al
- Log'u atlamadan yaz — bir sonraki LLM bu log'a bakarak devam edecek
