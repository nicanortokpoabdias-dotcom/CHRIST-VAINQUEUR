// File generated normally by the FlutterFire CLI.
// -----------------------------------------------------------------------
// ⚠️  PLACEHOLDER — remplacez ce fichier avant de publier l'application.
//
// Ce fichier contient des valeurs factices. Pour le régénérer avec les
// vraies informations de votre projet Firebase, installez la CLI puis
// lancez, à la racine du dossier `app` :
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Voir le README du projet pour les instructions complètes.
// -----------------------------------------------------------------------

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
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'christ-vainqueur-app',
    storageBucket: 'christ-vainqueur-app.appspot.com',
  );
}
