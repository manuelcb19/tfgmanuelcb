// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyByLY_d-NXOwud34-bCmAmK0WN010T_XrU',
    appId: '1:182065126076:web:16afcc980c5e8ab4ec8eb9',
    messagingSenderId: '182065126076',
    projectId: 'tfgmanuelcb',
    authDomain: 'tfgmanuelcb.firebaseapp.com',
    storageBucket: 'tfgmanuelcb.appspot.com',
    measurementId: 'G-ZLZ74P51MF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBml88jY6dkYQAEGNAF6qf-B96hxhnn0jQ',
    appId: '1:182065126076:android:14c28b0f5f74df8dec8eb9',
    messagingSenderId: '182065126076',
    projectId: 'tfgmanuelcb',
    storageBucket: 'tfgmanuelcb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDRvohsr7dit1Jetl7j65VAgVjsDdiCbNA',
    appId: '1:182065126076:ios:e70a6e2b56b3e427ec8eb9',
    messagingSenderId: '182065126076',
    projectId: 'tfgmanuelcb',
    storageBucket: 'tfgmanuelcb.appspot.com',
    iosClientId: '182065126076-145b1s543mcdesdnh3s1u9dctbhkk66k.apps.googleusercontent.com',
    iosBundleId: 'com.example.tfgmanuelcb',
  );
}
