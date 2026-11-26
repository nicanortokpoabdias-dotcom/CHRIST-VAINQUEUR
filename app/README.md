# Christ Vainqueur — application mobile

Application Flutter (Android) pour permettre aux membres et visiteurs du
**CENTRE DE PRIÈRE CHRIST VAINQUEUR** de rester informés : actualités,
programme des événements, prières audio, vidéos et verset du jour.

## Console d'administration

Tout le contenu (actualités, événements + affiches, audios, vidéos, verset
du jour) se publie depuis une **console web privée**, sans toucher au code :

👉 **https://claude.ai/artifact/FMF8BCC7pRA98hDZ9tbJT6**

Voir [Configurer la console d'administration](#configurer-la-console-dadministration)
pour l'activer (une seule fois).

## Fonctionnalités

- 📰 **Fil d'actualités** — liste des annonces publiées, avec écran de détail.
- 📅 **Programme** — calendrier des cultes, veillées, jeûnes et autres
  événements à venir, avec affiche (image) optionnelle par événement.
- 🎧 **Prières & prédications** — séances de prière enregistrées (mp3),
  écoutables dans l'app (mini-lecteur persistant) et téléchargeables.
- 🎬 **Vidéos** — liste des vidéos YouTube du centre.
- ✝️ **Verset du jour** — bandeau avec verset et méditation en tête d'accueil.
- 📺 **Réseaux sociaux** — boutons YouTube et TikTok sur l'accueil.
- 🔔 **Notifications push** — via Firebase Cloud Messaging, sur les topics
  `actualites` et `evenements`.
- 🌗 **Thème clair/sombre automatique**, navigation flottante animée,
  interface entièrement repensée (dégradés, animations d'entrée douces).

L'application démarre normalement même sans configuration Firebase (contenu
de repli), pour que l'APK soit installable et utilisable immédiatement. Les
actualités en temps réel nécessitent la configuration Firebase ci-dessous.

## Stack technique

- [Flutter](https://flutter.dev) 3.50 (Dart 3.14)
- [Firebase](https://firebase.google.com) : Cloud Firestore (données),
  Firebase Storage (images/audio), Firebase Cloud Messaging (notifications),
  Firebase Authentication (accès à la console d'administration)
- `just_audio` pour la lecture audio in-app (mini-lecteur persistant)
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

| Champ               | Type      | Description                          |
|---------------------|-----------|----------------------------------------|
| `title`             | string    | Nom de l'événement                    |
| `description`       | string    | Détails                               |
| `location`          | string    | Lieu                                  |
| `startAt`           | timestamp | Date et heure de début                |
| `isRecurringWeekly` | bool      | Événement hebdomadaire récurrent      |
| `posterUrl`         | string?   | URL de l'affiche de l'événement (optionnel) |

### Collection `audioMessages` (prières & prédications enregistrées)

| Champ         | Type      | Description                          |
|---------------|-----------|---------------------------------------|
| `title`       | string    | Titre de la séance (ex: "Prière du matin") |
| `description` | string    | Courte description (optionnel)        |
| `audioUrl`    | string    | URL du fichier mp3                    |
| `recordedAt`  | timestamp | Date de l'enregistrement              |

### Collection `videos`

| Champ         | Type      | Description                       |
|---------------|-----------|-------------------------------------|
| `title`       | string    | Titre de la vidéo                  |
| `youtubeUrl`  | string    | Lien YouTube (classique, short ou youtu.be) |
| `publishedAt` | timestamp | Date de publication                |

### Collection `dailyVerse` (verset du jour)

| Champ        | Type      | Description                |
|--------------|-----------|------------------------------|
| `reference`  | string    | Ex: "Philippiens 4:13"       |
| `text`       | string    | Texte du verset              |
| `meditation` | string?   | Courte méditation (optionnel)|
| `date`       | timestamp | Date associée                |

## Configurer la console d'administration

La console (`admin/console.html`, aussi publiée en ligne) permet de publier
tout le contenu depuis un navigateur, sans toucher au code. Pour l'activer :

1. **Activer la connexion anonyme** (la console s'ouvre alors directement,
   sans aucun mot de passe à créer ou retenir) : console Firebase →
   *Authentication* → onglet *Sign-in method* → activez **Anonyme**.
   Lien direct : https://console.firebase.google.com/project/christ-vainqueur/authentication/providers
2. **Coller les règles de sécurité** (lecture publique pour l'app, écriture
   réservée à la console) :

   **Firestore → Rules :**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```

   **Storage → Rules :**
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```

3. **(Recommandé) Enregistrer une application Web** : *Paramètres du projet*
   → *Ajouter une application* → icône **</>** → donnez-lui un nom (ex.
   "Console admin") → copiez l'objet `firebaseConfig` affiché et remplacez
   `FIREBASE_WEB_CONFIG` dans `admin/console.html` (recherchez-le en haut du
   `<script>`). Sans cette étape, la console utilise une configuration
   provisoire qui fonctionne généralement, mais celle-ci est plus propre.
4. Ouvrez la console (lien ci-dessus) : elle s'ouvre directement, sans rien
   à saisir. Chaque onglet (Actualités, Programme, Prières, Vidéos, Verset)
   gère sa propre liste, avec upload direct des affiches/mp3 vers Firebase
   Storage.

> ⚠️ Cette console n'a plus aucune protection par mot de passe : quiconque a
> le lien peut publier ou supprimer du contenu. Gardez le lien privé (ne le
> partagez pas publiquement) — c'est la seule protection restante.

Pour envoyer une **notification push** en plus d'une actualité ou d'un
événement, utilisez la console Firebase → *Cloud Messaging* → *Nouvelle
campagne*, en ciblant le topic `actualites` (ou `evenements`).

<details>
<summary>Publication manuelle (sans la console), si besoin ponctuel</summary>

Tout peut aussi se publier directement depuis la
[console Firebase](https://console.firebase.google.com) → *Firestore
Database* → collection correspondante → *Ajouter un document*, en respectant
les champs listés plus haut (types **timestamp**, pas texte, pour les dates).
Pour une affiche ou un audio, uploadez d'abord le fichier dans *Storage* (un
dossier `posters/` ou `audio/`), copiez son URL de téléchargement, puis
collez-la dans le champ `posterUrl`/`audioUrl` du document.
</details>

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
**et** l'AAB (nécessaire pour Google Play) à chaque push sur cette branche
(ou manuellement via l'onglet *Actions* → *Build Android APK* → *Run
workflow*). Les fichiers sont ensuite téléchargeables dans les *Artifacts*
du run, et aussi poussés sur la branche `apk-build` (`dist/`).

## Publier sur Google Play

Cette étape nécessite un **compte développeur Google Play à votre nom**
(inscription unique à 25 $US, carte bancaire) — personne ne peut la faire
gratuitement à votre place, ni créer ce compte pour vous. Tout le reste est
prêt ; il vous reste environ 15–20 minutes de clics.

1. **Créer le compte** : https://play.google.com/console/signup
2. **Créer l'application** dans Play Console → *Créer une application* →
   nom "Christ Vainqueur", catégorie **Style de vie** (ou *Éducation*),
   gratuite, visibilité ciblée "Tous publics".
3. **Fiche Store** (textes prêts à coller ci-dessous).
4. **Politique de confidentialité** : collez ce lien dans le champ dédié :
   **https://claude.ai/artifact/MNuqVJeiM137qAhSxrsxEg**
   (pensez à la partager en "lecture pour tous" via son menu *Partager*, et
   à compléter l'adresse e-mail de contact dedans avant de la rendre
   publique).
5. **Classification du contenu** : répondez au questionnaire en indiquant
   qu'il n'y a aucun contenu sensible → classification "Tous publics"
   attendue.
6. **Sécurité des données** (Data safety) : déclarez la collecte d'un
   "identifiant d'appareil" (jeton de notification Firebase), finalité
   "Fonctionnalité de l'application", non partagé avec des tiers, non vendu.
   Le détail est dans la politique de confidentialité ci-dessus.
7. **Version** → *Production* → *Créer une version* → laissez Google gérer
   la signature (*Play App Signing*, proposé par défaut) → téléversez le
   fichier **`.aab`** (pas l'APK) récupéré sur la branche `apk-build` ou dans
   les Artifacts GitHub Actions.
8. **Envoyer en validation**. Google répond généralement sous 1 à 3 jours
   pour une première publication.

### Textes de fiche Store (à copier-coller)

**Description courte** (80 caractères max) :
```
Actualités, programme, prières audio et vidéos du Centre Christ Vainqueur
```

**Description complète** :
```
L'application officielle du CENTRE DE PRIÈRE CHRIST VAINQUEUR pour rester
connecté à la vie du centre où que vous soyez.

✝️ Verset du jour
Un verset et une courte méditation chaque jour, dès l'ouverture de l'app.

📰 Actualités
Toutes les annonces et actualités du centre, avec notifications pour ne rien
manquer.

📅 Programme
Le calendrier des cultes, veillées, jeûnes et événements spéciaux — avec
l'affiche de chaque événement.

🎧 Prières & prédications
Écoutez ou téléchargez les séances de prière enregistrées, pour les
emporter partout avec vous.

🎬 Vidéos
Retrouvez les dernières vidéos du centre.

Suivez-nous aussi sur YouTube et TikTok directement depuis l'application.
```

**Note** : avant la soumission, remplacez l'icône dans `assets/icon/icon.png`
par une version encore plus haute résolution si vous en avez une (1024×1024
minimum requis par Google Play), et préparez 2 à 8 captures d'écran du
téléphone (faites-les depuis l'app installée : Accueil, Programme, Prières).

### Alternative gratuite, sans Google Play

Si vous voulez distribuer l'app immédiatement sans attendre la validation
Google, l'APK compilé par GitHub Actions (voir ci-dessus) s'installe
directement sur n'importe quel téléphone Android — c'est ce qui vous a déjà
été envoyé dans cette conversation. Seul inconvénient : chaque personne doit
autoriser "installer des applications inconnues" une fois, et il n'y a pas
de mise à jour automatique.
