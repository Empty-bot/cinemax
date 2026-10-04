import 'package:cinemax/models/movie.dart';
import 'package:cinemax/models/movie_details.dart';
import 'package:cinemax/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Movie', () {
    test('parse une entrée de liste TMDB et survit à un aller-retour JSON', () {
      final movie = Movie.fromJson({
        'id': 42,
        'title': 'Dune',
        'overview': 'Sur Arrakis…',
        'poster_path': '/p.jpg',
        'backdrop_path': null,
        'vote_average': 8.2,
        'vote_count': 1200,
        'release_date': '2021-09-15',
        'genre_ids': [878, 12],
      });

      expect(movie.year, '2021');
      expect(movie.genreIds, [878, 12]);
      final copy = Movie.fromJson(movie.toJson());
      expect(copy.title, 'Dune');
      expect(copy.voteAverage, 8.2);
      expect(copy.releaseDate, '2021-09-15');
    });

    test('date de sortie vide traitée comme inconnue', () {
      final movie = Movie.fromJson({'id': 1, 'title': 'X', 'release_date': ''});
      expect(movie.releaseDate, isNull);
      expect(movie.year, isNull);
    });
  });

  test('MovieDetails choisit la bande-annonce YouTube officielle', () {
    final details = MovieDetails.fromJson({
      'id': 1,
      'title': 'X',
      'runtime': 0,
      'genres': [
        {'id': 28, 'name': 'Action'},
      ],
      'credits': {
        'cast': [
          {'id': 7, 'name': 'Zendaya', 'character': 'Chani', 'profile_path': null},
        ],
      },
      'videos': {
        'results': [
          {'site': 'YouTube', 'type': 'Teaser', 'official': true, 'key': 'teaser'},
          {'site': 'Vimeo', 'type': 'Trailer', 'official': true, 'key': 'vimeo'},
          {'site': 'YouTube', 'type': 'Trailer', 'official': true, 'key': 'trailer'},
        ],
      },
    });

    expect(details.trailerKey, 'trailer');
    expect(details.runtime, isNull);
    expect(details.genres.single.name, 'Action');
    expect(details.cast.single.character, 'Chani');
  });

  group('Formatters', () {
    test('durée', () {
      expect(Formatters.runtime(135), '2 h 15 min');
      expect(Formatters.runtime(120), '2 h');
      expect(Formatters.runtime(45), '45 min');
      expect(Formatters.runtime(null), '—');
    });

    test('date en français', () {
      expect(Formatters.date(DateTime(2024, 3, 12)), '12 mars 2024');
      expect(Formatters.date(null), 'Date inconnue');
    });
  });
}
