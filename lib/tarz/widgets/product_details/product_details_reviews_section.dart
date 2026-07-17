import 'package:flutter/material.dart';

import '../../models/tarz_product_review.dart';
import '../../theme/tarz_colors.dart';
import '../../theme/tarz_spacing.dart';
import '../../utils/tarz_image_cache.dart';

/// PDP «Rəylər» bölməsi — API: `GET /products/:id/reviews?imagesOnly=`.
class ProductDetailsReviewsSection extends StatelessWidget {
  const ProductDetailsReviewsSection({
    super.key,
    required this.result,
    this.loading = false,
    this.imagesOnly = false,
    this.onImagesOnlyChanged,
    this.onSeeAll,
    this.onWriteReview,
  });

  final TarzProductReviewsResult result;
  final bool loading;
  final bool imagesOnly;
  final ValueChanged<bool>? onImagesOnlyChanged;
  final VoidCallback? onSeeAll;
  final VoidCallback? onWriteReview;

  static const Color _starColor = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    final reviews = result.reviews;
    final avg = result.averageRating;
    final count = result.totalReviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
        InkWell(
          onTap: onSeeAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TarzSpacing.md,
              vertical: 14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Rəylər ($count)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  _StarRow(rating: avg, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    avg.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (onImagesOnlyChanged != null || onWriteReview != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TarzSpacing.md,
              0,
              TarzSpacing.md,
              10,
            ),
            child: Row(
              children: [
                if (onImagesOnlyChanged != null)
                  FilterChip(
                    label: const Text('Yalnız şəkil'),
                    selected: imagesOnly,
                    onSelected: loading ? null : onImagesOnlyChanged,
                    selectedColor: TarzColors.ink.withValues(alpha: 0.1),
                    checkmarkColor: TarzColors.ink,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TarzColors.ink.withValues(alpha: 0.9),
                    ),
                    side: BorderSide(
                      color:
                          imagesOnly ? TarzColors.ink : const Color(0xFFE0E0E0),
                    ),
                    backgroundColor: Colors.white,
                    showCheckmark: true,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                const Spacer(),
                if (onWriteReview != null)
                  TextButton(
                    onPressed: loading ? null : onWriteReview,
                    style: TextButton.styleFrom(
                      foregroundColor: TarzColors.ink,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Rəy yaz',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (!loading && reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TarzSpacing.md,
              4,
              TarzSpacing.md,
              16,
            ),
            child: Text(
              imagesOnly
                  ? 'Şəkilli rəy tapılmadı'
                  : 'Hələ rəy yoxdur',
              style: TextStyle(
                fontSize: 13,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
          ),
        if (reviews.isNotEmpty) ...[
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
          ...reviews.map((review) => _ReviewTile(review: review)),
        ],
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final threshold = index + 1;
        final IconData icon;
        if (rating >= threshold) {
          icon = Icons.star_rounded;
        } else if (rating >= threshold - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(
          icon,
          size: size,
          color: ProductDetailsReviewsSection._starColor,
        );
      }),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final TarzProductReview review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TarzSpacing.md,
        14,
        TarzSpacing.md,
        4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.authorLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: TarzColors.ink,
                  ),
                ),
              ),
              Text(
                review.dateLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: TarzColors.inkMuted.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _StarRow(rating: review.rating, size: 14),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: TarzColors.ink.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = review.imageUrls[index];
                  final cache = TarzImageCache.px(context, 64);
                  return GestureDetector(
                    onTap: () => _openReviewImages(
                      context,
                      urls: review.imageUrls,
                      initialIndex: index,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        url,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        cacheWidth: cache,
                        cacheHeight: cache,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0xFFF0F0F0),
                          child: SizedBox(width: 64, height: 64),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
        ],
      ),
    );
  }
}

void _openReviewImages(
  BuildContext context, {
  required List<String> urls,
  required int initialIndex,
}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (context) {
      return _ReviewImageViewer(
        urls: urls,
        initialIndex: initialIndex,
      );
    },
  );
}

class _ReviewImageViewer extends StatefulWidget {
  const _ReviewImageViewer({
    required this.urls,
    required this.initialIndex,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<_ReviewImageViewer> createState() => _ReviewImageViewerState();
}

class _ReviewImageViewerState extends State<_ReviewImageViewer> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.urls.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.urls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      widget.urls[index],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ),
          if (widget.urls.length > 1)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    '${_index + 1} / ${widget.urls.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
