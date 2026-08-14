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

  // Tant que Firebase n'est pas configuré (voir README), l'app démarre quand
  // même avec le contenu de repli plutôt que de planter au lancement.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.init();
  } catch (error) {
    debugPrint('Firebase non configuré, démarrage en mode dégradé: $error');
  }

  await initializeDateFormatting('fr_FR', null);

  runApp(const ChristVainqueurApp());
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
