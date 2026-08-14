# Christ Vainqueur — application mobile

Application Flutter (Android) pour permettre aux membres et visiteurs du
**CENTRE DE PRIÈRE CHRIST VAINQUEUR** de rester informés : actualités,
programme des événements, verset du jour, et notifications push.

## Fonctionnalités

- 📰 **Fil d'actualités** — liste des annonces publiées, avec écran de détail.
- 🔔 **Notifications push** — via Firebase Cloud Messaging, sur les topics
  `actualites` et `evenements`.
- 📅 **Programme** — calendrier des cultes, veillées, jeûnes et autres
  événements à venir.
- ✝️ **Verset du jour** — bandeau avec verset et méditation en tête d'accueil.
- 📺 **Réseaux sociaux** — boutons YouTube et TikTok sur l'accueil.

L'application démarre normalement même sans configuration Firebase (contenu
de repli), pour que l'APK soit installable et utilisable immédiatement. Les
actualités en temps réel nécessitent la configuration Firebase ci-dessous.

## Stack technique

- [Flutter](https://flutter.dev) 3.47 (Dart 3.13)
- [Firebase](https://firebase.google.com) : Cloud Firestore (données),
  Firebase Cloud Messaging (notifications push)
- `flutter_local_notifications` pour l'affichage des notifications en
  premier plan

## Configuration Firebase (obligatoire avant de lancer l'app)

Le projet est prêt côté code, mais il a besoin d'un **projet Firebase réel**
pour fonctionner (les actualités sont stockées dans Firestore, et les
notifications passent par FCM).

1. Créez un projet sur la [console Firebase](https://console.firebase.google.com).
2. Ajoutez une application **Android** avec l'ID de package
   `com.christvainqueur.christ_vainqueur_app` (visible dans
   `android/app/build.gradle.kts`).
3. Téléchargez le fichier `google-services.json` généré et placez-le dans
   `android/app/google-services.json`.
4. Installez la CLI FlutterFire et générez `lib/firebase_options.dart`
   (remplace le fichier factice fourni) :

   ```bash
   dart pub global activate flutterfire_cli
   cd app
   flutterfire configure
   ```

5. Dans la console Firebase, activez **Cloud Firestore** (mode production ou
   test) et **Cloud Messaging**.

Tant que `google-services.json` n'est pas ajouté, l'application compile et se
lance normalement, mais affiche un contenu de repli (verset par défaut,
aucune actualité) au lieu des vraies données. Terminez la configuration
ci-dessus pour activer les actualités en temps réel et les notifications.

## Structure des données Firestore attendue

### Collection `news` (actualités)

| Champ         | Type      | Description                          |
|---------------|-----------|---------------------------------------|
| `title`       | string    | Titre de l'actualité                  |
| `content`     | string    | Contenu / description                 |
| `imageUrl`    | string?   | URL d'image (optionnel)               |
| `category`    | string    | Ex: "Annonce", "Témoignage", "Culte"  |
| `publishedAt` | timestamp | Date de publication                   |

### Collection `events` (programme)

| Champ               | Type      | Description                     |
|---------------------|-----------|----------------------------------|
| `title`             | string    | Nom de l'événement               |
| `description`       | string    | Détails                          |
| `location`          | string    | Lieu                             |
| `startAt`           | timestamp | Date et heure de début           |
| `isRecurringWeekly` | bool      | Événement hebdomadaire récurrent |

### Collection `dailyVerse` (verset du jour)

| Champ        | Type      | Description                |
|--------------|-----------|------------------------------|
| `reference`  | string    | Ex: "Philippiens 4:13"       |
| `text`       | string    | Texte du verset              |
| `meditation` | string?   | Courte méditation (optionnel)|
| `date`       | timestamp | Date associée                |

## Publier une actualité ou un événement

Dans un premier temps, publiez directement depuis la
[console Firebase → Firestore Database](https://console.firebase.google.com),
en ajoutant un document dans la collection correspondante.

Pour envoyer une **notification push** en même temps qu'une actualité,
utilisez la console Firebase → *Cloud Messaging* → *Nouvelle campagne*, en
ciblant le topic `actualites` (ou `evenements`).

> Une interface d'administration dédiée (site web ou app) pourra être
> ajoutée plus tard pour simplifier la publication sans passer par la
> console Firebase.

## Lancer le projet

```bash
cd app
flutter pub get
flutter run
```

## Construire l'APK Android

```bash
cd app
flutter build apk --release
```

L'APK signé se trouve ensuite dans `build/app/outputs/flutter-apk/`.

### Compiler via GitHub Actions

Le workflow `.github/workflows/build-apk.yml` compile automatiquement l'APK
release à chaque push sur cette branche (ou manuellement via l'onglet
*Actions* → *Build Android APK* → *Run workflow*). L'APK est ensuite
téléchargeable dans les *Artifacts* du run.
