import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/favorites_provider.dart';
import 'providers/home_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'services/favorites_service.dart';
import 'services/tmdb_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Chargé avant le premier rendu : le thème et les favoris sont prêts dès l'ouverture.
  final prefs = await SharedPreferences.getInstance();
  final tmdb = TmdbService();

  runApp(
    MultiProvider(
      providers: [
        Provider<TmdbService>.value(value: tmdb),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(FavoritesService(prefs))),
        ChangeNotifierProvider(create: (_) => HomeProvider(tmdb)..load()),
        ChangeNotifierProvider(create: (_) => SearchProvider(tmdb)),
      ],
      child: const CinemaxApp(),
    ),
  );
}
