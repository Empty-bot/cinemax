import 'package:flutter/foundation.dart';

import '../models/genre.dart';
import '../models/movie.dart';
import '../services/api_exception.dart';
import '../services/tmdb_service.dart';

/// Liste paginée des films d'un genre (filtrage par genre).
class GenreMoviesProvider extends ChangeNotifier {
  GenreMoviesProvider(this._api, this.genre);

  final TmdbService _api;
  final Genre genre;

  final List<Movie> _movies = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;

  List<Movie> get movies => List.unmodifiable(_movies);
  bool get isLoading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadMore() async {
    if (_loading || !_hasMore) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _api.byGenre(genre.id, page: _page + 1);
      _page = page.page;
      _hasMore = page.hasMore;
      // Les pages TMDB peuvent se chevaucher : on évite les doublons (et les tags Hero en double).
      final known = _movies.map((m) => m.id).toSet();
      _movies.addAll(page.movies.where((m) => known.add(m.id)));
    } catch (e) {
      _error = ApiException.describe(e);
    }
    _loading = false;
    notifyListeners();
  }
}
