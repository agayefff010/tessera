import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../theme/tarz_text_styles.dart';
import '../utils/tarz_image_cache.dart';

class TarzHeroBanner extends StatelessWidget {
  const TarzHeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onCta,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onCta;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TarzSpacing.md,
        TarzSpacing.md,
        TarzSpacing.md,
        TarzSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 11,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      cacheWidth:
                          TarzImageCache.px(context, constraints.maxWidth),
                      cacheHeight:
                          TarzImageCache.px(context, constraints.maxHeight),
                      errorBuilder: (_, __, ___) => const _HeroFallback(),
                    );
                  },
                )
              else
                const _HeroFallback(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      TarzColors.heroOverlay.withValues(alpha: 0.15),
                      TarzColors.heroOverlay.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(TarzSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(title, style: TarzTextStyles.titleLg.copyWith(color: Colors.white)),
                    const SizedBox(height: TarzSpacing.xs),
                    Text(
                      subtitle,
                      style: TarzTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                    ),
                    const SizedBox(height: TarzSpacing.md),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: TarzColors.ink,
                        padding: const EdgeInsets.symmetric(
                          horizontal: TarzSpacing.xl,
                          vertical: TarzSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: onCta,
                      child: Text(ctaLabel, style: TarzTextStyles.label.copyWith(color: TarzColors.ink)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B2B2B),
            Color(0xFF0F0F0F),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.auto_awesome_mosaic_rounded, size: 56, color: Colors.white24),
      ),
    );
  }
}
