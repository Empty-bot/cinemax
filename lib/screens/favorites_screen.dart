import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/poster_image.dart';
import '../widgets/pressable.dart';
import '../widgets/rating_badge.dart';
import '../widgets/state_views.dart';
import 'movie_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final movies = favorites.movies;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mes favoris', style: Theme.of(context).textTheme.headlineMedium),
            if (movies.isNotEmpty)
              Text(
                '${movies.length} film${movies.length > 1 ? 's' : ''} à voir',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: movies.isEmpty
            ? const EmptyState(
                key: ValueKey('empty'),
                icon: Icons.favorite_border_rounded,
                title: 'Aucun favori pour l\'instant',
                message: 'Touchez « Ajouter aux favoris » sur la fiche d\'un film pour le retrouver ici, même hors connexion.',
              )
            : ListView.separated(
                key: const ValueKey('list'),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: movies.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _FavoriteTile(movie: movies[i]),
              ),
      ),
    );
  }

  static void remove(BuildContext context, Movie movie) {
    final provider = context.read<FavoritesProvider>();
    final index = provider.remove(movie);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('« ${movie.title} » retiré des favoris'),
        action: SnackBarAction(label: 'Annuler', onPressed: () => provider.restore(movie, index)),
      ));
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroTag = 'favorite-${movie.id}';

    return Dismissible(
      key: ValueKey(movie.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => FavoritesScreen.remove(context, movie),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Retirer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white),
          ],
        ),
      ),
      child: Pressable(
        scale: 0.98,
        onTap: () => MovieDetailScreen.open(context, movie, heroTag: heroTag),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  height: 105,
                  child: Hero(
                    tag: heroTag,
                    child: PosterImage(path: movie.posterPath, size: 'w185', borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          RatingBadge(rating: movie.voteAverage),
                          if (movie.year != null) ...[
                            const SizedBox(width: 8),
                            Text(movie.year!, style: theme.textTheme.bodySmall),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(movie.overview, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Retirer des favoris',
                  icon: const Icon(Icons.favorite_rounded, color: AppColors.primary),
                  onPressed: () => FavoritesScreen.remove(context, movie),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
