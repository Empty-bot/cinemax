import 'package:flutter/material.dart';

/// Apparition en fondu + glissement, décalée selon [index] pour un effet en cascade.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0, this.offset = 24});

  final Widget child;
  final int index;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 8)) * 70;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay),
      // L'intervalle simule un délai de démarrage propre à chaque élément.
      curve: Interval(delay / (380 + delay), 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(offset * (1 - t), 0), child: child),
      ),
    );
  }
}
