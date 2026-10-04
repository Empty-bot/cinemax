# Cinemax

Application mobile Flutter de découverte de films, basée sur l'API [TMDB](https://www.themoviedb.org).
Projet de fin de module — Développement d'applications mobiles (Flutter).

## Fonctionnalités

| Écran | Contenu |
| --- | --- |
| Accueil | Carrousel automatique « À l'affiche », puces de genres, sections Populaires / Mieux notés / À venir, tirer pour rafraîchir |
| Recherche | Résultats en temps réel (anti-rebond 450 ms), grille responsive, états vide / chargement / erreur |
| Détail | Backdrop avec dégradé, affiche en médaillon (Hero), note animée (CustomPainter), durée, date, genres, synopsis, casting, favoris, bande-annonce YouTube, partage |
| Favoris | Liste persistée localement (consultable hors-ligne), suppression par glissement ou bouton, annulation |
| Paramètres | Thème Système / Clair / Sombre (mémorisé), à propos, source des données |
| Genre | Films d'un genre, chargement progressif au défilement |

## Configuration de la clé API TMDB

1. Créez un compte sur themoviedb.org, puis demandez une clé dans *Paramètres → API*.
2. Copiez le modèle et renseignez votre clé :
   ```bash
   cp config/tmdb.example.json config/tmdb.json
   ```
   Renseignez `TMDB_API_KEY` (clé v3) **ou** `TMDB_READ_TOKEN` (jeton v4).
   `config/tmdb.json` est ignoré par Git.
3. Lancez l'application :
   ```bash
   flutter pub get
   flutter run --dart-define-from-file=config/tmdb.json
   ```
   Générer l'APK :
   ```bash
   flutter build apk --release --dart-define-from-file=config/tmdb.json
   ```

Sans clé, l'application démarre et affiche un message d'erreur explicite.

## Architecture

```
lib/
├── main.dart              # Initialisation + injection des providers
├── app.dart               # MaterialApp, thèmes clair/sombre
├── models/                # Movie, MovieDetails, Genre, CastMember
├── services/              # TmdbService (http + cache), FavoritesService (shared_preferences), erreurs
├── providers/             # Thème, favoris, accueil, recherche, détail, genre (Provider/ChangeNotifier)
├── theme/                 # Couleurs, typographie, ThemeData, ThemeExtension
├── screens/               # Navigation principale + 6 écrans
├── widgets/               # Carte, carrousel, section, note, squelettes, états vide/erreur…
└── utils/                 # Formatage FR, transition de page personnalisée
```

**Choix techniques** : `provider`, `http`, `shared_preferences`, `cached_network_image`,
`url_launcher` (bande-annonce), `share_plus` (partage).

**Quota TMDB** : cache mémoire de 10 min par requête, anti-rebond sur la recherche,
annulation logique des réponses obsolètes.

**Réseau** : chaque section se charge et échoue indépendamment ; les erreurs sont traduites
en messages clairs avec un bouton « Réessayer ».

## Tests

```bash
flutter test
```
