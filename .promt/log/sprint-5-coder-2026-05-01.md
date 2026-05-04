# Sprint 5 — Kod Yazma Logu

**Tarih:** 2026-05-01
**Sprint:** Sprint 5 - Ana Sayfa UI Revizyonu & İlerleme Mekanizmaları

## Tamamlanan Görevler
- [x] Provider 0-100% logic: CompletionProvider ve Repository güncellendi. `targetProgress` ulaşıldığında status `done`, altındaysa `partial` logic işlendi → `lib/providers/completion_provider.dart` & `lib/data/repositories/completion_repository.dart`
- [x] Kart yapıları ayrıştırıldı: `TaskCard` silinerek yerine `EventCard` ve `TodoCard` bileşenleri kodlandı → `lib/screens/home/widgets/event_card.dart` & `lib/screens/home/widgets/todo_card.dart`
- [x] Alışkanlıklar bölümü güncellendi: `HabitCard` içerisindeki checkbox kaldırılarak `Slider` ve oran (%) göstergesi entegre edildi → `lib/screens/home/widgets/habit_card.dart`
- [x] Todo listesi filtrelemesi ana sayfada güncellendi ve Todo alanının başlığı sınırlarına eklendi → `lib/providers/record_provider.dart` & `lib/screens/home/home_screen.dart`
- [x] Uzun Basma (Long Press) mantığı genişletilerek Context Menu eklendi: Yeni `EventCard`, `TodoCard`, `HabitCard` bileşenlerinde `onLongPress` üzerinde modern bir `.showModalBottomSheet` eylemi çağrılarak `Düzenle / Sil` menüsü aktif hale getirildi → Kart dosyaları
- [x] Mevcut stub test altyapısı bu değişikliklere uyum sağlayacak şekilde düzeltildi ve testlerin geçmesi doğrulandı → `test/data/repositories/completion_repository_stub.dart`

## Yazılan/Düzenlenen Dosyalar
| Dosya | Satır Sayısı | Açıklama |
|---|---|---|
| lib/providers/completion_provider.dart | ~140 | targetProgress ile logic geliştirildi, markPartial, updateProgress metotları eklendi. |
| lib/data/repositories/completion_repository.dart | ~130 | partial update destekleyecek opsiyonel argüman eklendi. |
| lib/providers/record_provider.dart | ~150 | filter tipine "earliest" (yakın bitiş tarihi) açıklaması eklendi. |
| lib/screens/home/home_screen.dart | ~150 | Liste iterasyonlarında TodoCard ve EventCard ayrımları tanımlandı. |
| lib/screens/home/widgets/event_card.dart | ~150 | TaskCard temelinden üretilen saat aralığı gösterimli Event kartı. ModalContext Menu eklendi. |
| lib/screens/home/widgets/todo_card.dart | ~160 | TaskCard temelinden üretilen önceliğe duyarlı ToDo kartı. Bitiş tarihi alt başlığa formatlandı. ModalContext Menu eklendi. |
| lib/screens/home/widgets/habit_card.dart | ~170 | Done checkbox'ı yerini Slider ve Progress oranına bıraktı. ModalContext Menu eklendi. |
| test/data/repositories/completion_repository_stub.dart | ~50 | Stub metodları update edildi. |

## Yazılan Testler
| Test Dosyası | Test Sayısı | Kapsanan Kabul Kriteri |
|---|---|---|
| Mevcut Testler ve Stub | - | Projedeki testler refactor sonrası başarıyla passes oldu. (Yeni birim test Sprint sonlarına veya test sprintine dahil edilebilir.) |

## Tamamlanmayan / Bloker Görevler
- [ ] Düzenle akışı (`edit` butonu) tam dolu edit sayfasına veriyi yönlendirmesi henüz yapılmadı, `onTap` içi geçici boş bırakıldı. (Sonraki sprintin Onboarding/Edit akışıyla birleşebilir)

## Notlar
- `TaskCard`'ın yapısı yeni Event (`EventCard`) ve ToDo (`TodoCard`) modelleri ile verimli olmadığından (Single Responsibility Principal) iki ayrı bileşene bölünmesi tercih edildi. 
- Filtre menüsü sadece ToDo listesini ilgilendirdiği için, UI kararıyla sadece "Yapılacaklar" alanındaki `_SectionTitle` komponentinin yan hizasına taşındı.
- Kartlardaki `Slider` bileşeni hedefe yaklaştıkça (%100 `targetProgress`), State anlık progress'i alıp completion statüsünü default "done" hale sokabiliyor.