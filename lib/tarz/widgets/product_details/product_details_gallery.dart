import 'package:flutter/material.dart';

import '../../data/tarz_product_assets.dart';
import '../../theme/tarz_spacing.dart';

/// Böyük portret şəkil + thumbnail sırası və «Geriyə» düyməsi.
class ProductDetailsGallery extends StatelessWidget {
  const ProductDetailsGallery({
    super.key,
    this.imageAssets = const [],
    this.imageUrls = const [],
    required this.selectedIndex,
    required this.onThumbnailTap,
    required this.onBack,
    this.onFavorite,
    this.isFavorite = false,
    this.mainImageAsset,
  });

  final List<String> imageAssets;
  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int> onThumbnailTap;
  final VoidCallback onBack;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final String? mainImageAsset;

  static const double thumbnailSize = 78;
  static const double thumbnailGap = 8;

  bool get _useNetwork => imageUrls.isNotEmpty;

  List<int> get _indices =>
      List.generate(_useNetwork ? imageUrls.length : imageAssets.length, (i) => i);

  @override
  Widget build(BuildContext context) {
    final safeIndex = _indices.isEmpty
        ? 0
        : selectedIndex.clamp(0, _indices.length - 1);

    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildMainImage(safeIndex),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onBack,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(8, 4, 12, 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chevron_left_rounded,
                                size: 22,
                                color: Color(0xFF121212),
                              ),
                              Text(
                                'Geriyə',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121212),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (onFavorite != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: IconButton(
                        onPressed: onFavorite,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? const Color(0xFFE53935)
                              : const Color(0xFF121212),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_indices.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TarzSpacing.md,
                TarzSpacing.md,
                TarzSpacing.md,
                TarzSpacing.lg,
              ),
              child: SizedBox(
                height: thumbnailSize,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _indices.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: thumbnailGap),
                  itemBuilder: (context, index) {
                    final selected = index == safeIndex;
                    return GestureDetector(
                      onTap: () => onThumbnailTap(index),
                      child: Container(
                        width: thumbnailSize,
                        height: thumbnailSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF121212)
                                : const Color(0xFFE0E0E0),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          child: _buildThumb(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainImage(int index) {
    if (_useNetwork) {
      return Image.network(
        imageUrls[index],
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    final asset = mainImageAsset ??
        (imageAssets.isNotEmpty
            ? imageAssets[index]
            : TarzProductAssets.nikeV5Rnr);

    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _buildThumb(int index) {
    if (_useNetwork) {
      return Image.network(
        imageUrls[index],
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.asset(
      imageAssets[index],
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFF5F5F5)),
    );
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: Color(0xFFF0F0F0),
      child: Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}
