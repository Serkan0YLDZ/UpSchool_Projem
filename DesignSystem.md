# DesignSystem.md — Renk Paleti, Tipografi ve Component Kuralları

> Kaynak dosyalar: `lib/core/theme/` — `app_colors.dart`, `app_typography.dart`, `app_theme.dart`, `app_spacing.dart`, `track_custom_colors.dart`

---

## 1. Tema Felsefesi

**Neo-Brutalist + Material 3 karışımı.**

- Kalın kenarlıklar, sert gölgeler, az yuvarlama (Neo-Brutalist)
- `ColorScheme` ve `TextTheme` altyapısı (Material 3)
- Renk token'ları `AppColors`'ta merkezi; `TrackCustomColors` extension'ı ile `context.track` üzerinden erişilir.

---

## 2. Renk Paleti

### 2.1 Material 3 Temel Renkler

| Token | Hex | Kullanım |
|---|---|---|
| `primary` | `#0B5C4F` | Ana butonlar, vurgular |
| `primaryContainer` | `#0F7A68` | Tamamlanan alışkanlık kartı (`habitDone`) |
| `onPrimary` | `#FFFFFF` | Primary üzeri metin |
| `secondary` | `#3D4A45` | İkincil elementler |
| `secondaryContainer` | `#C9E8E0` | Yüzey varyantı |
| `tertiary` | `#5B3FA8` | Üçüncül vurgu (mor) |
| `tertiaryContainer` | `#DDD6F5` | Mor tona ait kapsayıcı |
| `surface` | `#F6F7F4` | Ana arka plan |
| `surfaceContainerLowest` | `#FFFFFF` | Kart yüzeyi |
| `onSurface` | `#141816` | Birincil metin rengi |
| `outline` | `#5B6460` | Kenarlıklar |
| `error` | `#B3261E` | Hata, seri tehlikesi (`relapseDanger`) |

### 2.2 Neo-Brutalist Özel Token'lar

| Token | Hex | Kullanım |
|---|---|---|
| `neoStackFace` | `#434D5E` | Merkez FAB yüzü · Seçili nav ikon rengi · Seçili chip arka planı |
| `neoStackShadow` | `#12161F` | Brutalist sert gölge · Nav pasif ikon rengi (0.42 alfa) |
| `neoStackOnFace` | `#FFFFFF` | `neoStackFace` üzeri metin / ikon |
| `neoChromePlate` | `#F8F9FB` | Alt nav arka planı · Takvim şeridi |
| `brutalistBlack` | `#121816` | Çizgi / hat rengi |

### 2.3 Bölüm Renkleri (Alt Nav Üçgen Metaforu)

| Token | Hex | Bölüm |
|---|---|---|
| `homeSectionCalendarBlue` | `#2563EB` | Takvim — üst köşe ikonu |
| `homeSectionHabitsCoral` | `#EF4444` | Alışkanlık — sol alt köşe |
| `homeSectionTodosOrange` | `#F97316` | Yapılacaklar — sağ alt köşe |

### 2.4 Öncelik & Durum Renkleri

| Token | Hex | Kullanım |
|---|---|---|
| `todoPriorityHigh` | `#E53935` | Yüksek öncelik şeridi |
| `todoPriorityMedium` | `#F9D65C` | Orta öncelik |
| `todoPriorityLow` | `#7EB6D9` | Düşük öncelik |
| `streakFire` | `#C2410C` | Aktif seri alevi |
| `streakRecovery` | `#CA6A08` | Kurtarma seri rengi |
| `streakMuted` | `#8A9390` | Pasif / biten seri |
| `habitCardSoftBlue` | `#B8E0D8` | Alışkanlık kart arka plan tonu |

---

## 3. Tipografi

**Font ailesi:** `Plus Jakarta Sans` (Google Fonts)

| Token | Boyut | Ağırlık | Line Height | Kullanım |
|---|---|---|---|---|
| `headlineLg` | 32px | 700 | 1.2 | Sayfa başlıkları |
| `headlineMd` | 24px | 600 | 1.3 | Bölüm başlıkları |
| `headlineSm` | 20px | 600 | 1.4 | Kart başlıkları |
| `bodyLg` | 18px | 400 | 1.6 | Ana paragraf metni |
| `bodyMd` | 16px | 400 | 1.5 | Standart body |
| `bodySm` | 14px | 400 | 1.5 | Yardımcı metin, etiket |
| `labelLg` | 14px | 600 | 1.2 | Buton metni, chip etiketi (ls: 0.28) |
| `labelSm` | 12px | 500 | 1.2 | Küçük etiket (ls: 0.6) |

