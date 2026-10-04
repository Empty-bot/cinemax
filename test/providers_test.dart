import 'package:cinemax/models/movie.dart';
import 'package:cinemax/providers/favorites_provider.dart';
import 'package:cinemax/providers/theme_provider.dart';
import 'package:cinemax/services/favorites_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const dune = Movie(id: 1, title: 'Dune');
  const alien = Movie(id: 2, title: 'Alien');

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('les favoris sont ajoutés, retirés, restaurés et persistés', () async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = FavoritesProvider(FavoritesService(prefs));

    expect(favorites.toggle(dune), isTrue);
    expect(favorites.toggle(alien), isTrue);
    expect(favorites.movies.map((m) => m.id), [2, 1]); // plus récent en premier

    final index = favorites.remove(alien);
    expect(favorites.isFavorite(2), isFalse);
    favorites.restore(alien, index);
    expect(favorites.movies.first.id, 2);

    expect(favorites.toggle(dune), isFalse);
    await Future<void>.delayed(Duration.zero);

    final reloaded = FavoritesProvider(FavoritesService(prefs));
    expect(reloaded.movies.map((m) => m.title), ['Alien']);
  });

  test('le thème est sombre par défaut et le choix est mémorisé', () async {
    final prefs = await SharedPreferences.getInstance();
    final theme = ThemeProvider(prefs);
    expect(theme.mode, ThemeMode.dark);

    await theme.setMode(ThemeMode.light);
    expect(ThemeProvider(prefs).mode, ThemeMode.light);
  });
}
