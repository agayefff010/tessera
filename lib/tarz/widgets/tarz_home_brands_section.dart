import 'package:flutter/material.dart';

import '../data/tarz_banner_assets.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../theme/tarz_text_styles.dart';

/// «Brendlər» — üfüqi sürüşən banner, «Yerli brendlər» nişanı və mətn loqoları.
class TarzHomeBrandsSection extends StatelessWidget {
  const TarzHomeBrandsSection({super.key, this.onBannerTap});

  final VoidCallback? onBannerTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cardW = (w - TarzSpacing.md * 2 - TarzSpacing.sm).clamp(280.0, 420.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TarzSpacing.md,
            0,
            TarzSpacing.md,
            TarzSpacing.md,
          ),
          child: Text(
            'Brendlər',
            style: TarzTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: TarzSpacing.md, right: TarzSpacing.md),
            physics: const BouncingScrollPhysics(),
            children: [
              _BrandBannerCard(
                width: cardW,
                imageAsset: TarzBannerAssets.mehman,
                onTap: onBannerTap,
              ),
              const SizedBox(width: TarzSpacing.sm),
              _BrandBannerCard(
                width: cardW,
                imageAsset: TarzBannerAssets.winter,
                onTap: onBannerTap,
              ),
            ],
          ),
        ),
        const SizedBox(height: TarzSpacing.xl),
      ],
    );
  }
}

class _BrandBannerCard extends StatelessWidget {
  const _BrandBannerCard({
    required this.width,
    required this.imageAsset,
    this.onTap,
  });

  final double width;
  final String imageAsset;
  final VoidCallback? onTap;

  static const TextStyle _logo = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(offset: Offset(0, 1), blurRadius: 8, color: Color(0x99000000)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: TarzColors.ink,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF2A2A2A)),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: TarzSpacing.md,
                top: TarzSpacing.md,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9C4A8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Yerli brendlər',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2419),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('PARCHA', style: _logo.copyWith(fontSize: 22, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text(
                      'NAVEEN BAKU',
                      style: _logo.copyWith(fontSize: 13, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text('EMILAND', style: _logo.copyWith(fontSize: 20, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text(
                      'corabb.',
                      style: _logo.copyWith(
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
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
