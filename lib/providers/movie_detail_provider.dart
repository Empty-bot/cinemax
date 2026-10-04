import 'package:flutter/foundation.dart';

import '../models/movie_details.dart';
import '../services/api_exception.dart';
import '../services/tmdb_service.dart';
import 'load_state.dart';

/// État de l'écran de détail, créé pour chaque film ouvert.
class MovieDetailProvider extends ChangeNotifier {
  MovieDetailProvider(this._api, this.movieId);

  final TmdbService _api;
  final int movieId;

  LoadState<MovieDetails> _details = const LoadState.idle();
  LoadState<MovieDetails> get details => _details;

  Future<void> load() async {
    _details = LoadState.loading(_details.data);
    notifyListeners();
    try {
      _details = LoadState.success(await _api.movieDetails(movieId));
    } catch (e) {
      _details = LoadState.error(ApiException.describe(e), _details.data);
    }
    notifyListeners();
  }
}
