import 'package:flutter/material.dart';

import '../../data/tarz_banner_assets.dart';
import '../../theme/tarz_colors.dart';
import '../../theme/tarz_home_layout.dart';

const List<String> _yerliBrandAssets = [
  'assets/yerlibrendler/68587fb6cad2b84d848b7df80a0aaed72bfd1a07.png',
  'assets/yerlibrendler/a88af6551b2bcddf0c28b937b8b674eeb888700d.png',
  'assets/yerlibrendler/a9f73bded96ff267592db9efacc192cd54392a0e.png',
  'assets/yerlibrendler/a9f73bded96ff267592db9efacc192cd54392a0e - Copy.png',
];

const List<String> _globalBrandAssets = [
  'assets/qlobalbrendler/71f898ab49e37f2e0b2f6959b53db69d95e43e43 (1).png',
  'assets/qlobalbrendler/9b0d70dfc7feb44f505a0b55ce2c6d8d2de994bc (1).png',
  'assets/qlobalbrendler/9b0d70dfc7feb44f505a0b55ce2c6d8d2de994bc (1) - Copy.png',
  'assets/qlobalbrendler/c24ac0b78d1288a798696ed2212bd29a0db7665b.png',
];

/// «Brendlər» — «Yerli brendlər» və «Qlobal brendlər» bölmələri.
class BrandBannerSection extends StatelessWidget {
  const BrandBannerSection({super.key, this.onBannerTap});

  final VoidCallback? onBannerTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandSection(
            title: 'Yerli brendlər',
            imageAsset: TarzBannerAssets.brandsYerli,
            onTap: onBannerTap,
          ),
          const SizedBox(height: 22),
          _BrandSection(
            title: 'Qlobal brendlər',
            imageAsset: TarzBannerAssets.brandsQlobal,
            onTap: onBannerTap,
          ),
        ],
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  const _BrandSection({
    required this.title,
    required this.imageAsset,
    this.onTap,
  });

  final String title;
  final String imageAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TarzHomeLayout.horizontalPadding,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TarzColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TarzHomeLayout.horizontalPadding,
          ),
          child: title == 'Yerli brendlər'
              ? SizedBox(
                  width: 471,
                  height: 99,
                  child: _LocalBrandsCarousel(
                    assets: _yerliBrandAssets,
                    onTap: onTap,
                  ),
                )
              : SizedBox(
                  width: 471,
                  height: 99,
                  child: _LocalBrandsCarousel(
                    assets: _globalBrandAssets,
                    onTap: onTap,
                  ),
                ),
        ),
      ],
    );
  }
}

class _LocalBrandsCarousel extends StatefulWidget {
  const _LocalBrandsCarousel({required this.assets, this.onTap});

  final List<String> assets;
  final VoidCallback? onTap;

  @override
  State<_LocalBrandsCarousel> createState() => _LocalBrandsCarouselState();
}

class _LocalBrandsCarouselState extends State<_LocalBrandsCarousel>
    with SingleTickerProviderStateMixin {
  static const double _viewportWidth = 471;
  static const double _viewportHeight = 99;
  static const int _carouselLength = 4;

  int _currentIndex = 0;
  late final AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      lowerBound: 0,
      upperBound: _viewportWidth,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _moveCarousel(int delta) {
    if (_slideController.isAnimating) {
      return;
    }

    final nextIndex = (_currentIndex + delta + _carouselLength) % _carouselLength;
    final itemWidth = _viewportWidth / 3;

    setState(() => _currentIndex = nextIndex);
    _slideController.animateTo(
      nextIndex * itemWidth,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _viewportWidth,
      height: _viewportHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final itemWidth = width / 3;
          final trackAssets = [...widget.assets, ...widget.assets];
          final trackWidth = itemWidth * trackAssets.length;

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBuilder(
                    animation: _slideController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(-_slideController.value, 0),
                        child: SizedBox(
                          width: trackWidth,
                          height: _viewportHeight,
                          child: Row(
                            children: trackAssets
                                .map(
                                  (asset) => SizedBox(
                                    width: itemWidth,
                                    height: _viewportHeight,
                                    child: InkWell(
                                      onTap: widget.onTap,
                                      child: Image.asset(
                                        asset,
                                        width: itemWidth,
                                        height: _viewportHeight,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                        errorBuilder: (_, __, ___) =>
                                            const ColoredBox(
                                              color: Colors.transparent,
                                            ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.14),
                          shape: const CircleBorder(),
                          elevation: 0,
                          child: InkWell(
                            onTap: () => _moveCarousel(-1),
                            customBorder: const CircleBorder(),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.14),
                          shape: const CircleBorder(),
                          elevation: 0,
                          child: InkWell(
                            onTap: () => _moveCarousel(1),
                            customBorder: const CircleBorder(),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
