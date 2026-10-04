import 'package:flutter/foundation.dart';

import '../models/genre.dart';
import '../models/movie.dart';
import '../services/api_exception.dart';
import '../services/tmdb_service.dart';
import 'load_state.dart';

enum MovieCategory {
  nowPlaying('À l\'affiche'),
  popular('Populaires'),
  topRated('Les mieux notés'),
  upcoming('Bientôt au cinéma');

  const MovieCategory(this.label);
  final String label;
}

/// Données de l'écran d'accueil : une section par catégorie, chargées indépendamment
/// pour qu'une erreur sur l'une n'empêche pas d'afficher les autres.
class HomeProvider extends ChangeNotifier {
  HomeProvider(this._api);

  final TmdbService _api;
  final Map<MovieCategory, LoadState<List<Movie>>> _sections = {
    for (final c in MovieCategory.values) c: const LoadState.idle(),
  };
  LoadState<List<Genre>> _genres = const LoadState.idle();

  LoadState<List<Movie>> section(MovieCategory category) => _sections[category]!;
  LoadState<List<Genre>> get genres => _genres;

  /// Vrai si tout a échoué et que rien n'est affichable : on montre alors une erreur plein écran.
  bool get allFailed => _sections.values.every((s) => s.hasError && !s.hasData);

  String? get firstError => _sections.values.firstWhere((s) => s.hasError, orElse: () => const LoadState.idle()).error;

  Future<void> load({bool refresh = false}) async {
    if (refresh) _api.clearCache();
    await Future.wait([
      for (final c in MovieCategory.values) loadSection(c),
      _loadGenres(),
    ]);
  }

  Future<void> loadSection(MovieCategory category) async {
    _sections[category] = LoadState.loading(_sections[category]!.data);
    notifyListeners();
    try {
      final page = await switch (category) {
        MovieCategory.nowPlaying => _api.nowPlaying(),
        MovieCategory.popular => _api.popular(),
        MovieCategory.topRated => _api.topRated(),
        MovieCategory.upcoming => _api.upcoming(),
      };
      _sections[category] = LoadState.success(page.movies);
    } catch (e) {
      _sections[category] = LoadState.error(ApiException.describe(e), _sections[category]!.data);
    }
    notifyListeners();
  }

  Future<void> _loadGenres() async {
    _genres = LoadState.loading(_genres.data);
    notifyListeners();
    try {
      _genres = LoadState.success(await _api.genres());
    } catch (e) {
      _genres = LoadState.error(ApiException.describe(e), _genres.data);
    }
    notifyListeners();
  }
}
