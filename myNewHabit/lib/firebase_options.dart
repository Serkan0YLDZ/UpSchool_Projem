// Firebase yapılandırması — `flutterfire configure` ile gerçek projeye bağlayın.
// Bu dosya derleme ve CI için minimum alanları içerir; Console'daki değerlerle değiştirin.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase Console + FlutterFire CLI ile üretilen değerlerle güncellenmeli.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web için firebase_options güncellenmeli (flutterfire configure).',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Bu platform için Firebase seçenekleri tanımlı değil.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-your-firebase-project-id',
    storageBucket: 'replace-with-your-firebase-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-your-firebase-project-id',
    storageBucket: 'replace-with-your-firebase-project-id.appspot.com',
    iosBundleId: 'com.myNewHabit.myNewHabit',
  );
}
