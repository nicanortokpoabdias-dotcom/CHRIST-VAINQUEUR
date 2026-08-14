// Généré à partir de android/app/google-services.json (projet Firebase
// "christ-vainqueur"). Pour régénérer après un changement de configuration
// Firebase, relancez `flutterfire configure` ou reportez les nouvelles
// valeurs depuis google-services.json (client_info / api_key / project_info).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions non configuré pour le web. '
        'Lancez `flutterfire configure`.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions non configuré pour cette plateforme. '
          'Lancez `flutterfire configure`.',
        );
    }
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyD-FsNSaTr4-FuqcyjuA0GGBPZ3KzP8b5k',
    appId: '1:182538716965:android:a77b413e9731bc2d0a7ccc',
    messagingSenderId: '182538716965',
    projectId: 'christ-vainqueur',
    storageBucket: 'christ-vainqueur.firebasestorage.app',
  );
}
