import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../cart/tarz_cart_controller.dart';
import '../data/product_repository.dart';
import '../models/tarz_product_detail.dart';
import '../models/tarz_product_preview.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../widgets/listing/plp_product_card.dart';
import '../widgets/product_details/product_details_gallery.dart';
import '../widgets/product_details/product_details_price_section.dart';
import '../widgets/tarz_flash_message.dart';
import '../wishlist/tarz_wishlist_controller.dart';

/// Məhsul detalları — API PDP.
class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.similarProducts = const [],
  });

  final TarzProductPreview product;
  final List<TarzProductPreview> similarProducts;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const Color _fieldBorder = Color(0xFFE0E0E0);

  final _productRepo = ProductRepository();
  final _wishlist = TarzWishlistController.instance;

  TarzProductDetail? _detail;
  List<TarzProductPreview> _similar = [];
  bool _loading = true;
  String? _error;

  int _selectedImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  bool _addingToCart = false;

  @override
  void initState() {
    super.initState();
    _similar = widget.similarProducts;
    _loadDetail();
  }

  @override
  void dispose() {
    _productRepo.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _productRepo.fetchProductDetail(widget.product.id),
        _productRepo.fetchSimilarProducts(widget.product.id),
      ]);

      if (!mounted) return;
      final detail = results[0] as TarzProductDetail;
      final similar = results[1] as List<TarzProductPreview>;

      setState(() {
        _detail = detail;
        _similar = similar.isNotEmpty ? similar : widget.similarProducts;
        _selectedColor =
            detail.colors.length == 1 ? detail.colors.first : null;
        _selectedSize = _pickDefaultSize(detail);
        _loading = false;
      });

      _productRepo.recordProductView(widget.product.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
        _detail = _fallbackDetail();
        _selectedSize = _detail!.availableSizes.firstOrNull;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Məhsul yüklənmədi';
        _loading = false;
        _detail = _fallbackDetail();
        _selectedSize = _detail!.availableSizes.firstOrNull;
      });
    }
  }

  TarzProductDetail _fallbackDetail() {
    return TarzProductDetail(
      id: widget.product.id,
      title: widget.product.title,
      brand: widget.product.brand,
      priceLabel: widget.product.priceLabel,
      originalPriceLabel: widget.product.originalPriceLabel,
      badgeLabel: widget.product.badgeLabel,
      imageUrls: widget.product.imageUrl != null
          ? [widget.product.imageUrl!]
          : const [],
      sizes: const [
        TarzProductSizeOption(size: 'M', stock: 10),
      ],
      colors: const [],
      preview: widget.product,
    );
  }

  String? _pickDefaultSize(TarzProductDetail detail) {
    final sizes = detail.sizesForColor(_selectedColor);
    if (sizes.isNotEmpty) return sizes.first;
    return detail.availableSizes.firstOrNull;
  }

  List<String> get _sizeOptions {
    final detail = _detail;
    if (detail == null) return const [];
    final sizes = detail.sizesForColor(_selectedColor);
    return sizes.isNotEmpty ? sizes : detail.availableSizes;
  }

  void _toast(String message) => TarzFlashMessage.show(context, message);

  Future<void> _toggleFavorite() async {
    final preview = _detail?.preview ?? widget.product;
    final added = await _wishlist.toggle(preview);
    _toast(
      added
          ? 'Seçilmişlərə əlavə edildi'
          : 'Seçilmişlərdən silindi',
    );
    if (mounted) setState(() {});
  }

  Future<void> _addToCart() async {
    final detail = _detail;
    if (detail == null) return;

    final size = _selectedSize;
    if (size == null || size.isEmpty) {
      _toast('Ölçü seçin');
      return;
    }

    if (!detail.isSizeAvailable(size, color: _selectedColor)) {
      _toast('Bu ölçü/rəng stokda yoxdur');
      return;
    }

    setState(() => _addingToCart = true);

    await TarzCartController.instance.addFromProduct(
      detail.preview,
      size: size,
      color: _selectedColor,
      vendor: detail.vendorName,
    );

    if (!mounted) return;
    setState(() => _addingToCart = false);

    TarzFlashMessage.show(context, 'Səbətə əlavə edildi');
  }

  void _openProduct(TarzProductPreview p) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetails,
      arguments: ProductDetailsArgs(product: p),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _detail == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final detail = _detail!;
    final preview = detail.preview;
    final isFavorite = _wishlist.contains(preview.id);
    final description = detail.fullDescription;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProductDetailsGallery(
              imageUrls: detail.imageUrls,
              selectedIndex: _selectedImageIndex,
              onThumbnailTap: (i) => setState(() => _selectedImageIndex = i),
              onBack: () => Navigator.of(context).maybePop(),
              onFavorite: _toggleFavorite,
              isFavorite: isFavorite,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TarzSpacing.md,
                  vertical: 8,
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            const SizedBox(height: TarzSpacing.sm),
            ProductDetailsPriceSection(
              brand: detail.brand ?? 'Tessera',
              title: detail.title,
              priceLabel: detail.priceLabel,
              originalPriceLabel: detail.originalPriceLabel,
              badgeLabel: detail.badgeLabel,
            ),
            if (detail.colors.isNotEmpty) ...[
              const SizedBox(height: TarzSpacing.md),
              _buildColorSection(detail.colors),
            ],
            if (_sizeOptions.isNotEmpty) ...[
              const SizedBox(height: TarzSpacing.md),
              _buildSizeDropdown(_sizeOptions),
            ],
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: TarzSpacing.lg),
              _buildDescription(description),
            ],
            const SizedBox(height: TarzSpacing.lg),
            _buildAddToCart(),
            const SizedBox(height: TarzSpacing.sm),
            _buildDeliveryButton(detail.vendorName),
            if (_similar.isNotEmpty) ...[
              const SizedBox(height: TarzSpacing.xl),
              _buildRelatedSection(),
            ],
            const SizedBox(height: TarzSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(List<String> colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rəng',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TarzColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((color) {
              final selected = _selectedColor == color;
              return ChoiceChip(
                label: Text(color),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedColor = color;
                    final sizes = _detail?.sizesForColor(color) ?? [];
                    if (_selectedSize == null ||
                        !sizes.contains(_selectedSize)) {
                      _selectedSize = sizes.isNotEmpty ? sizes.first : null;
                    }
                  });
                },
                selectedColor: TarzColors.ink.withValues(alpha: 0.12),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: TarzColors.ink,
                ),
                side: BorderSide(
                  color: selected ? TarzColors.ink : _fieldBorder,
                ),
                backgroundColor: Colors.white,
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeDropdown(List<String> sizes) {
    final value = sizes.contains(_selectedSize) ? _selectedSize : sizes.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(
            border: Border.all(color: _fieldBorder),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ölçü',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: TarzColors.ink,
                ),
              ),
              const SizedBox(width: 4),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: TarzColors.ink.withValues(alpha: 0.55),
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: TarzColors.ink,
                  ),
                  items: sizes
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s)),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedSize = v);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Təsvir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TarzColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: TarzColors.ink.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: FilledButton(
          onPressed: _addingToCart ? null : _addToCart,
          style: FilledButton.styleFrom(
            backgroundColor: TarzColors.ink,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          child: _addingToCart
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Səbətə əlavə et'),
        ),
      ),
    );
  }

  Widget _buildDeliveryButton(String? vendor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
      child: OutlinedButton.icon(
        onPressed: () {
          if (vendor != null && vendor.isNotEmpty) {
            _toast('Mağaza: $vendor');
          } else {
            _toast('Çatdırılma haqqında məlumat');
          }
        },
        icon: Icon(
          Icons.inventory_2_outlined,
          size: 18,
          color: TarzColors.ink.withValues(alpha: 0.7),
        ),
        label: const Text(
          'Çatdırılma haqqında məlumat',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: TarzColors.ink,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: TarzColors.ink,
          side: const BorderSide(color: _fieldBorder),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedSection() {
    const cardWidth = 175.0;
    final cardHeight = cardWidth / 0.48;

    return Padding(
      padding: const EdgeInsets.only(left: TarzSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: TarzSpacing.md),
            child: Text(
              'Oxşar məhsullar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
          ),
          const SizedBox(height: TarzSpacing.md),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: TarzSpacing.md),
              itemCount: _similar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = _similar[index];
                return SizedBox(
                  width: cardWidth,
                  child: PlpProductCard(
                    product: product,
                    isFavorite: _wishlist.contains(product.id),
                    onTap: () => _openProduct(product),
                    onFavorite: () async {
                      await _wishlist.toggle(product);
                      if (mounted) setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
