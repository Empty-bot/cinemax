import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

/// Persistance locale des favoris (films complets, pour un affichage hors-ligne).
class FavoritesService {
  FavoritesService(this._prefs);

  static const _key = 'favorites_v1';
  final SharedPreferences _prefs;

  List<Movie> load() {
    final raw = _prefs.getStringList(_key) ?? const [];
    final movies = <Movie>[];
    for (final entry in raw) {
      try {
        movies.add(Movie.fromJson(jsonDecode(entry) as Map<String, dynamic>));
      } on FormatException {
        // Entrée corrompue : on l'ignore plutôt que de perdre toute la liste.
      }
    }
    return movies;
  }

  Future<void> save(List<Movie> movies) =>
      _prefs.setStringList(_key, movies.map((m) => jsonEncode(m.toJson())).toList());
}
