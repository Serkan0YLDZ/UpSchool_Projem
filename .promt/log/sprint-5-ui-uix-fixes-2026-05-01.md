# Sprint 5 — UI/UX Hatalarının Düzeltilmesi & Yeni Todo Form Logu

**Tarih:** 2026-05-01
**Sprint:** Sprint 5 - Ana Sayfa UI Revizyonu & İlerleme Mekanizmaları (Part 2 - UI/UX Fixes)

## Tamamlanan Görevler
- [x] **Bottom Sheet Overlay Fix:** Kartlardaki "Düzenle / Sil" context menu'leri Navigation Bar'ın altında kalma sorunu `useRootNavigator: true` parametresi eklenerek çözüldü → `EventCard`, `TodoCard`, `HabitCard` dosyalarında `_showContextMenu` metodları güncellendi.
- [x] **Alışkanlık (Habit) Form Sadeleştirilmesi:** Gereksiz "Önem Derecesi" seçimi `showHabitDetailsSheet`'ten tamamen kaldırıldı. Artık sadece tekrar günleri seçimi içermektedir → `lib/modals/habit_details_sheet.dart`
- [x] **Yapılacaklar (Todo) Detay Formunun Oluşturulması:** Yeni `showTodoDetailsSheet` modalı oluşturuldu. İçerisinde "Önem Derecesi" (High/Medium/Low) ve opsiyonel "Bitiş Tarihi" (Due Date) seçimi barındırmaktadır → `lib/modals/todo_details_sheet.dart` (yeni dosya)
- [x] **Todo Ekleme Akışının Bağlanması:** `main_shell.dart`'daki `_openDetailSheet` metodunda Todo kayıtları için yeni `showTodoDetailsSheet` form çağrılması entegre edildi.
- [x] **Todo Filtre Bölümünün Yenilenmesi:** Yan yana gösteren (ve kötü görünen) `FilterChipBar` yerine, "Yapılacaklar" alanında şık bir **filtre butonuna (hunili ikon)** taşındı. Tıklandığında düzgün bir alt menü açılmakta ve "Sıralama" (En Önemli/En Yakın Bitiş Tarihi) ve "Zaman Aralığı" (Bu Hafta/Bu Ay/Tümü) seçenekleri gösterilmektedir → `lib/screens/home/home_screen.dart` içerisine `_TodoFilterButton` ve `_FilterOption` bileşenleri eklendi.
- [x] **Gereksiz İmport Temizliği:** `filter_chip_bar.dart` importu kaldırıldı ve `flutter/services.dart` gereksiz importu temizlendi.

## Yazılan/Düzenlenen Dosyalar
| Dosya | Satır Sayısı | Açıklama |
|---|---|---|
| lib/modals/habit_details_sheet.dart | ~100 | Priority seçimi widget'ı ve UI kaldırıldı. |
| lib/modals/todo_details_sheet.dart | ~250 | YENİ: Bitiş Tarihi seçici ve Önem Derecesi (Priority) ile yapılandırıldı. |
| lib/screens/home/home_screen.dart | ~280 | FilterChipBar import kaldırıldı. Todo filtre butonu ve alt menü sistemi eklendi. |
| lib/screens/home/widgets/habit_card.dart | ~180 | `_showContextMenu`'ye `useRootNavigator: true` eklendi. Gereksiz import temizliği. |
| lib/screens/home/widgets/event_card.dart | ~170 | `_showContextMenu`'ye `useRootNavigator: true` eklendi. |
| lib/screens/home/widgets/todo_card.dart | ~180 | `_showContextMenu`'ye `useRootNavigator: true` eklendi. |
| lib/screens/shell/main_shell.dart | ~150 | `priority: details.priority` kaldırıldı (Habit için). Todo form bağlantısı kuruldu. |

## Yazılan Testler
| Test Dosyası | Test Sayısı | Kapsanan Kabul Kriteri |
|---|---|---|
| Mevcut Testler | 46 | Tüm testler başarıyla passes. flutter test sonucu: +46 ✓ |

## Tamamlanmayan / Bloker Görevler
- [ ] "Düzenle" butonunun tam Edit akışı (şimdilik "TODO: Edit implementation" yorum satırı duruyor, rate limit nedeniyle tamamlanmadı). İlgili modal'lar (`showNamingModal`, `showHabitDetailsSheet` vb) `useRootNavigator: true` parametresi alacak şekilde güncelleme beklenmektedir.

## Notlar
- **UI/UX İyileştirme:** Todo filtreleri artık ana sayfada yan yana görünen ufak chip'ler yerine, "Yapılacaklar" başlığının yanında bulunan şık bir filtre butonuna (hunili/filter ikon) taşındı. Bottom Sheet menüsü kullanıcı deneyimini daha da iyileştirmektedir.
- **Form Yapısı:** Alışkanlık (Habit) eklerken artık "Önem Derecesi" sorulmamakta, yalnızca tekrar günleri seçimi yapılmaktadır. Böylece Habit ekleme sürecinin kullanıcı deneyimi basitleştirilmiştir.
- **Todo Kayıtları:** Yapılacak (Todo) eklerken "Önem Derecesi" ve opsiyonel "Bitiş Tarihi" seçeneği sunulmaktadır. Bu, Todo'ların sıralanması (En Önemli/En Yakın Bitiş Tarihi) ve filtrelenmesi (Bu Hafta/Bu Ay) işlevselliğini desteklemektedir.
- **Navigation Fix:** Bottom Sheet'ler artık `useRootNavigator: true` ile açıldığından, uygulama'nın yüzen Navigation Bar'ı tarafından örtülmemektedir. Menü tam olarak görünür ve işlevseldir.
- **Rate Limit:** Sub-Agent rate limit'ine ulaşıldığı için Edit akışı tamamlanamadı. Bu işlevsellik Sprint 5'in sonraki adımında tamamlanabilir veya Sprint 6'a taşınabilir.