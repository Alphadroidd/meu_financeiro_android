import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwfLaEm8WQMFSML38SSAFoBksw_qlmXfg',
    appId: '1:964539627033:android:7ba2d4a5d20a9a688adc88',
    messagingSenderId: '964539627033',
    projectId: 'financas-712a1',
    storageBucket: 'financas-712a1.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCwfLaEm8WQMFSML38SSAFoBksw_qlmXfg',
    appId: '1:964539627033:android:7ba2d4a5d20a9a688adc88',
    messagingSenderId: '964539627033',
    projectId: 'financas-712a1',
    storageBucket: 'financas-712a1.firebasestorage.app',
  );
}
