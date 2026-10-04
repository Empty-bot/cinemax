import 'package:cinemax/models/movie.dart';
import 'package:cinemax/theme/app_theme.dart';
import 'package:cinemax/widgets/movie_card.dart';
import 'package:cinemax/widgets/rating_badge.dart';
import 'package:cinemax/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  testWidgets('la note animée atteint sa valeur finale', (tester) async {
    await tester.pumpWidget(wrap(const Center(child: RatingCircle(rating: 7.8))));
    expect(find.text('0.0'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('7.8'), findsOneWidget);
  });

  testWidgets('ErrorView propose de réessayer', (tester) async {
    var retried = false;
    await tester.pumpWidget(wrap(ErrorView(message: 'Pas de connexion', onRetry: () => retried = true)));
    await tester.tap(find.text('Réessayer'));
    expect(retried, isTrue);
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('la grille de films tient un titre sur deux lignes (texte x$scale)', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const movie = Movie(
        id: 1,
        title: 'Le Seigneur des anneaux : La Communauté de l\'anneau',
        releaseDate: '2001-12-19',
      );

      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(size: const Size(412, 915), textScaler: TextScaler.linear(scale)),
        child: wrap(Builder(
          builder: (context) => GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: MovieGridDelegate(infoHeight: MovieCard.infoHeight(context)),
            itemCount: 6,
            itemBuilder: (_, i) => MovieCard(movie: movie, heroTag: 'test-$i'),
          ),
        )),
      ));

      expect(tester.takeException(), isNull);
    });
  }
}
