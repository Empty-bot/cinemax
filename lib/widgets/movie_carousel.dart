import 'dart:async';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../screens/movie_detail_screen.dart';
import '../theme/app_colors.dart';
import 'poster_image.dart';
import 'pressable.dart';
import 'rating_badge.dart';
import 'skeleton.dart';

/// Carrousel automatique des films à l'affiche, en grand format.
class MovieCarousel extends StatefulWidget {
  const MovieCarousel({super.key, required this.movies, this.heroPrefix = 'carousel'});

  final List<Movie> movies;
  final String heroPrefix;

  static double heightFor(BuildContext context) =>
      (MediaQuery.sizeOf(context).width * 0.62).clamp(210.0, 340.0);

  @override
  State<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel> {
  static const _interval = Duration(seconds: 5);

  // Index de départ élevé pour permettre un défilement « infini » dans les deux sens.
  late final int _base = widget.movies.length * 500;
  late final PageController _controller = PageController(viewportFraction: 0.88, initialPage: _base);
  late int _page = _base;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.nextPage(duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movies = widget.movies;
    if (movies.isEmpty) return const SizedBox.shrink();
    final current = _page % movies.length;

    return Column(
      children: [
        SizedBox(
          height: MovieCarousel.heightFor(context),
          child: NotificationListener<ScrollStartNotification>(
            // L'utilisateur reprend la main : on remet le minuteur à zéro.
            onNotification: (n) {
              if (n.dragDetails != null) _restartTimer();
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (p) => setState(() => _page = p),
              itemBuilder: (context, index) {
                final movie = movies[index % movies.length];
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    var delta = 0.0;
                    if (_controller.position.haveDimensions) {
                      delta = (_controller.page! - index).abs().clamp(0.0, 1.0);
                    } else {
                      delta = index == _page ? 0 : 1;
                    }
                    return Transform.scale(scale: 1 - delta * 0.08, child: child);
                  },
                  child: _CarouselSlide(movie: movie, heroTag: '${widget.heroPrefix}-$index-${movie.id}'),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < movies.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == current ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == current
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CarouselSlide extends StatelessWidget {
  const _CarouselSlide({required this.movie, required this.heroTag});

  final Movie movie;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Pressable(
      scale: 0.97,
      onTap: () => MovieDetailScreen.open(context, movie, heroTag: heroTag),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PosterImage(path: movie.backdropPath ?? movie.posterPath, size: 'w780'),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.3, 1],
                    colors: [Colors.transparent, Color(0xE6000000)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 108,
                      child: Hero(
                        tag: heroTag,
                        child: PosterImage(path: movie.posterPath, size: 'w185', borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('À L\'AFFICHE', style: textTheme.labelSmall!.copyWith(color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineSmall!.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              RatingBadge(rating: movie.voteAverage),
                              if (movie.year != null) ...[
                                const SizedBox(width: 8),
                                Text(movie.year!, style: textTheme.bodySmall!.copyWith(color: Colors.white70)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieCarouselSkeleton extends StatelessWidget {
  const MovieCarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Shimmer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.06 + 6),
          child: Column(
            children: [
              SkeletonBox(height: MovieCarousel.heightFor(context), radius: 22),
              const SizedBox(height: 14),
              const SkeletonBox(width: 60, height: 6),
            ],
          ),
        ),
      );
}
