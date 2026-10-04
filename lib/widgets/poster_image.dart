import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../services/api_config.dart';
import '../theme/app_colors.dart';
import 'skeleton.dart';

/// Image TMDB mise en cache, avec squelette pendant le chargement et repli si absente.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.path,
    this.size = 'w342',
    this.borderRadius = BorderRadius.zero,
    this.fallbackIcon = Icons.movie_outlined,
    this.alignment = Alignment.center,
  });

  final String? path;
  final String size;
  final BorderRadius borderRadius;
  final IconData fallbackIcon;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final url = ApiConfig.imageUrl(path, size: size);
    final fallback = _Fallback(icon: fallbackIcon);

    return ClipRRect(
      borderRadius: borderRadius,
      child: url == null
          ? fallback
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              alignment: alignment,
              width: double.infinity,
              height: double.infinity,
              fadeInDuration: const Duration(milliseconds: 300),
              placeholder: (_, _) => const Shimmer(child: SkeletonBox(radius: 0)),
              errorWidget: (_, _, _) => fallback,
            ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = CinemaxColors.of(context);
    return Container(
      color: colors.skeletonBase,
      alignment: Alignment.center,
      child: Icon(icon, size: 32, color: colors.textMuted.withValues(alpha: 0.6)),
    );
  }
}
