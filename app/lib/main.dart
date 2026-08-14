import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'screens/root_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chargement local, rapide et sans réseau : peut être attendu sans risque
  // de bloquer l'affichage de l'app.
  await initializeDateFormatting('fr_FR', null);

  // L'app s'affiche immédiatement, sans attendre Firebase. Tant qu'un vrai
  // projet Firebase n'est pas configuré (voir README), les appels réseau
  // ci-dessous peuvent échouer ou traîner : ils ne doivent jamais retarder
  // le premier affichage, sous peine d'écran blanc au démarrage.
  runApp(const ChristVainqueurApp());

  unawaited(_initializeFirebase());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error) {
    debugPrint('Firebase non configuré, démarrage en mode dégradé: $error');
    return;
  }

  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.init();
  } catch (error) {
    debugPrint('Notifications indisponibles: $error');
  }
}

class ChristVainqueurApp extends StatelessWidget {
  const ChristVainqueurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centre de Prière Christ Vainqueur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RootScreen(),
    );
  }
}
