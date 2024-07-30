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
    apiKey: 'AIzaSyDJyzUoHNPLOnLfcja-w_13myTHSfIERUE',
    appId: '1:902862934461:web:9fdc185ef0fb0437e482d4',
    messagingSenderId: '902862934461',
    projectId: 'miniproject-a3032',
    authDomain: 'miniproject-a3032.firebaseapp.com',
    storageBucket: 'miniproject-a3032.appspot.com',
    measurementId: 'G-XGLQQ60EBN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwQjdrUVkzYFEmCsjq3FIfAkLpx9N2kwM',
    appId: '1:902862934461:android:a9d93168de334887e482d4',
    messagingSenderId: '902862934461',
    projectId: 'miniproject-a3032',
    storageBucket: 'miniproject-a3032.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCGb2F_qcuCod6Sr-niRXL6keNP09LeglM',
    appId: '1:902862934461:ios:2a8bd19352a901c2e482d4',
    messagingSenderId: '902862934461',
    projectId: 'miniproject-a3032',
    storageBucket: 'miniproject-a3032.appspot.com',
    iosBundleId: 'com.harshRajpurohit.weChat',
  );

}