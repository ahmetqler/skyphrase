// Firebase Console'daki "SkyPhrase16" web uygulamasından alınan yapılandırma.
// Android/iOS platform desteği eklendiğinde (ör. `flutter create --platforms=ios .`
// sonrası Firebase konsolunda yeni bir uygulama kaydedip) buraya yeni
// case'ler eklenmeli.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions bu platform için henüz yapılandırılmadı. '
          'Firebase konsolunda bu platform için bir uygulama kaydedip '
          'buraya yeni bir FirebaseOptions ekleyin.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBoU7SAydayKOiU18wRIzugTcAZr2DwBCw',
    appId: '1:336169931471:web:39b924e7d25156bc1c5dba',
    messagingSenderId: '336169931471',
    projectId: 'skyphrase16',
    authDomain: 'skyphrase16.firebaseapp.com',
    storageBucket: 'skyphrase16.firebasestorage.app',
    measurementId: 'G-39WGKPBPHG',
  );
}
