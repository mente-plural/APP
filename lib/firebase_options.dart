
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZ3zJu6s7TP2z8YTrp4xQ8Xpe_UGWo0S4',
    appId: '1:1016061063081:android:77428494653b6e5b995eb8',
    messagingSenderId: '1016061063081',
    projectId: 'maoamiga-990da',
    storageBucket: 'maoamiga-990da.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_BG_06GeW4fgMeQBvqXOSDXvyWXHyTXU',
    appId: '1:1016061063081:ios:346e73cd6e45238c995eb8',
    messagingSenderId: '1016061063081',
    projectId: 'maoamiga-990da',
    storageBucket: 'maoamiga-990da.firebasestorage.app',
    iosClientId:
        '1016061063081-b9v5lg0qjmvsjl9fr3la44j3fljapmud.apps.googleusercontent.com',
    iosBundleId: 'com.maoamiga.app.app',
  );
}
