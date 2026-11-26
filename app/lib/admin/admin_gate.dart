import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import 'admin_home_screen.dart';

/// Code à saisir une seule fois par téléphone pour déverrouiller
/// l'administration (évite qu'un visiteur qui tomberait sur le geste secret
/// ne puisse publier ou supprimer du contenu). Pour le changer, modifiez
/// cette valeur dans le code.
const String adminPin = 'CV2026';

const String _prefsUnlockedKey = 'cv_admin_unlocked';

/// Ouvre l'administration : directement si ce téléphone l'a déjà déverrouillée
/// une fois, sinon après saisie du code.
Future<void> openAdmin(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final alreadyUnlocked = prefs.getBool(_prefsUnlockedKey) ?? false;

  if (!context.mounted) return;

  if (alreadyUnlocked) {
    await _enterAdmin(context);
    return;
  }

  final unlocked = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const _AdminPinScreen()),
  );
  if (unlocked == true) {
    await prefs.setBool(_prefsUnlockedKey, true);
    if (context.mounted) await _enterAdmin(context);
  }
}

/// S'assure que Firebase est prêt et qu'une session (anonyme) est ouverte
/// avant d'autoriser l'accès à l'administration, puis ouvre l'écran.
Future<void> _enterAdmin(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  String? error;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    final code = e is FirebaseAuthException ? e.code : '';
    if (code == 'operation-not-allowed' || code == 'admin-restricted-operation') {
      error = "La connexion anonyme n'est pas encore activée dans Firebase.\n\n"
          'Ouvrez console.firebase.google.com → projet "christ-vainqueur" → '
          'Authentication → Sign-in method → activez "Anonyme", puis réessayez.';
    } else {
      error = 'Connexion impossible : $e\n\nVérifiez votre connexion internet puis réessayez.';
    }
  }

  if (!context.mounted) return;
  Navigator.of(context).pop(); // ferme le loader

  if (error != null) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Connexion impossible'),
        content: Text(error!),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
  );
}

class _AdminPinScreen extends StatefulWidget {
  const _AdminPinScreen();

  @override
  State<_AdminPinScreen> createState() => _AdminPinScreenState();
}

class _AdminPinScreenState extends State<_AdminPinScreen> {
  final _controller = TextEditingController();
  String? _error;

  void _submit() {
    if (_controller.text.trim() == adminPin) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'Code incorrect.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administration')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 40),
                const SizedBox(height: 16),
                const Text(
                  'Entrez le code administrateur pour publier du contenu.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  obscureText: true,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Code',
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submit,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                    child: Text('Déverrouiller'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
