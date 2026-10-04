import 'package:flutter/material.dart';

import '../models/cast_member.dart';
import 'poster_image.dart';

class CastCard extends StatelessWidget {
  const CastCard({super.key, required this.member, this.width = 84});

  final CastMember member;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox.square(
            dimension: width - 8,
            child: PosterImage(
              path: member.profilePath,
              size: 'w185',
              borderRadius: BorderRadius.circular(width),
              fallbackIcon: Icons.person_rounded,
              alignment: Alignment.topCenter,
            ),
          ),
          const SizedBox(height: 8),
          Text(member.name, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium!.copyWith(color: theme.colorScheme.onSurface)),
          if (member.character.isNotEmpty)
            Text(member.character, maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall!.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
