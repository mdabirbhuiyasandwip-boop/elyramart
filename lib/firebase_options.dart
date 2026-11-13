import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Android Firebase client configuration for Elyramart.
/// Web requires registering a separate Firebase Web app first.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Register a Firebase Web app and add its exact options before running Elyramart on Web.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Elyramart Firebase is configured for Android.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1y_pRspJCjiXKNs_pM6CcwdUApLeDtCQ',
    appId: '1:275927108805:android:5b70dc4408b7713545b4ac',
    messagingSenderId: '275927108805',
    projectId: 'elyramart',
    storageBucket: 'elyramart.firebasestorage.app',
  );
}
