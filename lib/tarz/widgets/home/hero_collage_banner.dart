import 'package:flutter/material.dart';

import '../../data/tarz_banner_assets.dart';
import '../../models/tarz_home_banner.dart';

/// Ana səhifə hero slider banner — API şəkilləri və ya lokal fallback.
class HeroCollageBanner extends StatefulWidget {
  const HeroCollageBanner({
    super.key,
    this.banners = const [],
  });

  final List<TarzHomeBanner> banners;

  static const double _aspectRatio = 494 / 317;

  @override
  State<HeroCollageBanner> createState() => _HeroCollageBannerState();
}

class _HeroCollageBannerState extends State<HeroCollageBanner> {
  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<TarzHomeBanner> get _items =>
      widget.banners.where((b) => b.imageUrl.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: HeroCollageBanner._aspectRatio,
          child: items.isEmpty
              ? _assetImage()
              : items.length == 1
                  ? _networkImage(items.first.imageUrl)
                  : _carousel(items),
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
          onPageChanged: (index) => setState(() => _page = index),
          itemBuilder: (_, index) => _networkImage(items[index].imageUrl),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 8 : 6,
                height: active ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _assetImage() {
    return Image.asset(
      TarzBannerAssets.sliderBanner,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _networkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
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
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: Color(0xFFE8E8E8),
      child: Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}
