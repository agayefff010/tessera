import 'package:flutter/material.dart';

import '../../data/tarz_banner_assets.dart';

/// Ana səhifə hero slider banner (Figma export).
class HeroCollageBanner extends StatelessWidget {
  const HeroCollageBanner({super.key});

  static const double _aspectRatio = 494 / 317;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: Image.asset(
            TarzBannerAssets.sliderBanner,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0xFFE8E8E8),
              child: Center(
                child: Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
