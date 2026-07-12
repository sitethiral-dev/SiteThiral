import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // ── WEB (Chrome / Edge) ──────────────────
    if (kIsWeb) {
      return web;
    }
    // ── MOBILE / DESKTOP ────────────────────
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return web; // Windows desktop — use web config
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── WEB CONFIG (from your Firebase Console) ──
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBwRwg4ItxIwU9n8Wp4uE-B1graL4E5XJo',
    authDomain: 'sitethiral-76afb.firebaseapp.com',
    projectId: 'sitethiral-76afb',
    storageBucket: 'sitethiral-76afb.firebasestorage.app',
    messagingSenderId: '925164197370',
    appId: '1:925164197370:web:94506d2741793e49d18043',
  );

  // ── ANDROID CONFIG ───────────────────────────
  // (google-services.json இருந்தா auto fill ஆகும்)
  // இல்லன்னா web config போட்டாலும் work ஆகும்
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBwRwg4ItxIwU9n8Wp4uE-B1graL4E5XJo',
    authDomain: 'sitethiral-76afb.firebaseapp.com',
    projectId: 'sitethiral-76afb',
    storageBucket: 'sitethiral-76afb.firebasestorage.app',
    messagingSenderId: '925164197370',
    appId: '1:925164197370:web:94506d2741793e49d18043',
  );

  // ── iOS CONFIG ───────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBwRwg4ItxIwU9n8Wp4uE-B1graL4E5XJo',
    authDomain: 'sitethiral-76afb.firebaseapp.com',
    projectId: 'sitethiral-76afb',
    storageBucket: 'sitethiral-76afb.firebasestorage.app',
    messagingSenderId: '925164197370',
    appId: '1:925164197370:web:94506d2741793e49d18043',
    iosClientId: '',
    iosBundleId: 'com.sitethiral.app',
  );
}