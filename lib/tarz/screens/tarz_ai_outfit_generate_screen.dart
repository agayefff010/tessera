import 'dart:async';

import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/auth_service.dart';
import '../cart/tarz_cart_controller.dart';
import '../cart/tarz_price_utils.dart';
import '../data/product_repository.dart';
import '../models/tarz_outfit.dart';
import '../models/tarz_product_preview.dart';
import '../outfits/tarz_outfits_controller.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../utils/tarz_image_cache.dart';
import '../widgets/cart/tarz_checkout_sheet.dart';
import '../widgets/tarz_flash_message.dart';

/// AI kombin generasiya — məhsul seç → `GET /outfits/generate/:slug` → saxla.
class TarzAiOutfitGenerateScreen extends StatefulWidget {
  const TarzAiOutfitGenerateScreen({super.key});

  @override
  State<TarzAiOutfitGenerateScreen> createState() =>
      _TarzAiOutfitGenerateScreenState();
}

class _TarzAiOutfitGenerateScreenState
    extends State<TarzAiOutfitGenerateScreen> {
  final _searchController = TextEditingController();
  final _repo = ProductRepository();
  final _auth = AuthService();

  Timer? _debounce;
  int _requestId = 0;

  List<TarzProductPreview> _results = [];
  bool _searching = false;
  bool _generating = false;
  bool _saving = false;
  bool _addingToCart = false;

  TarzProductPreview? _anchor;
  TarzGeneratedOutfit _outfit = TarzGeneratedOutfit.empty;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _repo.dispose();
    _auth.dispose();
    super.dispose();
  }

  void _toast(String message) => TarzFlashMessage.show(context, message);

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 320), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    final id = ++_requestId;
    try {
      final results = await _repo.fetchAutocomplete(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = [];
        _searching = false;
      });
      _toast('Axtarış alınmadı');
    }
  }

  Future<void> _generateFrom(TarzProductPreview product) async {
    final slug = product.slug?.trim();
    if (slug == null || slug.isEmpty) {
      _toast('Bu məhsul üçün kombin yaradıla bilməz');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _anchor = product;
      _generating = true;
      _error = null;
      _outfit = TarzGeneratedOutfit.empty;
      _results = [];
      _searchController.text = product.title;
    });

    try {
      final outfit = await _repo.fetchGeneratedOutfit(slug);
      if (!mounted) return;
      setState(() {
        _outfit = outfit;
        _generating = false;
        if (outfit.displayItems.isEmpty) {
          _error = 'Bu məhsul üçün kombin tapılmadı';
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _error = 'Kombin generasiya olunmadı';
      });
    }
  }

  Future<void> _saveOutfit() async {
    if (_saving || _outfit.displayItems.isEmpty) return;

    final loggedIn = await _auth.isLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      final action = await showTarzAuthRequiredDialog(
        context,
        message: 'Kombin saxlamaq üçün daxil olun.',
      );
      if (!mounted || action == null) return;
      if (action == TarzAuthPromptAction.login) {
        await Navigator.of(context).pushNamed(AppRoutes.login);
      } else {
        await Navigator.of(context).pushNamed(AppRoutes.register);
      }
      return;
    }

    setState(() => _saving = true);
    try {
      await TarzOutfitsController.instance.saveGenerated(_outfit);
      if (!mounted) return;
      _toast('Kombinlərimə əlavə edildi');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      _toast(e.message);
    } catch (_) {
      if (!mounted) return;
      _toast('Kombin saxlanılmadı');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addOutfitToCart() async {
    if (_addingToCart || _outfit.displayItems.isEmpty) return;
    setState(() => _addingToCart = true);
    var added = 0;
    try {
      for (final item in _outfit.displayItems) {
        final product = item.product;
        if (product.id.isEmpty) continue;
        try {
          final detail = await _repo.fetchProductDetail(product.id);
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
      _toast(added > 0
          ? '$added məhsul səbətə əlavə edildi'
          : 'Səbətə əlavə edilmədi');
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  String get _totalLabel {
    var sum = 0.0;
    for (final item in _outfit.displayItems) {
      sum += TarzPriceUtils.parseManat(item.product.priceLabel);
    }
    return TarzPriceUtils.formatManatSpaced(sum);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] TarzAiOutfitGenerateScreen');
    final items = _outfit.displayItems;
    final busy = _generating || _saving || _addingToCart;

    return Scaffold(
      backgroundColor: TarzColors.background,
      appBar: AppBar(
        title: const Text('AI kombini generasiya et'),
        backgroundColor: Colors.white,
        foregroundColor: TarzColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Məhsul axtar (məs. don, ceket...)',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: TarzColors.ink),
              ),
            ),
          ),
          if (_searching) ...[
            const SizedBox(height: 16),
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ] else if (_results.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._results.take(12).map(
                  (p) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _thumb(p.imageUrl),
                    title: Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(p.priceLabel),
                    trailing: const Icon(Icons.auto_awesome_rounded, size: 20),
                    onTap: busy ? null : () => _generateFrom(p),
                  ),
                ),
          ],
          if (_anchor != null) ...[
            const SizedBox(height: 20),
            Text(
              'Seçilmiş məhsul',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TarzColors.inkMuted.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _thumb(_anchor!.imageUrl),
              title: Text(
                _anchor!.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(_anchor!.priceLabel),
            ),
          ],
          if (_generating) ...[
            const SizedBox(height: 28),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(height: 12),
                  Text('AI kombin generasiya edilir...'),
                ],
              ),
            ),
          ],
          if (_error != null && !_generating) ...[
            const SizedBox(height: 20),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
          if (items.isNotEmpty && !_generating) ...[
            const SizedBox(height: 20),
            const Text(
              'Yaradılmış kombin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final item = items[i];
                  final p = item.product;
                  return SizedBox(
                    width: 96,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _thumb(p.imageUrl, size: 96),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${items.length} məhsul · Ümumi $_totalLabel',
              style: TextStyle(
                fontSize: 13,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: busy ? null : _saveOutfit,
                style: FilledButton.styleFrom(
                  backgroundColor: TarzColors.ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _saving ? 'Saxlanılır...' : 'Kombinlərimə əlavə et',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: busy ? null : _addOutfitToCart,
                icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                label: Text(
                  _addingToCart ? 'Əlavə edilir...' : 'Səbətə əlavə et',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TarzColors.ink,
                  side: const BorderSide(color: TarzColors.ink, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          if (_anchor == null && _results.isEmpty && !_searching) ...[
            const SizedBox(height: TarzSpacing.xl),
            Icon(
              Icons.auto_awesome_rounded,
              size: 48,
              color: TarzColors.inkMuted.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 12),
            Text(
              'Məhsul seçin — AI uyğun ayaqqabı, çanta və üst geyim tapacaq.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _thumb(String? url, {double size = 48}) {
    final cache = TarzImageCache.px(context, size);
    if (url == null || url.isEmpty) {
      return ColoredBox(
        color: const Color(0xFFF0F0F0),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.checkroom_outlined,
            color: TarzColors.inkMuted.withValues(alpha: 0.4),
          ),
        ),
      );
    }
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      cacheWidth: cache,
      cacheHeight: cache,
      errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFF0F0F0)),
    );
  }
}
