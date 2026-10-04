import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/api_exception.dart';
import '../services/tmdb_service.dart';
import 'load_state.dart';

/// Recherche « au fil de la saisie » avec anti-rebond pour économiser le quota TMDB.
class SearchProvider extends ChangeNotifier {
  SearchProvider(this._api);

  static const debounce = Duration(milliseconds: 450);

  final TmdbService _api;
  Timer? _debounce;
  int _requestId = 0;

  String _query = '';
  LoadState<List<Movie>> _results = const LoadState.idle();

  String get query => _query;
  LoadState<List<Movie>> get results => _results;

  void onQueryChanged(String value) {
    final query = value.trim();
    if (query == _query) return;
    _query = query;
    _debounce?.cancel();

    if (query.isEmpty) {
      _requestId++; // Invalide toute réponse encore en vol.
      _results = const LoadState.idle();
      notifyListeners();
      return;
    }

    _results = LoadState.loading(_results.data);
    notifyListeners();
    _debounce = Timer(debounce, _run);
  }

  Future<void> retry() => _run();

  Future<void> _run() async {
    if (_query.isEmpty) return;
    final id = ++_requestId;
    _results = LoadState.loading(_results.data);
    notifyListeners();
    try {
      final page = await _api.search(_query);
      if (id != _requestId) return; // Une saisie plus récente a pris le relais.
      _results = LoadState.success(page.movies);
    } catch (e) {
      if (id != _requestId) return;
      _results = LoadState.error(ApiException.describe(e));
    }
    notifyListeners();
  }

  void clear() => onQueryChanged('');

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
