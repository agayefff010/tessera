import 'package:flutter/material.dart';



import '../../routes/app_routes.dart';

import '../cart/tarz_cart_controller.dart';

import '../data/tarz_product_assets.dart';

import '../data/tarz_mock_catalog.dart';

import '../models/tarz_product_preview.dart';

import '../theme/tarz_colors.dart';

import '../theme/tarz_spacing.dart';

import '../widgets/listing/plp_product_card.dart';

import '../widgets/product_details/product_details_gallery.dart';

import '../widgets/product_details/product_details_price_section.dart';

import '../wishlist/tarz_wishlist_controller.dart';



/// Məhsul detalları — Figma PDP dizaynına uyğun.

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



  static const List<String> _galleryAssets = TarzProductAssets.all;



  static const List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL'];



  final _wishlist = TarzWishlistController.instance;



  int _selectedImageIndex = 0;

  String _selectedSize = 'M';



  String get _brand => widget.product.brand ?? 'River Island';



  String get _title =>

      widget.product.title == 'Nike V5 RNR'

          ? 'Brown Check Asymmetric Wrap Skirt'

          : widget.product.title;



  String get _price =>

      widget.product.priceLabel.isNotEmpty ? widget.product.priceLabel : '90₼';



  String? get _originalPrice => widget.product.originalPriceLabel ?? '120₼';



  String? get _badge => widget.product.badgeLabel ?? '-25%';



  List<TarzProductPreview> get _related {

    if (widget.similarProducts.isNotEmpty) return widget.similarProducts;

    return TarzMockCatalog.homeTrendler().take(6).toList();

  }



  void _toast(String message) {

    final messenger = ScaffoldMessenger.maybeOf(context);

    messenger?.hideCurrentSnackBar();

    messenger?.showSnackBar(SnackBar(content: Text(message)));

  }



  void _openProduct(TarzProductPreview p) {

    Navigator.of(context).pushNamed(

      AppRoutes.productDetails,

      arguments: ProductDetailsArgs(

        product: p,

        similarProducts: _related,

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: ListenableBuilder(

        listenable: _wishlist,

        builder: (context, _) {

          return SingleChildScrollView(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                ProductDetailsGallery(

                  imageAssets: _galleryAssets,

                  selectedIndex: _selectedImageIndex,

                  onThumbnailTap: (i) => setState(() => _selectedImageIndex = i),

                  onBack: () => Navigator.of(context).maybePop(),

                ),

                const SizedBox(height: TarzSpacing.sm),

                ProductDetailsPriceSection(

                  brand: _brand,

                  title: _title,

                  priceLabel: _price,

                  originalPriceLabel: _originalPrice,

                  badgeLabel: _badge,

                ),

                const SizedBox(height: TarzSpacing.md),

                _buildSizeDropdown(),

                const SizedBox(height: TarzSpacing.lg),

                _buildAddToCart(),

                const SizedBox(height: TarzSpacing.sm),

                _buildDeliveryButton(),

                const SizedBox(height: TarzSpacing.xl),

                _buildReviewsSection(),

                const SizedBox(height: TarzSpacing.xl),

                _buildRelatedSection(),

                const SizedBox(height: TarzSpacing.xl),

              ],

            ),

          );

        },

      ),

    );

  }



  Widget _buildSizeDropdown() {

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

                  value: _selectedSize,

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

                  items: _sizes

                      .map(

                        (s) => DropdownMenuItem(

                          value: s,

                          child: Text(s),

                        ),

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



  Widget _buildAddToCart() {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),

      child: SizedBox(

        width: double.infinity,

        height: 46,

        child: FilledButton(

          onPressed: () {

            TarzCartController.instance.addFromProduct(

              widget.product,

              size: _selectedSize,

            );

            _toast('Səbətə əlavə edildi ($_selectedSize)');

          },

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

          child: const Text('Səbətə əlavə et'),

        ),

      ),

    );

  }



  Widget _buildDeliveryButton() {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),

      child: OutlinedButton.icon(

        onPressed: () => _toast('Çatdırılma haqqında məlumat'),

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



  Widget _buildReviewsSection() {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),

      child: Row(

        children: [

          GestureDetector(

            onTap: () => _toast('Rəylər'),

            child: const Text(

              'Rəylər (104)',

              style: TextStyle(

                fontSize: 13,

                fontWeight: FontWeight.w500,

                color: TarzColors.ink,

                decoration: TextDecoration.underline,

                decorationColor: TarzColors.ink,

              ),

            ),

          ),

          const Spacer(),

          Row(

            children: [

              ...List.generate(5, (i) {

                final filled = i < 4;

                return Icon(

                  filled ? Icons.star_rounded : Icons.star_outline_rounded,

                  size: 16,

                  color: filled

                      ? const Color(0xFF121212)

                      : const Color(0xFFD0D0D0),

                );

              }),

              const SizedBox(width: 6),

              const Text(

                '4.0',

                style: TextStyle(

                  fontSize: 13,

                  fontWeight: FontWeight.w600,

                  color: TarzColors.ink,

                ),

              ),

            ],

          ),

        ],

      ),

    );

  }



  Widget _buildRelatedSection() {

    const cardWidth = 175.0;

    // PLP şəbəkəsi ilə eyni nisbət (0.48) — mətn üçün kifayət yer.
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

              itemCount: _related.length,

              separatorBuilder: (_, __) => const SizedBox(width: 12),

              itemBuilder: (context, index) {

                final product = _related[index];

                return SizedBox(

                  width: cardWidth,

                  child: PlpProductCard(

                    product: product,

                    isFavorite: _wishlist.contains(product.id),

                    onTap: () => _openProduct(product),

                    onFavorite: () => _wishlist.toggle(product),

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


