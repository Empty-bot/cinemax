import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/genre.dart';
import '../providers/genre_movies_provider.dart';
import '../services/tmdb_service.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/movie_card.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_views.dart';

/// Films d'un genre donné, avec chargement progressif au défilement.
class GenreMoviesScreen extends StatelessWidget {
  const GenreMoviesScreen({super.key, required this.genre});

  final Genre genre;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => GenreMoviesProvider(context.read<TmdbService>(), genre)..loadMore(),
        child: Scaffold(
          appBar: AppBar(title: Text(genre.name)),
          body: const _GenreGrid(),
        ),
      );
}

class _GenreGrid extends StatelessWidget {
  const _GenreGrid();

  @override
  Widget build(BuildContext context) {
    final delegate = MovieGridDelegate(infoHeight: MovieCard.infoHeight(context));
    final provider = context.watch<GenreMoviesProvider>();
    final movies = provider.movies;

    if (movies.isEmpty && provider.error != null) {
      return ErrorView(message: provider.error!, onRetry: provider.loadMore);
    }
    if (movies.isEmpty && !provider.isLoading && !provider.hasMore) {
      return const EmptyState(
        icon: Icons.local_movies_outlined,
        title: 'Aucun film',
        message: 'Aucun film trouvé pour ce genre.',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 600) provider.loadMore();
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            sliver: movies.isEmpty
                ? SliverGrid.builder(
                    gridDelegate: delegate,
                    itemCount: 9,
                    itemBuilder: (_, _) => Shimmer(
                      child: LayoutBuilder(builder: (_, c) => MovieCardSkeleton(width: c.maxWidth)),
                    ),
                  )
                : SliverGrid.builder(
                    gridDelegate: delegate,
                    itemCount: movies.length,
                    itemBuilder: (context, i) => FadeSlideIn(
                      index: i % 20,
                      offset: 0,
                      child: MovieCard(movie: movies[i], heroTag: 'genre-${movies[i].id}'),
                    ),
                  ),
          ),
          if (movies.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: provider.error != null
                    ? ErrorView(message: provider.error!, onRetry: provider.loadMore, compact: true)
                    : provider.hasMore
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}
