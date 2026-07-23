import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        if (kIsWeb) return web;
        return null;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5XThkGE-R1pqnwX0gdmDa_lW-gEygbNQ',
    appId: '1:891377810648:android:4e49e6764f0f41ca29ebad',
    messagingSenderId: '891377810648',
    projectId: 'my-spicemarket-f9f28',
    storageBucket: 'my-spicemarket-f9f28.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB5XThkGE-R1pqnwX0gdmDa_lW-gEygbNQ',
    appId: '1:891377810648:web:dummy',
    messagingSenderId: '891377810648',
    projectId: 'my-spicemarket-f9f28',
    storageBucket: 'my-spicemarket-f9f28.firebasestorage.app',
  );
}
