import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured - use Android');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS is not configured');
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcsbw9US9Ooxc13gqE6a0dav8XClj848k',
    appId: '1:925164197370:android:72341c0a37186093d18043',
    messagingSenderId: '925164197370',
    projectId: 'sitethiral-76afb',
    storageBucket: 'sitethiral-76afb.firebasestorage.app',
  );
}