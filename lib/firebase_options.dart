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
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCP-2bCRoNs-puah434ckkzH3gNX1dBQNY',
    appId: '1:1056376307892:web:f9a924ba820940b44497e1',
    messagingSenderId: '1056376307892',
    projectId: 'nutrifit-c7f62',
    authDomain: 'nutrifit-c7f62.firebaseapp.com',
    storageBucket: 'nutrifit-c7f62.firebasestorage.app',
    measurementId: 'G-PMTDVX32Y8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCP-2bCRoNs-puah434ckkzH3gNX1dBQNY',
    appId: '1:1056376307892:android:f9a924ba820940b44497e1', // Placeholder app ID for android
    messagingSenderId: '1056376307892',
    projectId: 'nutrifit-c7f62',
    storageBucket: 'nutrifit-c7f62.firebasestorage.app',
  );
}
