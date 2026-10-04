import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Effet « shimmer » : un reflet qui balaie les squelettes pendant le chargement.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CinemaxColors.of(context);
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [colors.skeletonBase, colors.skeletonHighlight, colors.skeletonBase],
          stops: const [0.25, 0.5, 0.75],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          transform: _SlideGradient(_controller.value * 2 - 1),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.percent);

  final double percent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}

/// Bloc gris arrondi servant de squelette ; à placer dans un [Shimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height, this.radius = 10});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: CinemaxColors.of(context).skeletonBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// Squelette d'une carte de film (affiche + deux lignes de texte).
class MovieCardSkeleton extends StatelessWidget {
  const MovieCardSkeleton({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 2 / 3, child: SkeletonBox(radius: 14)),
            const SizedBox(height: 10),
            SkeletonBox(width: width * 0.85, height: 12),
            const SizedBox(height: 6),
            SkeletonBox(width: width * 0.4, height: 10),
          ],
        ),
      );
}
