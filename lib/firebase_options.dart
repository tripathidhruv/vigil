// File generated based on google-services.json and GoogleService-Info.plist
// Project: flutterapp-793d2

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyC0kw4dW8vafbuFHQN5KWMtxNspKmk1zt0',
    appId: '1:612969434118:web:fbc82ca0f5290e952c4787',
    messagingSenderId: '612969434118',
    projectId: 'flutterapp-793d2',
    storageBucket: 'flutterapp-793d2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0kw4dW8vafbuFHQN5KWMtxNspKmk1zt0',
    appId: '1:612969434118:android:fbc82ca0f5290e952c4787',
    messagingSenderId: '612969434118',
    projectId: 'flutterapp-793d2',
    storageBucket: 'flutterapp-793d2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBj84fgPv5zpwFEVpwVYHwobS18lQE-vpQ',
    appId: '1:612969434118:ios:c46ea9d0b2e01f932c4787',
    messagingSenderId: '612969434118',
    projectId: 'flutterapp-793d2',
    storageBucket: 'flutterapp-793d2.firebasestorage.app',
    iosBundleId: 'com.vigil.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBj84fgPv5zpwFEVpwVYHwobS18lQE-vpQ',
    appId: '1:612969434118:ios:c46ea9d0b2e01f932c4787',
    messagingSenderId: '612969434118',
    projectId: 'flutterapp-793d2',
    storageBucket: 'flutterapp-793d2.firebasestorage.app',
    iosBundleId: 'com.vigil.app',
  );
}
