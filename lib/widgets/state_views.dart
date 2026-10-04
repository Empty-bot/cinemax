import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Message d'erreur avec bouton « Réessayer ».
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry, this.compact = false});

  final String message;
  final VoidCallback? onRetry;

  /// Version en ligne, pour une section plutôt qu'un écran entier.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = CinemaxColors.of(context).textMuted;

    if (compact) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: muted),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
            if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Illustration(icon: Icons.wifi_off_rounded),
            const SizedBox(height: 24),
            Text('Oups…', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium!.copyWith(color: muted)),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// État vide illustré (aucune recherche, aucun favori…).
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Illustration(icon: icon),
            const SizedBox(height: 28),
            Text(title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium!.copyWith(color: CinemaxColors.of(context).textMuted),
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// Icône animée entourée de cercles concentriques.
class _Illustration extends StatefulWidget {
  const _Illustration({required this.icon});

  final IconData icon;

  @override
  State<_Illustration> createState() => _IllustrationState();
}

class _IllustrationState extends State<_Illustration> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final float = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: float,
      builder: (context, child) => Transform.translate(offset: Offset(0, -6 * float.value), child: child),
      child: Container(
        width: 148,
        height: 148,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.06),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.28),
                AppColors.primaryDeep.withValues(alpha: 0.12),
              ],
            ),
          ),
          child: Icon(widget.icon, size: 46, color: AppColors.primary),
        ),
      ),
    );
  }
}
