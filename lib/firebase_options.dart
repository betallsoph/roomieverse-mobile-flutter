import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5XNQbA_hW8FhFUQq-mn29CmiEA15EGfU',
    appId: '1:808985936517:web:8e9337a8dc37ddb1f39fec',
    messagingSenderId: '808985936517',
    projectId: 'roomieverse-antt',
    storageBucket: 'roomieverse-antt.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFUzmv772RhgAXXZxo7Rou2418BUfMkWE',
    appId: '1:808985936517:ios:6a22f8649c26e699f39fec',
    messagingSenderId: '808985936517',
    projectId: 'roomieverse-antt',
    storageBucket: 'roomieverse-antt.firebasestorage.app',
    iosBundleId: 'com.roommieverse.roomieverseMobile',
    iosClientId: '808985936517-rcirtpkods317iufbn78kkv8e0h7lqau.apps.googleusercontent.com',
  );
}
