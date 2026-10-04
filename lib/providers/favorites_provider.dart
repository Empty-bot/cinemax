import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._service) : _movies = _service.load();

  final FavoritesService _service;
  final List<Movie> _movies;

  /// Favoris, du plus récemment ajouté au plus ancien.
  List<Movie> get movies => List.unmodifiable(_movies);
  int get count => _movies.length;
  bool get isEmpty => _movies.isEmpty;

  bool isFavorite(int movieId) => _movies.any((m) => m.id == movieId);

  /// Ajoute ou retire le film ; renvoie true s'il est désormais en favori.
  bool toggle(Movie movie) {
    final added = !isFavorite(movie.id);
    added ? _movies.insert(0, movie) : _movies.removeWhere((m) => m.id == movie.id);
    _commit();
    return added;
  }

  /// Retire un film et renvoie sa position, pour pouvoir annuler la suppression.
  int remove(Movie movie) {
    final index = _movies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _movies.removeAt(index);
      _commit();
    }
    return index;
  }

  void restore(Movie movie, int index) {
    if (isFavorite(movie.id)) return;
    _movies.insert(index.clamp(0, _movies.length), movie);
    _commit();
  }

  void _commit() {
    notifyListeners();
    _service.save(_movies);
  }
}
