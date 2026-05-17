# tech-stack.md — Teknoloji Yığını ve Servis Seçimleri

## Platform & Dil

| Alan | Seçim | Gerekçe |
|---|---|---|
| Framework | **Flutter** (Dart) | Tek kod tabanıyla iOS + Android; Material 3 desteği; widget test altyapısı |
| Minimum SDK | `sdk: ^3.11.5` | Dart 3.x pattern matching ve records dil özellikleri |
| Hedef platformlar | iOS 16+ · Android 7+ | UpSchool proje kapsamı |

---

## Durum Yönetimi (State Management)

**Paket:** `provider`

**Gerekçe:** Basit ve test edilebilir `ChangeNotifier` modeli; `go_router` ile sorunsuz entegrasyon; v0.2'de Firebase stream'leri `StreamProvider` ile doğrudan bağlanabilir. Riverpod veya Bloc tercih edilmedi — proje kapsamı için overkill.

---

## Navigasyon

**Paket:** `go_router`

**Gerekçe:** Declarative URL-bazlı rota tanımı; deep link ve web uyumluluğu; `redirect` hook ile auth guard kolayca uygulanır (v0.2 AI sekmesi ve login akışı için kritik).

---

## Yerel Veritabanı (v0.1)

**Paket:** `sqflite` + `path`

**Şema:** `calendar_events`, `habits`, `todos`, `habit_day_logs`, `streak_snapshots` — ayrık tablolar, soft delete, `local_revision`.

**Gerekçe:** SQLite'ın iOS/Android'de sıfır kurulum gerektirmesi; `sqflite` olgun ve geniş ekosistemi; migration zinciri (`onUpgrade`) ile şema evrimi yönetilebilir. v0.2'de Firestore ile hibrit (yerel önce, buluta senkron) çalışacak.

**v0.2 geçiş stratejisi:** `local_revision` + `device_id` alanları v0.1'de şemaya eklenmiş; Firestore senkron katmanı bu alanları okuyacak.

---

## Tema & Tasarım

**Yaklaşım:** Material 3 + Neo-Brutalist karışımı

| Dosya | Rol |
|---|---|
| `lib/core/theme/app_theme.dart` | `ThemeData` tanımı |
| `lib/core/theme/app_colors.dart` | Tüm renk token'ları |
| `lib/core/theme/app_typography.dart` | `AppTypography` — `Plus Jakarta Sans` (Google Fonts) |
| `lib/core/theme/track_custom_colors.dart` | `TrackCustomColors` extension — `context.track` |
| `lib/core/theme/app_spacing.dart` | Spacing + radius sabitleri |

**Font:** `plus_jakarta_sans` (Google Fonts) — modern, okunabilir, Neo-Brutalist estetikle uyumlu.

---

## Test

**Paket:** `flutter_test` (SDK dahili)

| Tür | Kapsam |
|---|---|
| Unit test | `StreakService`, `HabitProvider`, skip mantığı, tarih hesaplamaları |
| Widget test | `TriangleCornerNav`, `EmptyState`, `TodoFilter` chip renkleri |

**Standart:** Arrange-Act-Assert (AAA) pattern; her test bağımsız, `setUp` ile mock sıfırlanır.

---

## v0.2 Servisleri

### Firebase

| Servis | Kullanım |
|---|---|
| `firebase_auth` | E-posta/şifre + Google Sign-In |
| `cloud_firestore` | Çok cihazlı senkron, paylaşılan listeler |
| `firebase_core` | Ortak init |

**Gerekçe:** Firebase ekosistemi tek API key ve Flutter SDK ile düşük entegrasyon maliyeti sunar. Offline persistence Firestore'da varsayılan açık — yerel önce stratejisiyle uyumlu.

### Harici Takvim OAuth

| Servis | Protokol |
|---|---|
| Google Calendar | Google OAuth 2.0 + Calendar API v3 |
| Apple Calendar | EventKit (native) |
| Microsoft Outlook | Microsoft Graph API + MSAL |

---

## AI Servisleri (v0.2 — FR-17)

**Servis:** Google AI Studio / **Gemini API**

**Gerekçe:** Google ekosistemiyle (Firebase Auth, Firestore) uyumlu; tek API key; Gemini modellerinin Türkçe dil desteği; UpSchool projesi için AI Studio ücretsiz katman yeterli.

**Mimari katmanlar:**

```
ai_repository.dart        ← HTTP: POST /v1/models/gemini-pro:generateContent
ai_planner_service.dart   ← Prompt üretimi + yanıt parse
AiAssistantScreen         ← UI (auth guard ile)
```

**Privacy:** Kullanıcı verisi local DB'den çekilir; sunucuya yalnızca anonim/özet (tarihler, süre, öncelik) gönderilir — isim ve kişisel metin gönderilmez.

**v0.3 abonelik hazırlığı:** `isSubscribed` bayrağı user modelinde v0.2'den itibaren bulunur; Stripe veya platform in-app purchase v0.3'te bağlanacak.

---

## Geliştirme Sürecinde AI Kullanımı

Bu projede yapay zeka aşağıdaki alanlarda geliştirici asistanı olarak kullanıldı:

| Alan | Kullanım |
|---|---|
| Mimari kararlar | Repository katmanı, provider yapısı, go_router guard tasarımı |
| Kod üretimi | Widget boilerplate, migration helper, streak servisi |
| Test yazımı | AAA pattern'inde unit/widget test iskeletleri |
| Hata ayıklama | Streak "Full Replay" yaklaşımına geçiş kararı, anchor_date geçersiz tarih düzeltmesi |
| Dokümentasyon | PRD, agilePlan, bu dosyanın taslağı |

> **Not:** Tüm AI çıktıları geliştirici tarafından gözden geçirildi ve commit öncesi doğrulandı.
