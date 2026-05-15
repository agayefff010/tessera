import 'package:flutter/material.dart';

import '../theme/tarz_spacing.dart';

/// Promo banner — başlıq şəklin üstündə, soldan yuxarıdan.
class TarzImageBannerCard extends StatelessWidget {
  const TarzImageBannerCard({
    super.key,
    required this.assetPath,
    required this.caption,
    this.aspectRatio = 1 / 0.78,
    this.onTap,
  });

  final String assetPath;
  final String caption;
  final double aspectRatio;
  final VoidCallback? onTap;

  static const TextStyle _overlayCaption = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
    shadows: [
      Shadow(offset: Offset(0, 1), blurRadius: 6, color: Color(0xB0000000)),
      Shadow(offset: Offset(0, 2), blurRadius: 14, color: Color(0x66000000)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final imageBlock = Padding(
      padding: const EdgeInsets.fromLTRB(
        TarzSpacing.md,
        0,
        TarzSpacing.md,
        TarzSpacing.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFE0E0E0),
                  child: Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 40),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: const SizedBox(height: 100),
                ),
              ),
              Positioned(
                left: TarzSpacing.md,
                top: TarzSpacing.md,
                right: TarzSpacing.xl,
                child: Text(
                  caption,
                  style: _overlayCaption,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: imageBlock),
      );
    }
    return imageBlock;
  }
}
