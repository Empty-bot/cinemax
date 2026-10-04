import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/movie.dart';
import '../screens/movie_detail_screen.dart';
import '../theme/app_colors.dart';
import 'poster_image.dart';
import 'pressable.dart';
import 'rating_badge.dart';

/// Carte affiche + note + titre. [heroTag] doit être unique dans l'écran courant.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, required this.heroTag, this.width});

  final Movie movie;
  final String heroTag;

  /// Largeur fixe (listes horizontales) ; null pour remplir la cellule d'une grille.
  final double? width;

  /// Hauteur réservée sous l'affiche : deux lignes de titre + année.
  static double infoHeight(BuildContext context) => 72 * MediaQuery.textScalerOf(context).scale(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = CinemaxColors.of(context);

    return Pressable(
      onTap: () => MovieDetailScreen.open(context, movie, heroTag: heroTag),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: colors.posterShadow, blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: heroTag,
                      child: PosterImage(path: movie.posterPath, borderRadius: BorderRadius.circular(14)),
                    ),
                    Positioned(top: 8, left: 8, child: RatingBadge(rating: movie.voteAverage)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
            if (movie.year != null) ...[
              const SizedBox(height: 2),
              Text(movie.year!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

/// Grille de [MovieCard] : la hauteur des cellules suit leur largeur réelle
/// (affiche 2:3) plus [infoHeight], pour que titre et année tiennent toujours.
class MovieGridDelegate extends SliverGridDelegateWithMaxCrossAxisExtent {
  const MovieGridDelegate({required this.infoHeight})
      : super(maxCrossAxisExtent: 170, mainAxisSpacing: 20, crossAxisSpacing: 14);

  final double infoHeight;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final base = super.getLayout(constraints) as SliverGridRegularTileLayout;
    final extent = base.childCrossAxisExtent * 1.5 + infoHeight;
    return SliverGridRegularTileLayout(
      crossAxisCount: base.crossAxisCount,
      mainAxisStride: extent + mainAxisSpacing,
      crossAxisStride: base.crossAxisStride,
      childMainAxisExtent: extent,
      childCrossAxisExtent: base.childCrossAxisExtent,
      reverseCrossAxis: base.reverseCrossAxis,
    );
  }

  @override
  bool shouldRelayout(covariant MovieGridDelegate oldDelegate) =>
      super.shouldRelayout(oldDelegate) || oldDelegate.infoHeight != infoHeight;
}
