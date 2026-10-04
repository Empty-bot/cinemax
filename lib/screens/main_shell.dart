import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

/// Squelette de navigation : barre d'onglets inférieure, chaque onglet garde son état.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _searchFocus = FocusNode();

  void _select(int index) {
    if (index == _index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _index = index);
  }

  void _openSearch() {
    _select(1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesCount = context.select<FavoritesProvider, int>((p) => p.count);

    return PopScope(
      // Le bouton retour ramène d'abord à l'accueil avant de quitter l'application.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onSearchTap: _openSearch),
            SearchScreen(focusNode: _searchFocus),
            const FavoritesScreen(),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            const NavigationDestination(
              icon: Icon(Icons.search_rounded),
              label: 'Recherche',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: favoritesCount > 0,
                label: Text('$favoritesCount'),
                child: const Icon(Icons.favorite_border_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: favoritesCount > 0,
                label: Text('$favoritesCount'),
                child: const Icon(Icons.favorite_rounded),
              ),
              label: 'Favoris',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }
}
