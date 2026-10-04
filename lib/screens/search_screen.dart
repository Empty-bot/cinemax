import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/load_state.dart';
import '../providers/search_provider.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/movie_card.dart';
import '../widgets/search_field.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_views.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.focusNode});

  final FocusNode? focusNode;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final _controller = TextEditingController(text: context.read<SearchProvider>().query);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<SearchProvider>();
    final results = search.results;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text('Recherche', style: Theme.of(context).textTheme.headlineMedium),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: CinemaxSearchField(
                controller: _controller,
                focusNode: widget.focusNode,
                onChanged: search.onQueryChanged,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _body(search.query, results, search.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(String query, LoadState<List<Movie>> results, VoidCallback retry) {
    if (query.isEmpty) {
      return const EmptyState(
        key: ValueKey('idle'),
        icon: Icons.manage_search_rounded,
        title: 'Trouvez votre prochain film',
        message: 'Saisissez un titre : les résultats s\'affichent au fil de la frappe.',
      );
    }
    if (results.hasError) {
      return ErrorView(key: const ValueKey('error'), message: results.error!, onRetry: retry);
    }
    if (results.isLoading && !results.hasData) {
      return const _GridSkeleton(key: ValueKey('loading'));
    }
    final movies = results.data ?? const [];
    if (movies.isEmpty && !results.isLoading) {
      return EmptyState(
        key: const ValueKey('empty'),
        icon: Icons.search_off_rounded,
        title: 'Aucun résultat',
        message: 'Aucun film ne correspond à « $query ». Vérifiez l\'orthographe ou essayez un autre titre.',
      );
    }
    return Stack(
      key: const ValueKey('results'),
      children: [
        _MovieGrid(movies: movies, heroPrefix: 'search'),
        // Les anciens résultats restent visibles pendant la nouvelle requête.
        if (results.isLoading) const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}

class _MovieGrid extends StatelessWidget {
  const _MovieGrid({required this.movies, required this.heroPrefix});

  final List<Movie> movies;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) => GridView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        gridDelegate: MovieGridDelegate(infoHeight: MovieCard.infoHeight(context)),
        itemCount: movies.length,
        itemBuilder: (context, i) => FadeSlideIn(
          index: i,
          offset: 0,
          child: MovieCard(movie: movies[i], heroTag: '$heroPrefix-${movies[i].id}'),
        ),
      );
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Shimmer(
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          gridDelegate: MovieGridDelegate(infoHeight: MovieCard.infoHeight(context)),
          itemCount: 9,
          itemBuilder: (context, _) => LayoutBuilder(
            builder: (context, c) => MovieCardSkeleton(width: c.maxWidth),
          ),
        ),
      );
}
