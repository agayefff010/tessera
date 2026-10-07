import 'package:flutter/material.dart';

import '../../models/tarz_home_banner.dart';
import '../../utils/tarz_image_cache.dart';

/// Ana bannerin altı — yalnız API `side_top` / `side_bottom` reklamları.
class HomePromoBannersSection extends StatelessWidget {
  const HomePromoBannersSection({
    super.key,
    this.sideTop = const [],
    this.sideBottom = const [],
  });

  final List<TarzHomeBanner> sideTop;
  final List<TarzHomeBanner> sideBottom;

  static const double _aspectRatio = 610 / 275;
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] HomePromoBannersSection');
    final slots = <TarzHomeBanner>[
      ...sideTop.where((b) => b.imageUrl.isNotEmpty),
      ...sideBottom.where((b) => b.imageUrl.isNotEmpty),
    ];
    if (slots.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          for (var i = 0; i < slots.length; i++) ...[
            if (i > 0) const SizedBox(height: _gap),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _aspectRatio,
                child: _NetworkImage(url: slots[i].imageUrl),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
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
          errorBuilder: (_, __, ___) => const ColoredBox(
            color: Color(0xFFE8E8E8),
            child: Center(child: Icon(Icons.image_not_supported_outlined)),
          ),
        );
      },
    );
  }
}
