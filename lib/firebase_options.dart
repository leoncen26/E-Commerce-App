// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyC-XhNdZoqyK0IHFjSk9RrjWY4ISIPiAR8',
    appId: '1:928790649363:web:9244690038a5c38c5dfde6',
    messagingSenderId: '928790649363',
    projectId: 'e-commerceapp-9a925',
    authDomain: 'e-commerceapp-9a925.firebaseapp.com',
    storageBucket: 'e-commerceapp-9a925.appspot.com',
    measurementId: 'G-E1LZWV8KR3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDwMP2gaGfEkozjRmrZhDlRgmBbOfS1N-4',
    appId: '1:928790649363:android:9c664e23b718e85b5dfde6',
    messagingSenderId: '928790649363',
    projectId: 'e-commerceapp-9a925',
    storageBucket: 'e-commerceapp-9a925.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBN8psYvm5mp6P6cKm07QEW10XpWbngM6I',
    appId: '1:928790649363:ios:6a8b7187186f06005dfde6',
    messagingSenderId: '928790649363',
    projectId: 'e-commerceapp-9a925',
    storageBucket: 'e-commerceapp-9a925.appspot.com',
    iosBundleId: 'com.example.ecommerceApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBN8psYvm5mp6P6cKm07QEW10XpWbngM6I',
    appId: '1:928790649363:ios:6a8b7187186f06005dfde6',
    messagingSenderId: '928790649363',
    projectId: 'e-commerceapp-9a925',
    storageBucket: 'e-commerceapp-9a925.appspot.com',
    iosBundleId: 'com.example.ecommerceApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC-XhNdZoqyK0IHFjSk9RrjWY4ISIPiAR8',
    appId: '1:928790649363:web:aef42b52d2bbccf55dfde6',
    messagingSenderId: '928790649363',
    projectId: 'e-commerceapp-9a925',
    authDomain: 'e-commerceapp-9a925.firebaseapp.com',
    storageBucket: 'e-commerceapp-9a925.appspot.com',
    measurementId: 'G-8FVT1WYG0V',
  );
}
