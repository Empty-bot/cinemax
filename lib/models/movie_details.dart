import 'cast_member.dart';
import 'genre.dart';
import 'movie.dart';

/// Fiche complète d'un film : `/movie/{id}?append_to_response=credits,videos`.
class MovieDetails {
  const MovieDetails({
    required this.movie,
    this.tagline,
    this.runtime,
    this.genres = const [],
    this.cast = const [],
    this.trailerKey,
  });

  final Movie movie;
  final String? tagline;

  /// Durée en minutes.
  final int? runtime;
  final List<Genre> genres;
  final List<CastMember> cast;

  /// Identifiant de la bande-annonce YouTube, s'il en existe une.
  final String? trailerKey;

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    final credits = json['credits'] as Map<String, dynamic>?;
    final videos = (json['videos'] as Map<String, dynamic>?)?['results'] as List? ?? const [];
    final tagline = json['tagline'] as String?;
    final runtime = (json['runtime'] as num?)?.toInt();

    return MovieDetails(
      movie: Movie.fromJson(json),
      tagline: (tagline == null || tagline.isEmpty) ? null : tagline,
      runtime: (runtime == null || runtime == 0) ? null : runtime,
      genres: (json['genres'] as List? ?? const [])
          .map((g) => Genre.fromJson(g as Map<String, dynamic>))
          .toList(),
      cast: (credits?['cast'] as List? ?? const [])
          .take(15)
          .map((c) => CastMember.fromJson(c as Map<String, dynamic>))
          .toList(),
      trailerKey: _pickTrailer(videos.cast<Map<String, dynamic>>()),
    );
  }

  /// Privilégie une bande-annonce officielle YouTube, puis tout teaser YouTube.
  static String? _pickTrailer(List<Map<String, dynamic>> videos) {
    final youtube = videos.where((v) => v['site'] == 'YouTube').toList();
    int score(Map<String, dynamic> v) =>
        (v['type'] == 'Trailer' ? 2 : 0) + (v['official'] == true ? 1 : 0);
    youtube.sort((a, b) => score(b).compareTo(score(a)));
    return youtube.isEmpty ? null : youtube.first['key'] as String?;
  }
}
