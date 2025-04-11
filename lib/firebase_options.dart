import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';

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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AlzaSyC_TcarUFnhed39VWwvIWc8ovPBuuKxzMQ',
    appId: '1:589914627723:web:c23a1d62c2f5d5e0dd7e8e',
    messagingSenderId: '589914627723',
    projectId: '589914627723',
    authDomain: 'firebbelleva-parfumerie.aseapp.com',
    storageBucket: 'belleva-parfumerie.appspot.com',
    measurementId: 'G-5Q578B1S1W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AlzaSyC_TcarUFnhed39VWwvIWc8ovPBuuKxzMQ',
    appId: '1:589914627723:android:abc123def456',
    messagingSenderId: '589914627723',
    projectId: '589914627723',
    storageBucket: 'belleva-parfumerie.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AlzaSyC_TcarUFnhed39VWwvIWc8ovPBuuKxzMQ',
    appId: '1:589914627723:ios:abc123def456',
    messagingSenderId: '589914627723',
    projectId: '589914627723',
    storageBucket: 'belleva-parfumerie.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AlzaSyC_TcarUFnhed39VWwvIWc8ovPBuuKxzMQ',
    appId: '1:589914627723:macos:abc123def456',
    messagingSenderId: '589914627723',
    projectId: '589914627723',
    storageBucket: 'belleva-parfumerie.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AlzaSyC_TcarUFnhed39VWwvIWc8ovPBuuKxzMQ',
    appId: '1:589914627723:windows:abc123def456',
    messagingSenderId: '589914627723',
    projectId: '589914627723',
    storageBucket: 'belleva-parfumerie.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AlzaSyC_TcarUFnhed39VWwvIWc8ovPBuuKxzMQ',
    appId: '1:589914627723:linux:abc123def456',
    messagingSenderId: '589914627723',
    projectId: '589914627723',
    storageBucket: 'belleva-parfumerie.appspot.com',
  );
}
