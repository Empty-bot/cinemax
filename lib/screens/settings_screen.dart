import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/theme_provider.dart';
import '../services/api_config.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final muted = CinemaxColors.of(context).textMuted;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        toolbarHeight: 72,
        title: Text('Paramètres', style: theme.textTheme.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _Label('APPARENCE'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thème', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('« Système » suit automatiquement le réglage du téléphone.', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: AppColors.primary,
                        selectedForegroundColor: Colors.white,
                      ),
                      segments: const [
                        ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_rounded), label: Text('Système')),
                        ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded), label: Text('Clair')),
                        ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_rounded), label: Text('Sombre')),
                      ],
                      selected: {themeProvider.mode},
                      onSelectionChanged: (s) => themeProvider.setMode(s.first),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          _Label('À PROPOS'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.movie_filter_rounded, color: AppColors.primary),
                  title: const Text('Cinemax'),
                  subtitle: const Text('Version $appVersion'),
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('Application de découverte de films'),
                  subtitle: const Text('Projet de fin de module — Développement d\'applications mobiles (Flutter)'),
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(
                    ApiConfig.hasCredentials ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    color: ApiConfig.hasCredentials ? AppColors.ratingHigh : AppColors.ratingLow,
                  ),
                  title: const Text('Clé API TMDB'),
                  subtitle: Text(ApiConfig.hasCredentials ? 'Configurée' : 'Non configurée — voir le README'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _Label('SOURCE DES DONNÉES'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('The Movie Database (TMDB)', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Les informations et images des films proviennent de l\'API TMDB. '
                    'Ce produit utilise l\'API TMDB mais n\'est ni approuvé ni certifié par TMDB.',
                    style: theme.textTheme.bodySmall!.copyWith(color: muted),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () => launchUrl(Uri.parse('https://www.themoviedb.org'), mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('themoviedb.org'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(text, style: Theme.of(context).textTheme.labelSmall),
      );
}
