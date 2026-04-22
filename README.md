# UpSchool Projem — Flutter PDF Harcama Takibi (MVP)

Bu repo, **Flutter** ile geliştirilen **offline-first** bir mobil uygulamanın MVP çalışmasını içerir.
MVP odak: **PDF yükleme → PDF görüntüleme → PDF’ten metin çıkarımı (v0)**.

## Gereksinimler

- Flutter SDK (stable)
- Chrome (web demo için)
- (iOS için) Xcode + CocoaPods
- (Android için) Android Studio + Android SDK

Kurulum doğrulama:

```bash
flutter doctor -v
```

## Çalıştırma (en hızlı: Web/Chrome)

```bash
cd upschool_projem_app
flutter pub get
flutter run -d chrome
```

Uygulama açılınca:
- **PDF Yükle** butonuna basıp bir PDF seç
- Detay ekranda PDF görüntülenir
- Alt panelde PDF’ten çıkarılan metin (varsa) gösterilir

## Çalıştırma (iOS / Android)

> Not: iOS/Android tarafında plugin’ler için tam kurulum gerekir.

### iOS

```bash
cd upschool_projem_app
flutter run
```

Eğer CocoaPods/Pods hatası alırsan:

```bash
cd ios
pod install
cd ..
flutter run
```

### Android

Android SDK kurulu olmalı. Sonra:

```bash
cd upschool_projem_app
flutter run
```

## Sık karşılaşılan sorunlar

### `EACCES: permission denied, mkdir '/Users/serkan/.cursor/projects'`

`.cursor` klasörü yanlışlıkla `root` sahibi olabilir. Çözüm:

```bash
sudo chown -R "$USER":staff "$HOME/.cursor"
mkdir -p "$HOME/.cursor/projects"
```

## Dokümanlar

- Ürün gereksinimleri: [`prd.md`](prd.md)
- Sprint planı: [`agile.md`](agile.md)

