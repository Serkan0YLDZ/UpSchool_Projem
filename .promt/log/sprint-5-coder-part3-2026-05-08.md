# Sprint 5 — Kod Yazma Logu (Part 3)

**Tarih:** 2026-05-08
**Sprint:** Sprint 5 (Neo-Brutalism Akışı ve Veritabanı Genişletmesi)

## Tamamlanan Görevler
- [x] "Alışkanlık Ekle" akışındaki modallar arası geçiş yapısı (Adım 1 -> 2 -> 3) `while` döngüsü kullanılarak bir durum makinesi (state machine) ile baştan yazıldı. Geri dönme butonları tam fonksiyonel hale getirildi. → `lib/screens/shell/main_shell.dart`
- [x] İsim Verme Modalına (Adım 2) Neo-Brutalism tarzına uygun olarak "HEDEF" (Sayı) ve "BİRİM" (lt, km, sayfa vs.) giriş kutuları yan yana eklendi. → `lib/modals/naming_modal.dart`
- [x] İsim Verme Modalında alışkanlık adı boşken "DEVAM ET" butonu deaktif (gri) ve tıklanamaz hale getirildi. → `lib/modals/naming_modal.dart`
- [x] Hızlı öneri çiplerine tıklandığında Hedef ve Birim değerlerinin otomatik olarak dolması sağlandı (Örn: "Su İç" için 5 lt). → `lib/modals/naming_modal.dart`
- [x] "Alışkanlık Detayları" Modalının (Adım 3) başlığı sarı arka planlı, eğik ve siyah çerçeveli Neo-Brutalism tasarım diline uygun bir kutuya dönüştürüldü. → `lib/modals/habit_details_sheet.dart`
- [x] Alışkanlık kartındaki ilerleme çubuğu metninin içerisine yeni eklenen `target_unit` (birim) değeri entegre edildi ve "Done!" yazısıyla % göstergeleri kaldırılarak daha sade bir görünüm elde edildi. → `lib/screens/home/widgets/habit_card.dart`
- [x] SQLite veritabanı şeması Versiyon 5'e yükseltilerek `records` tablosuna `target_unit TEXT` kolonu eklendi (Migration işlemi yazıldı). → `lib/data/database/database_helper.dart`
- [x] `RecordModel` yapısına `targetUnit` özelliği eklendi ve JSON ayrıştırma (fromMap/toMap) fonksiyonları güncellendi. → `lib/data/models/record_model.dart`

## Yazılan/Düzenlenen Dosyalar
| Dosya | Açıklama |
|---|---|
| `lib/screens/shell/main_shell.dart` | `_openAddFlow` metodu modallar arası ileri-geri gidişi destekleyecek state machine loop'a dönüştürüldü. |
| `lib/modals/naming_modal.dart` | Geri tuşu dönüş değeri eklendi. Hedef Sayı ve Birim kutuları eklendi. Boş isim kontrolü ve Hızlı Öneri oto-doldurma entegre edildi. |
| `lib/modals/habit_details_sheet.dart` | Başlık konteynerı Neo-Brutalism stiliyle güncellendi, Geri dönme yeteneği kazandırıldı. |
| `lib/screens/home/widgets/habit_card.dart` | İlerleme yazısı (örn: 0 / 5 lt) olarak güncellendi, eski yüzde ve tamamlanma metinleri silindi. |
| `lib/data/database/database_helper.dart` | DB Version 5'e çekildi, `_migrateV5` eklendi (`target_unit`). |
| `lib/data/models/record_model.dart` | `targetUnit` String özelliği eklendi. |

## Yazılan Testler
| Test Dosyası | Test Sayısı | Kapsanan Kabul Kriteri |
|---|---|---|
| Yeni test yazılmadı | 0 | UI akışı ve DB Migration testleri manuel yapıldı. |

## Tamamlanmayan / Bloker Görevler
- [ ] Yok
