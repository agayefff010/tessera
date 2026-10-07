import 'dart:async';

import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../data/product_repository.dart';
import '../models/tarz_product_preview.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../utils/tarz_image_cache.dart';
import '../widgets/tarz_flash_message.dart';
import '../widgets/tarz_home_search_bar.dart';

/// Axtarış — real-time autocomplete (`GET /products/search/autocomplete`).
class TarzSearchScreen extends StatefulWidget {
  const TarzSearchScreen({super.key});

  @override
  State<TarzSearchScreen> createState() => _TarzSearchScreenState();
}

class _TarzSearchScreenState extends State<TarzSearchScreen> {
  final _controller = TextEditingController();
  final _repo = ProductRepository();

  Timer? _debounce;
  int _requestId = 0;
  List<TarzProductPreview> _results = [];
  bool _loading = false;
  String? _error;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _repo.dispose();
    super.dispose();
  }

  void _toast(String message) => TarzFlashMessage.show(context, message);

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
        _error = null;
        _lastQuery = '';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    _debounce = Timer(const Duration(milliseconds: 320), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    final id = ++_requestId;
    _lastQuery = query;
    try {
      final results = await _repo.fetchAutocomplete(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _loading = false;
        _error = 'Axtarış alınmadı';
      });
    }
  }

  void _submitSearch([String? overrideQuery]) {
    final query = (overrideQuery ?? _controller.text).trim();
    if (query.isEmpty) {
      _toast('Axtarış üçün mətn daxil edin');
      return;
    }

    _debounce?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.productListing,
        arguments: ProductListingArgs(
          title: '«$query»',
          searchQuery: query,
          products: List<TarzProductPreview>.from(_results),
          totalCount: _results.length,
        ),
      );
    });
  }

  void _openProduct(TarzProductPreview product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetails,
      arguments: ProductDetailsArgs(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] TarzSearchScreen');
    final query = _controller.text.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: TarzColors.ink,
        toolbarHeight: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Geri',
        ),
        title: const Text(
          'Axtarış',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TarzColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TarzHomeSearchBar(
                controller: _controller,
                autofocus: true,
                onChanged: _onQueryChanged,
                onSearch: (_) => _submitSearch(),
                padding: const EdgeInsets.fromLTRB(
                  TarzSpacing.md,
                  0,
                  TarzSpacing.md,
                  TarzSpacing.sm,
                ),
              ),
              if (_loading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: TarzColors.ink,
                  backgroundColor: Color(0xFFEFEFEF),
                ),
              Expanded(
                child: _buildBody(query),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(String query) {
    if (query.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            'Axtarın',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: TarzColors.inkMuted.withValues(alpha: 0.9),
            ),
          ),
        ),
      );
    }

    if (_error != null && _results.isEmpty) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
      );
    }

    if (!_loading && _results.isEmpty && _lastQuery == query) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            '«$query» üçün nəticə tapılmadı',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: TarzColors.inkMuted.withValues(alpha: 0.9),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        TarzSpacing.md,
        TarzSpacing.sm,
        TarzSpacing.md,
        TarzSpacing.xl,
      ),
      itemCount: _results.length + (_results.isNotEmpty ? 1 : 0),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFECECEC)),
      itemBuilder: (context, index) {
        if (index == _results.length) {
          return TextButton(
            onPressed: () => _submitSearch(
              _lastQuery.isNotEmpty ? _lastQuery : query,
            ),
            child: Text(
              'Bütün nəticələrə bax («$query»)',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
          );
        }
        final product = _results[index];
        return _SearchResultTile(
          product: product,
          onTap: () => _openProduct(product),
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.product,
    this.onTap,
  });

  final TarzProductPreview product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    final cache = TarzImageCache.px(context, 56);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: url == null || url.isEmpty
              ? const ColoredBox(color: Color(0xFFF0F0F0))
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  cacheWidth: cache,
                  cacheHeight: cache,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: Color(0xFFF0F0F0)),
                ),
        ),
      ),
      title: Text(
        product.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: TarzColors.ink,
        ),
      ),
      subtitle: Text(
        [
          if (product.brand != null && product.brand!.isNotEmpty) product.brand!,
          product.priceLabel,
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: TarzColors.inkMuted.withValues(alpha: 0.95),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: TarzColors.ink),
    );
  }
}
