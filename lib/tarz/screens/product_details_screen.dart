import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/auth_service.dart';
import '../cart/tarz_cart_controller.dart';
import '../data/product_repository.dart';
import '../models/tarz_product_detail.dart';
import '../models/tarz_product_preview.dart';
import '../models/tarz_product_review.dart';
import '../models/tarz_outfit.dart';
import '../outfits/tarz_outfits_controller.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../widgets/cart/tarz_checkout_sheet.dart';
import '../widgets/product_details/product_details_gallery.dart';
import '../widgets/product_details/product_details_outfit_replace_sheet.dart';
import '../widgets/product_details/product_details_outfit_section.dart';
import '../widgets/product_details/product_details_price_section.dart';
import '../widgets/product_details/product_details_reviews_section.dart';
import '../widgets/product_details/product_details_write_review_sheet.dart';
import '../widgets/tarz_flash_message.dart';
import '../widgets/tarz_product_card.dart';
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
  final _authService = AuthService();
  final _wishlist = TarzWishlistController.instance;
  bool _submittingReview = false;

  TarzProductDetail? _detail;
  List<TarzProductPreview> _similar = [];
  TarzProductReviewsResult _reviews = TarzProductReviewsResult.empty;
  TarzGeneratedOutfit _outfit = TarzGeneratedOutfit.empty;
  bool _reviewsLoading = true;
  bool _reviewsImagesOnly = false;
  bool _outfitLoading = false;
  bool _savingOutfit = false;
  bool _addingOutfitToCart = false;
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
    // Slug listədən gəlirsə dərhal yüklə — hər PDP-də Tam obraz.
    _loadOutfit(widget.product.slug);
  }

  @override
  void dispose() {
    _productRepo.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _reviewsLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _productRepo.fetchProductDetail(widget.product.id),
        _productRepo.fetchSimilarProducts(widget.product.id),
        _safeFetchReviews(widget.product.id),
      ]);

      if (!mounted) return;
      final detail = results[0] as TarzProductDetail;
      final similar = results[1] as List<TarzProductPreview>;
      final reviews = results[2] as TarzProductReviewsResult;

      setState(() {
        _detail = detail;
        _similar = similar.isNotEmpty ? similar : widget.similarProducts;
        _reviews = reviews;
        _reviewsLoading = false;
        _selectedColor =
            detail.colors.length == 1 ? detail.colors.first : null;
        _selectedSize = _pickDefaultSize(detail);
        _loading = false;
      });

      _productRepo.recordProductView(widget.product.id);
      _loadOutfit(
        detail.preview.slug ?? widget.product.slug,
        force: true,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
        _reviewsLoading = false;
        _detail = _fallbackDetail();
        _selectedSize = _detail!.availableSizes.firstOrNull;
      });
      _loadReviewsOnly();
      _loadOutfit(widget.product.slug);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Məhsul yüklənmədi';
        _loading = false;
        _reviewsLoading = false;
        _detail = _fallbackDetail();
        _selectedSize = _detail!.availableSizes.firstOrNull;
      });
      _loadReviewsOnly();
      _loadOutfit(widget.product.slug);
    }
  }

  Future<void> _loadReviewsOnly() async {
    setState(() => _reviewsLoading = true);
    try {
      final reviews = await _productRepo.fetchProductReviews(
        widget.product.id,
        imagesOnly: _reviewsImagesOnly,
      );
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _reviewsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _reviewsLoading = false);
    }
  }

  Future<TarzProductReviewsResult> _safeFetchReviews(String id) async {
    try {
      return await _productRepo.fetchProductReviews(
        id,
        imagesOnly: _reviewsImagesOnly,
      );
    } catch (_) {
      return TarzProductReviewsResult.empty;
    }
  }

  void _onReviewsImagesOnlyChanged(bool value) {
    if (_reviewsImagesOnly == value) return;
    setState(() => _reviewsImagesOnly = value);
    _loadReviewsOnly();
  }

  Future<void> _loadOutfit(String? slug, {bool force = false}) async {
    final resolved = (slug ??
            _detail?.preview.slug ??
            widget.product.slug)
        ?.trim();
    if (resolved == null || resolved.isEmpty) {
      if (mounted) {
        setState(() {
          _outfit = TarzGeneratedOutfit.empty;
          _outfitLoading = false;
        });
      }
      return;
    }
    if (_outfitLoading && !force) return;

    setState(() => _outfitLoading = true);
    try {
      final outfit = await _productRepo.fetchGeneratedOutfit(resolved);
      if (!mounted) return;
      setState(() {
        _outfit = outfit;
        _outfitLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _outfitLoading = false;
        if (force || _outfit.displayItems.isEmpty) {
          _outfit = TarzGeneratedOutfit.empty;
        }
      });
      if (force) _toast('Kombin yenilənmədi');
    }
  }

  Future<void> _toggleOutfitFavorite(TarzProductPreview product) async {
    final added = await _wishlist.toggle(product);
    _toast(
      added ? 'Seçilmişlərə əlavə edildi' : 'Seçilmişlərdən silindi',
    );
  }

  Future<void> _addToMyOutfits() async {
    if (_savingOutfit) return;
    if (_outfit.displayItems.isEmpty) {
      _toast('Əlavə ediləcək kombin yoxdur');
      return;
    }

    final loggedIn = await _authService.isLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      final action = await showTarzAuthRequiredDialog(
        context,
        message: 'Kombin saxlamaq üçün daxil olun və ya qeydiyyatdan keçin.',
      );
      if (!mounted || action == null) return;
      if (action == TarzAuthPromptAction.login) {
        await Navigator.of(context).pushNamed(AppRoutes.login);
      } else {
        await Navigator.of(context).pushNamed(AppRoutes.register);
      }
      return;
    }

    setState(() => _savingOutfit = true);
    try {
      await TarzOutfitsController.instance.saveGenerated(_outfit);
      if (!mounted) return;
      _toast('Kombinlərimə əlavə edildi');
    } on ApiException catch (e) {
      if (!mounted) return;
      _toast(e.message);
    } catch (_) {
      if (!mounted) return;
      _toast('Kombin saxlanılmadı');
    } finally {
      if (mounted) setState(() => _savingOutfit = false);
    }
  }

  Future<void> _addOutfitToCart() async {
    if (_addingOutfitToCart) return;
    final items = _outfit.displayItems;
    if (items.isEmpty) {
      _toast('Əlavə ediləcək məhsul yoxdur');
      return;
    }

    setState(() => _addingOutfitToCart = true);
    var added = 0;
    try {
      for (final item in items) {
        final product = item.product;
        if (product.id.isEmpty) continue;

        try {
          final detail = await _productRepo.fetchProductDetail(product.id);
          final color = detail.colors.isNotEmpty ? detail.colors.first : null;
          final sizes = detail.sizesForColor(color);
          final size = sizes.isNotEmpty
              ? sizes.first
              : (detail.availableSizes.firstOrNull ?? 'Standart');

          await TarzCartController.instance.addFromProduct(
            detail.preview,
            size: size,
            color: color,
            vendor: detail.vendorName,
          );
          added++;
        } catch (_) {
          await TarzCartController.instance.addFromProduct(
            product,
            size: 'Standart',
          );
          added++;
        }
      }

      if (!mounted) return;
      if (added == 0) {
        _toast('Səbətə əlavə edilmədi');
      } else {
        _toast('$added məhsul səbətə əlavə edildi');
      }
    } catch (_) {
      if (!mounted) return;
      _toast('Səbətə əlavə edilmədi');
    } finally {
      if (mounted) setState(() => _addingOutfitToCart = false);
    }
  }

  Future<void> _writeReview() async {
    if (_submittingReview) return;

    final loggedIn = await _authService.isLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      final action = await showTarzAuthRequiredDialog(
        context,
        message: 'Rəy yazmaq üçün daxil olun və ya qeydiyyatdan keçin.',
      );
      if (!mounted || action == null) return;
      if (action == TarzAuthPromptAction.login) {
        await Navigator.of(context).pushNamed(AppRoutes.login);
      } else {
        await Navigator.of(context).pushNamed(AppRoutes.register);
      }
      return;
    }

    if (!mounted) return;
    final draft = await showTarzWriteReviewSheet(context);
    if (draft == null || !mounted) return;

    setState(() => _submittingReview = true);
    try {
      await _productRepo.submitProductReview(
        widget.product.id,
        rating: draft.rating,
        comment: draft.comment,
        images: draft.images,
      );
      if (!mounted) return;
      _toast('Rəyiniz göndərildi');
      await _loadReviewsOnly();
    } on ApiException catch (e) {
      if (!mounted) return;
      _toast(e.message);
    } catch (_) {
      if (!mounted) return;
      _toast('Rəy göndərilmədi');
    } finally {
      if (mounted) setState(() => _submittingReview = false);
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

  Future<void> _replaceOutfitItem(TarzOutfitItem item) async {
    final genderId = item.product.genderId ??
        _detail?.preview.genderId ??
        widget.product.genderId;

    final picked = await showOutfitReplaceSheet(
      context,
      item: item,
      genderId: genderId,
      productRepo: _productRepo,
    );
    if (!mounted || picked == null) return;

    setState(() {
      _outfit = _outfit.replaceProduct(item.product.id, picked);
    });
    _toast('Kombin yeniləndi');
  }

  void _openProduct(TarzProductPreview p) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetails,
      arguments: ProductDetailsArgs(product: p),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] ProductDetailsScreen');
    if (_loading && _detail == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final detail = _detail!;
    final preview = detail.preview;
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
              favoriteProductId: preview.id,
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
            _buildDeliveryButton(detail),
            const SizedBox(height: TarzSpacing.md),
            ProductDetailsReviewsSection(
              result: _reviews,
              loading: _reviewsLoading || _submittingReview,
              imagesOnly: _reviewsImagesOnly,
              onImagesOnlyChanged: _onReviewsImagesOnlyChanged,
              onWriteReview: _writeReview,
            ),
            ProductDetailsOutfitSection(
              outfit: _outfit,
              loading:
                  _outfitLoading || _savingOutfit || _addingOutfitToCart,
              onRefresh: () => _loadOutfit(
                _detail?.preview.slug ?? widget.product.slug,
                force: true,
              ),
              onReplaceItem: _replaceOutfitItem,
              onFavorite: _toggleOutfitFavorite,
              onAddToOutfits: _addToMyOutfits,
              onAddToCart: _addOutfitToCart,
            ),
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

  Widget _buildDeliveryButton(TarzProductDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
      child: OutlinedButton.icon(
        onPressed: () => _showDeliveryInfo(detail),
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

  Future<void> _showDeliveryInfo(TarzProductDetail detail) {
    final vendor = detail.vendorName?.trim();
    final vendorSlug = detail.vendorSlug?.trim();
    final delivery = detail.vendorDeliveryAvailable;
    final address = detail.vendorAddress?.trim();
    final hours = detail.vendorOpenHours?.trim();
    final stores = detail.vendorStoreAddresses;

    final deliveryLabel = delivery == null
        ? 'Çatdırılma məlumatı qeyd olunmayıb'
        : delivery
            ? 'Bu mağaza çatdırılma təklif edir'
            : 'Bu mağaza çatdırılma təklif etmir (yalnız mağazadan götürmə)';

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Çatdırılma haqqında',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: TarzColors.ink,
                  ),
                ),
                const SizedBox(height: 14),
                if (vendor != null && vendor.isNotEmpty) ...[
                  Text(
                    'Mağaza: $vendor',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      delivery == true
                          ? Icons.local_shipping_outlined
                          : delivery == false
                              ? Icons.storefront_outlined
                              : Icons.info_outline_rounded,
                      size: 20,
                      color: TarzColors.ink.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        deliveryLabel,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: TarzColors.ink.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                if (hours != null && hours.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'İş saatları: $hours',
                    style: TextStyle(
                      fontSize: 13,
                      color: TarzColors.inkMuted.withValues(alpha: 0.95),
                    ),
                  ),
                ],
                if (address != null && address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Ünvan: $address',
                    style: TextStyle(
                      fontSize: 13,
                      color: TarzColors.inkMuted.withValues(alpha: 0.95),
                    ),
                  ),
                ],
                if (stores.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Mağaza ünvanları:\n${stores.map((e) => '• $e').join('\n')}',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: TarzColors.inkMuted.withValues(alpha: 0.95),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                if (vendorSlug != null && vendorSlug.isNotEmpty) ...[
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).pushNamed(
                        AppRoutes.vendorStore,
                        arguments: VendorStoreArgs(
                          slug: vendorSlug,
                          name: vendor,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TarzColors.ink,
                      side: const BorderSide(color: TarzColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Mağazaya bax'),
                  ),
                  const SizedBox(height: 10),
                ],
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: TarzColors.ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Bağla'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRelatedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: TarzSpacing.md),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = TarzSpacing.sm;
              final cardWidth = (constraints.maxWidth - spacing) / 2;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List<Widget>.generate(_similar.length, (index) {
                    final p = _similar[index];
                    final item = SizedBox(
                      width: cardWidth,
                      child: TarzProductCard(
                        product: p,
                        onTap: () => _openProduct(p),
                      ),
                    );
                    if (index == _similar.length - 1) return item;
                    return Row(children: [item, const SizedBox(width: spacing)]);
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
