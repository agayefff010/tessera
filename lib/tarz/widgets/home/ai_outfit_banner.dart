import 'package:flutter/material.dart';

import '../../data/tarz_banner_assets.dart';

/// «Sənin AI kombinlərin» — Figma banneri.
class AiOutfitBanner extends StatelessWidget {
  const AiOutfitBanner({
    super.key,
    this.onCreateOutfit,
  });

  final VoidCallback? onCreateOutfit;

  static const double _bannerAspect = 494 / 663;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = width / _bannerAspect;

          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    TarzBannerAssets.aiKombinlerBanner,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFF1A2744),
                    ),
                  ),
                  Positioned(
                    right: width * 0.04,
                    bottom: height * 0.035,
                    child: _CreateOutfitButton(onTap: onCreateOutfit),
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

class _CreateOutfitButton extends StatelessWidget {
  const _CreateOutfitButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            child: Text(
              'Öz obrazını yarat',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121212),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
