import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../providers/load_state.dart';
import 'fade_slide_in.dart';
import 'movie_card.dart';
import 'section_header.dart';
import 'skeleton.dart';
import 'state_views.dart';

/// Section horizontale défilante d'une catégorie de films.
class MovieSection extends StatelessWidget {
  const MovieSection({
    super.key,
    required this.title,
    required this.state,
    required this.heroPrefix,
    this.onRetry,
  });

  final String title;
  final LoadState<List<Movie>> state;
  final String heroPrefix;
  final VoidCallback? onRetry;

  static double cardWidthFor(BuildContext context) =>
      (MediaQuery.sizeOf(context).width / 3.3).clamp(108.0, 160.0);

  @override
  Widget build(BuildContext context) {
    final cardWidth = cardWidthFor(context);
    final height = cardWidth * 1.5 + MovieCard.infoHeight(context);
    final movies = state.data;

    final Widget body;
    if (movies == null && state.hasError) {
      body = ErrorView(message: state.error!, onRetry: onRetry, compact: true);
    } else if (movies == null) {
      body = SizedBox(
        height: height,
        child: Shimmer(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, _) => MovieCardSkeleton(width: cardWidth),
          ),
        ),
      );
    } else if (movies.isEmpty) {
      body = const SizedBox.shrink();
    } else {
      body = SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: movies.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (context, i) => FadeSlideIn(
            index: i,
            child: MovieCard(movie: movies[i], width: cardWidth, heroTag: '$heroPrefix-${movies[i].id}'),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        AnimatedSwitcher(duration: const Duration(milliseconds: 350), child: body),
      ],
    );
  }
}
