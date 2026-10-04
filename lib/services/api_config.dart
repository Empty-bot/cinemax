/// Configuration de l'accès à l'API TMDB.
///
/// Les identifiants sont injectés à la compilation, jamais écrits en dur :
///   flutter run --dart-define-from-file=config/tmdb.json
/// ou
///   flutter run --dart-define=TMDB_API_KEY=xxxx
class ApiConfig {
  ApiConfig._();

  /// Clé API v3 (paramètre `api_key`).
  static const String apiKey = String.fromEnvironment('TMDB_API_KEY');

  /// Jeton de lecture v4 (en-tête `Authorization: Bearer`), alternative à la clé v3.
  static const String readToken = String.fromEnvironment('TMDB_READ_TOKEN');

  static const String host = 'api.themoviedb.org';
  static const String language = 'fr-FR';
  static const Duration timeout = Duration(seconds: 12);

  /// Durée de vie du cache mémoire, pour ménager le quota de la clé gratuite.
  static const Duration cacheTtl = Duration(minutes: 10);

  static bool get hasCredentials => apiKey.isNotEmpty || readToken.isNotEmpty;

  static const String _imageBase = 'https://image.tmdb.org/t/p';

  /// Construit l'URL d'une image TMDB. Tailles usuelles : w185, w342, w500, w780, original.
  static String? imageUrl(String? path, {String size = 'w500'}) =>
      (path == null || path.isEmpty) ? null : '$_imageBase/$size$path';

  static String movieWebUrl(int id) => 'https://www.themoviedb.org/movie/$id';

  static String youtubeUrl(String key) => 'https://www.youtube.com/watch?v=$key';
}
