import 'package:flutter/material.dart';

import '../../data/tarz_banner_assets.dart';
import '../../theme/tarz_colors.dart';
import '../../theme/tarz_home_layout.dart';

/// «Brendlər» — üfüqi scroll, Figma «Yerli brendlər» banneri.
class BrandBannerSection extends StatelessWidget {
  const BrandBannerSection({
    super.key,
    this.onBannerTap,
  });

  final VoidCallback? onBannerTap;

  static const double _cardGap = 12;
  static const double _peekWidth = 32;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: TarzHomeLayout.horizontalPadding,
            ),
            child: Text(
              'Brendlər',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TarzColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPad = TarzHomeLayout.horizontalPadding;
              final bannerWidth = constraints.maxWidth -
                  horizontalPad * 2 -
                  _peekWidth;
              final bannerHeight = TarzHomeLayout.brandFrameHeight *
                  (bannerWidth / TarzHomeLayout.brandFrameWidth);

              return SizedBox(
                height: bannerHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                  itemCount: 2,
                  separatorBuilder: (_, __) => const SizedBox(width: _cardGap),
                  itemBuilder: (context, index) {
                    return _BrandBanner(
                      width: bannerWidth,
                      height: bannerHeight,
                      onTap: onBannerTap,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BrandBanner extends StatelessWidget {
  const _BrandBanner({
    required this.width,
    required this.height,
    this.onTap,
  });

  final double width;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Image.asset(
            TarzBannerAssets.brandsYerli,
            fit: BoxFit.fill,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 32,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
