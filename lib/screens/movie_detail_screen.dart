import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/movie.dart';
import '../models/movie_details.dart';
import '../providers/favorites_provider.dart';
import '../providers/movie_detail_provider.dart';
import '../services/api_config.dart';
import '../services/tmdb_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/page_transitions.dart';
import '../widgets/cast_card.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/poster_image.dart';
import '../widgets/rating_badge.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_views.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movie, this.heroTag});

  /// Données de la liste d'origine, affichées immédiatement pendant le chargement de la fiche.
  final Movie movie;
  final String? heroTag;

  static Future<void> open(BuildContext context, Movie movie, {String? heroTag}) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Navigator.of(context).push(
      FadeThroughRoute(builder: (_) => MovieDetailScreen(movie: movie, heroTag: heroTag)),
    );
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => MovieDetailProvider(context.read<TmdbService>(), movie.id)..load(),
        child: _DetailView(movie: movie, heroTag: heroTag ?? 'detail-${movie.id}'),
      );
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.movie, required this.heroTag});

  final Movie movie;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MovieDetailProvider>().details;
    final details = state.data;
    final current = details?.movie ?? movie;
    final size = MediaQuery.sizeOf(context);
    final backdropHeight = (size.width * 0.62).clamp(220.0, 380.0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _BackdropAppBar(movie: current, height: backdropHeight),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(movie: current, details: details, heroTag: heroTag),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Actions(movie: current, trailerKey: details?.trailerKey),
                ),
                if (state.hasError && details == null) ...[
                  const SizedBox(height: 20),
                  ErrorView(
                    message: state.error!,
                    compact: true,
                    onRetry: context.read<MovieDetailProvider>().load,
                  ),
                ],
                const SizedBox(height: 28),
                _Synopsis(movie: current, tagline: details?.tagline),
                const SizedBox(height: 28),
                _Cast(details: details, loading: state.isLoading),
                SizedBox(height: 32 + MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropAppBar extends StatelessWidget {
  const _BackdropAppBar({required this.movie, required this.height});

  final Movie movie;
  final double height;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: height,
      backgroundColor: background,
      leading: const Padding(padding: EdgeInsets.all(8), child: _CircleButton(child: BackButton(color: Colors.white))),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _CircleButton(
            child: IconButton(
              tooltip: 'Partager',
              color: Colors.white,
              icon: const Icon(Icons.share_rounded),
              onPressed: () => _share(context, movie),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage(path: movie.backdropPath ?? movie.posterPath, size: 'w780'),
            // Dégradé de superposition : fond sombre en haut (lisibilité des boutons)
            // et fondu vers la couleur de l'écran en bas.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.3, 0.7, 1],
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    background.withValues(alpha: 0.5),
                    background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _share(BuildContext context, Movie movie) {
    final box = context.findRenderObject() as RenderBox?;
    final year = movie.year == null ? '' : ' (${movie.year})';
    SharePlus.instance.share(ShareParams(
      subject: movie.title,
      text: '🎬 ${movie.title}$year — ★ ${Formatters.rating(movie.voteAverage)}/10\n'
          'Découvert sur Cinemax : ${ApiConfig.movieWebUrl(movie.id)}',
      sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ));
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.35)),
        child: child,
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.movie, required this.details, required this.heroTag});

  final Movie movie;
  final MovieDetails? details;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posterWidth = (MediaQuery.sizeOf(context).width * 0.32).clamp(110.0, 170.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affiche « en médaillon », remontée sur l'image de fond.
          Transform.translate(
            offset: const Offset(0, -56),
            child: Container(
              width: posterWidth,
              height: posterWidth * 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                boxShadow: [BoxShadow(color: CinemaxColors.of(context).posterShadow, blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Hero(
                tag: heroTag,
                child: PosterImage(path: movie.posterPath, borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FadeSlideIn(
              offset: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingCircle(rating: movie.voteAverage),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          '${movie.voteCount} votes\nsur TMDB',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetaChips(movie: movie, details: details),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.movie, required this.details});

  final Movie movie;
  final MovieDetails? details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = CinemaxColors.of(context).textMuted;

    Widget info(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Icon(icon, size: 15, color: muted),
              const SizedBox(width: 6),
              Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        info(Icons.calendar_today_rounded, Formatters.date(movie.releaseDateTime)),
        if (details != null)
          info(Icons.schedule_rounded, Formatters.runtime(details!.runtime))
        else
          const Shimmer(child: SkeletonBox(width: 80, height: 12)),
        const SizedBox(height: 4),
        if (details != null && details!.genres.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final g in details!.genres)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                  child: Text(g.name, style: theme.textTheme.labelMedium!.copyWith(color: theme.colorScheme.onSurface)),
                ),
            ],
          ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.movie, required this.trailerKey});

  final Movie movie;
  final String? trailerKey;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesProvider, bool>((p) => p.isFavorite(movie.id));

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: isFavorite
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  )
                : null,
            onPressed: () {
              final added = context.read<FavoritesProvider>().toggle(movie);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(added ? 'Ajouté à vos favoris' : 'Retiré de vos favoris'),
                ));
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
              child: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(isFavorite),
                color: isFavorite ? AppColors.primary : null,
              ),
            ),
            label: Text(isFavorite ? 'Dans vos favoris' : 'Ajouter aux favoris'),
          ),
        ),
        if (trailerKey != null) ...[
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => _openTrailer(context, trailerKey!),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Bande-annonce'),
          ),
        ],
      ],
    );
  }

  static Future<void> _openTrailer(BuildContext context, String key) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(Uri.parse(ApiConfig.youtubeUrl(key)), mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir la bande-annonce.')));
    }
  }
}

class _Synopsis extends StatelessWidget {
  const _Synopsis({required this.movie, this.tagline});

  final Movie movie;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Synopsis'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tagline != null) ...[
                Text('« $tagline »', style: theme.textTheme.titleSmall!.copyWith(fontStyle: FontStyle.italic, color: AppColors.primary)),
                const SizedBox(height: 8),
              ],
              Text(
                movie.overview.isEmpty ? 'Aucun synopsis disponible en français pour ce film.' : movie.overview,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Cast extends StatelessWidget {
  const _Cast({required this.details, required this.loading});

  final MovieDetails? details;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final cast = details?.cast;
    if (cast != null && cast.isEmpty) return const SizedBox.shrink();
    if (cast == null && !loading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Casting principal'),
        SizedBox(
          height: 150 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4),
          child: cast == null
              ? Shimmer(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 5,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, _) => const Column(
                      children: [
                        SkeletonBox(width: 76, height: 76, radius: 38),
                        SizedBox(height: 8),
                        SkeletonBox(width: 64, height: 10),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cast.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => FadeSlideIn(index: i, child: CastCard(member: cast[i])),
                ),
        ),
      ],
    );
  }
}
