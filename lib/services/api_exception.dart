enum ApiErrorType { missingKey, network, timeout, unauthorized, notFound, quota, server, unknown }

/// Erreur d'API traduite en message lisible par l'utilisateur.
class ApiException implements Exception {
  const ApiException(this.type, [this.details]);

  final ApiErrorType type;
  final String? details;

  String get message => switch (type) {
        ApiErrorType.missingKey =>
          'Clé API TMDB manquante. Lancez l\'application avec --dart-define-from-file=config/tmdb.json.',
        ApiErrorType.network =>
          'Pas de connexion internet. Vérifiez votre réseau puis réessayez.',
        ApiErrorType.timeout => 'Le serveur met trop de temps à répondre. Réessayez dans un instant.',
        ApiErrorType.unauthorized => 'Clé API TMDB invalide ou expirée.',
        ApiErrorType.notFound => 'Ce contenu est introuvable.',
        ApiErrorType.quota => 'Trop de requêtes envoyées. Patientez quelques secondes.',
        ApiErrorType.server => 'Le service TMDB rencontre un problème. Réessayez plus tard.',
        ApiErrorType.unknown => 'Une erreur inattendue est survenue.',
      };

  bool get isOffline => type == ApiErrorType.network || type == ApiErrorType.timeout;

  /// Convertit n'importe quelle erreur en message affichable.
  static String describe(Object error) =>
      error is ApiException ? error.message : const ApiException(ApiErrorType.unknown).message;

  @override
  String toString() => 'ApiException($type${details == null ? '' : ': $details'})';
}
