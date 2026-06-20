import 'package:flutter/material.dart';

import '../../data/tarz_banner_assets.dart';

/// «Sənin AI kombinlərin» — tünd göy kart, üst-üstə şəkillər, CTA.
class AiOutfitBanner extends StatelessWidget {
  const AiOutfitBanner({
    super.key,
    this.onCreateOutfit,
  });

  final VoidCallback? onCreateOutfit;

  static const Color _bgStart = Color(0xFF1A2744);
  static const Color _bgEnd = Color(0xFF0F1A2E);

  static const _pills = ['Toy', 'Gündəlik', 'Ofis', 'Tətil'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 270,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_bgStart, _bgEnd],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  left: 18,
                  top: 20,
                  child: Text(
                    'Sənin AI✦\nkombinlərin',
                    style: TextStyle(
                      color: Color(0xFFD8E2F0),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 88,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _pills.map(_pill).toList(),
                  ),
                ),
                Positioned(left: 12, bottom: 52, child: _floatImage(TarzBannerAssets.yakup, 72, 96)),
                Positioned(right: 88, top: 56, child: _floatImage(TarzBannerAssets.tomy, 64, 80)),
                Positioned(right: 14, bottom: 70, child: _floatImage(TarzBannerAssets.mehman, 78, 100)),
                Positioned(left: 100, bottom: 24, child: _floatImage(TarzBannerAssets.winter, 68, 86)),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: onCreateOutfit,
                      borderRadius: BorderRadius.circular(999),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        child: Text(
                          'Öz obrazını yarat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF121212),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _pill(String label) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static Widget _floatImage(String asset, double w, double h) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        asset,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SizedBox(
          width: w,
          height: h,
          child: const ColoredBox(color: Colors.white24),
        ),
      ),
    );
  }
}