---

## 4. Spacing & Radius

Tüm değerler `AppSpacing` sınıfından alınır.

| Sabit | Değer | Kullanım |
|---|---|---|
| `sm` | 8dp | İç dolgu küçük |
| `md` | 16dp | Standart padding |
| `lg` | 24dp | Büyük boşluk |
| `radiusMd` | Tanımlı | Kart ve snackbar köşe yarıçapı |
| `mainShellBottomNavHeight` | Tanımlı | Alt nav yüksekliği |

---

## 5. Component Kuralları

### 5.1 Merkez FAB (Ekle Butonu)

- **Boyut:** 64×64dp
- **Köşe yarıçapı:** 18dp
- **Arka plan:** `neoStackFace` (#434D5E)
- **Kenarlık:** `neoStackShadow`, 3dp
- **Sert gölge:** `neoStackShadow`, offset (5, 5), blur 0
- **İkon:** `Icons.add_rounded`, boyut 32, renk `neoStackOnFace`
- **Konumlama:** Bottom bar'da dikey olarak 24dp yukarı kaydırılmış (`Transform.translate(Offset(0, -24))`)

### 5.2 Alt Navigasyon Bar

- **Arka plan:** `neoChromePlate`
- **Üst kenarlık:** `neoStackShadow`, 4dp
- **Slot yapısı (5 eleman):** `[Home] [AI] [+FAB] [TriangleNav] [Profile]`
- **Aktif ikon rengi:** `neoStackFace`
- **Pasif ikon rengi:** `neoStackShadow` @ 0.42 alfa

> **AI İkonu (v0.2):** `Icons.auto_awesome_rounded` — aktif renk `neoStackFace` — Home ve Profile ile tutarlı.

### 5.3 Üçgen Köşe Navigasyonu

- **Üçgen çizilmez** — sadece `Stack` + `Positioned` köşe konumlaması
- Aktif ikon: boyut 20, tam opasite, bölüm rengi
- Pasif ikon: boyut 14, 0.38 opasite, `neoStackShadow`
- Geçiş: `AnimatedOpacity` + `AnimatedContainer` (200ms, `easeOut`)
- Dokunma hedefi minimum: 48×48dp

### 5.4 Chip (Filtre)

- **Seçili:** Arka plan `neoStackFace`, metin `neoStackOnFace` (beyaz)
- **Seçilmemiş:** `surfaceContainerLow` arka plan, `onSurface` metin
- Başlık metni: **"Yapılacakları Filtrele"** (yalnızca F büyük, Türkçe başlık biçimi)

### 5.5 Boş Durum (Empty State)

- **Kural:** Emoji **kullanılmaz**
- **Format:** `Icon` widget (Material) + metin
- `bodySm` ile yardımcı metin, `streakMuted` veya `onSurfaceVariant` rengi

### 5.6 Öncelik Gösterimi

- **Kural:** Ayrı ikon **kullanılmaz**
- **Format:** Renk şeridi (`todoPriorityHigh/Medium/Low`) veya metin etiketi

### 5.7 Snackbar

- **Arka plan:** `brutalistInk` (TrackCustomColors)
- **Kenarlık:** beyaz, 2dp
- **Köşe:** `radiusMd`
- **Davranış:** `SnackBarBehavior.floating`

---

## 6. Semantics & Erişilebilirlik

| Bileşen | Etiket |
|---|---|
| Takvim ikonu (aktif) | `"Takvim görünümü (seçili)"` |
| Alışkanlık ikonu (aktif) | `"Alışkanlık görünümü (seçili)"` |
| Yapılacaklar ikonu (aktif) | `"Yapılacaklar görünümü (seçili)"` |
| Pasif durum | `"Mod seçici: Takvim, Alışkanlık, Yapılacaklar"` |

- `Semantics(button: true)` tüm dokunulabilir alanlarda.
- VoiceOver / TalkBack ile doğrulanmalı.
