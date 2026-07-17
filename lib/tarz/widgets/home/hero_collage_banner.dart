import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/tarz_banner_assets.dart';
import '../../models/tarz_home_banner.dart';
import '../../utils/tarz_image_cache.dart';

/// Ana səhifə hero — `main_banner` reklamlarının slider-i.
class HeroCollageBanner extends StatefulWidget {
  const HeroCollageBanner({
    super.key,
    this.banners = const [],
    this.loading = false,
    this.onBannerTap,
  });

  final List<TarzHomeBanner> banners;

  /// `true` ikən statik fallback göstərilmir — skeleton.
  final bool loading;
  final ValueChanged<TarzHomeBanner>? onBannerTap;

  static const double _aspectRatio = 494 / 317;
  static const Duration _autoPlayInterval = Duration(seconds: 4);

  @override
  State<HeroCollageBanner> createState() => _HeroCollageBannerState();
}

class _HeroCollageBannerState extends State<HeroCollageBanner> {
  late final PageController _pageController;
  Timer? _autoPlay;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _restartAutoPlay();
  }

  @override
  void didUpdateWidget(covariant HeroCollageBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _page = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _restartAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<TarzHomeBanner> get _items =>
      widget.banners.where((b) => b.imageUrl.isNotEmpty).toList();

  void _restartAutoPlay() {
    _autoPlay?.cancel();
    final count = _items.length;
    if (count <= 1) return;
    _autoPlay = Timer.periodic(HeroCollageBanner._autoPlayInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_page + 1) % count;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: HeroCollageBanner._aspectRatio,
          child: widget.loading && items.isEmpty
              ? _loadingPlaceholder()
              : items.isEmpty
                  ? _assetImage()
                  : items.length == 1
                      ? GestureDetector(
                          onTap: () => widget.onBannerTap?.call(items.first),
                          child: _networkImage(items.first.imageUrl),
                        )
                      : _carousel(items),
        ),
      ),
    );
  }

  Widget _loadingPlaceholder() {
    return const ColoredBox(
      color: Color(0xFFE8E8E8),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _carousel(List<TarzHomeBanner> items) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: items.length,
          onPageChanged: (index) {
            setState(() => _page = index);
            _restartAutoPlay();
          },
          itemBuilder: (_, index) {
            final banner = items[index];
            return GestureDetector(
              onTap: () => widget.onBannerTap?.call(banner),
              child: _networkImage(banner.imageUrl),
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 14,
          child: IgnorePointer(
            child: _PillPageIndicator(
              count: items.length,
              index: _page,
            ),
          ),
        ),
      ],
    );
  }

  Widget _assetImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Image.asset(
          TarzBannerAssets.sliderBanner,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: TarzImageCache.px(context, constraints.maxWidth),
          cacheHeight: TarzImageCache.px(context, constraints.maxHeight),
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      },
    );
  }

  Widget _networkImage(String url) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: TarzImageCache.px(context, constraints.maxWidth),
          cacheHeight: TarzImageCache.px(context, constraints.maxHeight),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const ColoredBox(
              color: Color(0xFFE8E8E8),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _assetImage(),
        );
      },
    );
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: Color(0xFFE8E8E8),
      child: Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}

/// Yarı-şəffaf ağ pill, aktiv tire + nöqtələr.
class _PillPageIndicator extends StatelessWidget {
  const _PillPageIndicator({
    required this.count,
    required this.index,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (i) {
            final active = i == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: i == 0 ? 0 : 5),
              width: active ? 14 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
    );
  }
}
