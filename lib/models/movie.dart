/// Film tel que renvoyé par les listes TMDB (populaires, recherche…).
///
/// Sérialisable en JSON pour être conservé dans les favoris.
class Movie {
  const Movie({
    required this.id,
    required this.title,
    this.overview = '',
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.voteCount = 0,
    this.releaseDate,
    this.genreIds = const [],
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;

  /// Date au format ISO `yyyy-MM-dd`, ou null si inconnue.
  final String? releaseDate;
  final List<int> genreIds;

  factory Movie.fromJson(Map<String, dynamic> json) {
    final date = json['release_date'] as String?;
    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['original_title'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      releaseDate: (date == null || date.isEmpty) ? null : date,
      genreIds: (json['genre_ids'] as List?)?.whereType<int>().toList() ??
          (json['genres'] as List?)
              ?.map((g) => (g as Map<String, dynamic>)['id'])
              .whereType<int>()
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'overview': overview,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'vote_average': voteAverage,
        'vote_count': voteCount,
        'release_date': releaseDate,
        'genre_ids': genreIds,
      };

  DateTime? get releaseDateTime => releaseDate == null ? null : DateTime.tryParse(releaseDate!);

  String? get year => releaseDateTime?.year.toString();

  @override
  bool operator ==(Object other) => other is Movie && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
