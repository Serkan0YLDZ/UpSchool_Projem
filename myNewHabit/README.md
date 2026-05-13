# myNewHabit — Flutter uygulaması

Yerel öncelikli alışkanlık, takvim etkinliği ve yapılacak takibi. Tam ürün özeti, mimari, Firebase ve depo yapısı için üst dizindeki **[README.md](../README.md)** dosyasına bakın.

## Hızlı komutlar

```bash
flutter pub get
flutter run
```

```bash
dart analyze
flutter test
```

## iOS

```bash
cd ios && pod install && cd ..
```

## Paket adı ve sürüm

- Dart paket adı: `my_new_habit` (`pubspec.yaml`)  
- `environment.sdk`: depodaki `pubspec.yaml` ile aynı sürüm aralığını kullanın.

## Firebase

İsteğe bağlı bulut modu: `lib/firebase_options.dart`, Android `google-services.json`, iOS `GoogleService-Info.plist` ve Firebase Console ayarları. Ayrıntılı kontrol listesi: [../.rules/01-tech-stack.md](../.rules/01-tech-stack.md).

## Kaynaklar

- [Flutter dokümantasyonu](https://docs.flutter.dev/)
