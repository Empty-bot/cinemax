import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/genre.dart';
import '../providers/home_provider.dart';
import '../theme/app_colors.dart';
import '../utils/page_transitions.dart';
import '../widgets/movie_carousel.dart';
import '../widgets/movie_section.dart';
import '../widgets/section_header.dart';
import '../widgets/state_views.dart';
import 'genre_movies_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final nowPlaying = home.section(MovieCategory.nowPlaying);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => home.load(refresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              titleSpacing: 20,
              title: const _Logo(),
              actions: [
                IconButton(
                  tooltip: 'Rechercher',
                  onPressed: onSearchTap,
                  icon: const Icon(Icons.search_rounded),
                ),
                const SizedBox(width: 8),
              ],
            ),
            if (home.allFailed)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(message: home.firstError!, onRetry: home.load),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 28),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: nowPlaying.data != null
                        ? MovieCarousel(movies: nowPlaying.data!.take(10).toList())
                        : nowPlaying.hasError
                            ? ErrorView(
                                message: nowPlaying.error!,
                                compact: true,
                                onRetry: () => home.loadSection(MovieCategory.nowPlaying),
                              )
                            : const MovieCarouselSkeleton(),
                  ),
                ),
              ),
              if (home.genres.data case final genres? when genres.isNotEmpty)
                SliverToBoxAdapter(child: _GenreChips(genres: genres)),
              for (final category in MovieCategory.values.skip(1))
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 28),
                  sliver: SliverToBoxAdapter(
                    child: MovieSection(
                      title: category.label,
                      state: home.section(category),
                      heroPrefix: category.name,
                      onRetry: () => home.loadSection(category),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDeep]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(
              children: const [
                TextSpan(text: 'Cine'),
                TextSpan(text: 'max', style: TextStyle(color: AppColors.primary)),
              ],
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      );
}

/// Filtrage par genre : chaque puce ouvre la liste des films de ce genre.
class _GenreChips extends StatelessWidget {
  const _GenreChips({required this.genres});

  final List<Genre> genres;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Explorer par genre'),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: genres.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ActionChip(
                  label: Text(genres[i].name),
                  onPressed: () => Navigator.of(context).push(
                    FadeThroughRoute(builder: (_) => GenreMoviesScreen(genre: genres[i])),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
