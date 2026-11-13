import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for the Elyramart project.
/// Values are the Firebase client configuration supplied by the project owner.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Elyramart Firebase is currently configured for Android and Web.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCz6iEHPvhHm-ACg248-mzmYFB14mTMwq0',
    appId: '1:275927108805:web:1a94a4348968169045b4ac',
    messagingSenderId: '275927108805',
    projectId: 'elyramart',
    authDomain: 'elyramart.firebaseapp.com',
    storageBucket: 'elyramart.firebasestorage.app',
    measurementId: 'G-8NTXTTTZRG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCz6iEHPvhHm-ACg248-mzmYFB14mTMwq0',
    appId: '1:275927108805:android:5b70dc4408b7713545b4ac',
    messagingSenderId: '275927108805',
    projectId: 'elyramart',
    storageBucket: 'elyramart.firebasestorage.app',
  );
}
