import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/genre.dart';
import '../models/movie.dart';
import '../models/movie_details.dart';
import 'api_config.dart';
import 'api_exception.dart';

/// Une page de résultats TMDB.
class MoviePage {
  const MoviePage({required this.movies, required this.page, required this.totalPages});

  final List<Movie> movies;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

/// Accès à l'API REST TMDB, avec cache mémoire pour limiter la consommation du quota.
class TmdbService {
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, ({DateTime at, Map<String, dynamic> body})> _cache = {};

  Future<MoviePage> nowPlaying({int page = 1}) => _moviePage('/movie/now_playing', page: page);
  Future<MoviePage> popular({int page = 1}) => _moviePage('/movie/popular', page: page);
  Future<MoviePage> topRated({int page = 1}) => _moviePage('/movie/top_rated', page: page);
  Future<MoviePage> upcoming({int page = 1}) => _moviePage('/movie/upcoming', page: page);

  Future<MoviePage> search(String query, {int page = 1}) =>
      _moviePage('/search/movie', page: page, params: {'query': query, 'include_adult': 'false'});

  Future<MoviePage> byGenre(int genreId, {int page = 1}) => _moviePage(
        '/discover/movie',
        page: page,
        params: {'with_genres': '$genreId', 'sort_by': 'popularity.desc'},
      );

  Future<List<Genre>> genres() async {
    final json = await _get('/genre/movie/list');
    return (json['genres'] as List)
        .map((g) => Genre.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  Future<MovieDetails> movieDetails(int id) async {
    final json = await _get('/movie/$id', {
      'append_to_response': 'credits,videos',
      // Beaucoup de bandes-annonces n'existent qu'en anglais.
      'include_video_language': 'fr,en,null',
    });
    return MovieDetails.fromJson(json);
  }

  Future<MoviePage> _moviePage(String path, {int page = 1, Map<String, String> params = const {}}) async {
    final json = await _get(path, {...params, 'page': '$page'});
    final results = (json['results'] as List? ?? const [])
        .map((m) => Movie.fromJson(m as Map<String, dynamic>))
        .toList();
    return MoviePage(
      movies: results,
      page: (json['page'] as num?)?.toInt() ?? page,
      // TMDB refuse les pages au-delà de 500.
      totalPages: ((json['total_pages'] as num?)?.toInt() ?? 1).clamp(1, 500),
    );
  }

  Future<Map<String, dynamic>> _get(String path, [Map<String, String> params = const {}]) async {
    if (!ApiConfig.hasCredentials) throw const ApiException(ApiErrorType.missingKey);

    final uri = Uri.https(ApiConfig.host, '/3$path', {
      'language': ApiConfig.language,
      ...params,
      if (ApiConfig.apiKey.isNotEmpty) 'api_key': ApiConfig.apiKey,
    });

    final key = uri.toString();
    final cached = _cache[key];
    if (cached != null && DateTime.now().difference(cached.at) < ApiConfig.cacheTtl) {
      return cached.body;
    }

    final http.Response response;
    try {
      response = await _client.get(uri, headers: {
        'Accept': 'application/json',
        if (ApiConfig.readToken.isNotEmpty) 'Authorization': 'Bearer ${ApiConfig.readToken}',
      }).timeout(ApiConfig.timeout);
    } on SocketException catch (e) {
      throw ApiException(ApiErrorType.network, e.message);
    } on http.ClientException catch (e) {
      throw ApiException(ApiErrorType.network, e.message);
    } on TimeoutException {
      throw const ApiException(ApiErrorType.timeout);
    }

    switch (response.statusCode) {
      case 200:
        final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _cache[key] = (at: DateTime.now(), body: body);
        return body;
      case 401:
        throw const ApiException(ApiErrorType.unauthorized);
      case 404:
        throw const ApiException(ApiErrorType.notFound);
      case 429:
        throw const ApiException(ApiErrorType.quota);
      default:
        throw ApiException(
          response.statusCode >= 500 ? ApiErrorType.server : ApiErrorType.unknown,
          'HTTP ${response.statusCode}',
        );
    }
  }

  void clearCache() => _cache.clear();
}
