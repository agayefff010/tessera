import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/auth_service.dart';
import '../models/tarz_outfit.dart';
import '../models/tarz_product_preview.dart';
import '../outfits/tarz_outfits_controller.dart';
import '../theme/tarz_breakpoints.dart';
import '../theme/tarz_colors.dart';
import '../utils/tarz_image_cache.dart';
import '../widgets/cart/tarz_checkout_sheet.dart';
import '../widgets/tarz_flash_message.dart';

/// Kombinlərim — `GET /outfits/me`.
class TarzOutfitsScreen extends StatefulWidget {
  const TarzOutfitsScreen({super.key});

  @override
  State<TarzOutfitsScreen> createState() => _TarzOutfitsScreenState();
}

class _TarzOutfitsScreenState extends State<TarzOutfitsScreen> {
  final _outfits = TarzOutfitsController.instance;
  final _auth = AuthService();
  final Set<String> _generatingAiImages = {};
  final Set<String> _deletingOutfits = {};
  bool _checkingAuth = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _outfits.addListener(_onChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    _outfits.removeListener(_onChanged);
    _auth.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _bootstrap() async {
    final loggedIn = await _auth.isLoggedIn();
    if (!mounted) return;
    setState(() {
      _loggedIn = loggedIn;
      _checkingAuth = false;
    });
    if (loggedIn) {
      await _outfits.reload();
    }
  }

  Future<void> _promptLogin() async {
    final action = await showTarzAuthRequiredDialog(
      context,
      message: 'Kombinlərinizə baxmaq üçün daxil olun.',
    );
    if (!mounted || action == null) return;
    if (action == TarzAuthPromptAction.login) {
      await Navigator.of(context).pushNamed(AppRoutes.login);
    } else {
      await Navigator.of(context).pushNamed(AppRoutes.register);
    }
    if (!mounted) return;
    await _bootstrap();
  }

  void _openProduct(TarzProductPreview product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetails,
      arguments: ProductDetailsArgs(product: product),
    );
  }

  Future<void> _openAiOutfitBuilder() async {
    final saved = await Navigator.of(context).pushNamed(
      AppRoutes.aiOutfitGenerate,
    );
    if (!mounted) return;
    if (saved == true && _loggedIn) {
      await _outfits.reload();
    }
  }

  Future<void> _confirmDeleteOutfit(TarzSavedOutfit outfit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kombini sil'),
        content: Text(
          '«${outfit.title}» kombinini silmək istəyirsiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ləğv et'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _deleteOutfit(outfit);
  }

  Future<void> _deleteOutfit(TarzSavedOutfit outfit) async {
    if (_deletingOutfits.contains(outfit.id)) return;
    setState(() => _deletingOutfits.add(outfit.id));
    try {
      await _outfits.deleteOutfit(outfit);
      if (!mounted) return;
      TarzFlashMessage.show(context, 'Kombin silindi');
    } on ApiException catch (e) {
      if (!mounted) return;
      TarzFlashMessage.show(context, e.message);
    } catch (_) {
      if (!mounted) return;
      TarzFlashMessage.show(context, 'Kombin silinmədi');
    } finally {
      if (mounted) {
        setState(() => _deletingOutfits.remove(outfit.id));
      }
    }
  }

  Future<void> _generateAiImage(TarzSavedOutfit outfit) async {
    if (_generatingAiImages.contains(outfit.id)) return;
    setState(() => _generatingAiImages.add(outfit.id));
    try {
      await _outfits.generateAiImage(outfit);
      if (!mounted) return;
      TarzFlashMessage.show(context, 'AI obraz yaradıldı');
    } on ApiException catch (e) {
      if (!mounted) return;
      TarzFlashMessage.show(context, e.message);
    } catch (_) {
      if (!mounted) return;
      TarzFlashMessage.show(context, 'AI obraz yaradılmadı');
    } finally {
      if (mounted) {
        setState(() => _generatingAiImages.remove(outfit.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = TarzBreakpoints.contentMaxWidth(constraints.maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: RefreshIndicator(
              onRefresh: () async {
                if (!_loggedIn) {
                  await _promptLogin();
                  return;
                }
                await _outfits.reload();
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text(
                        'Kombinlərim',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: TarzColors.ink,
                        ),
                      ),
                    ),
                  ),
                  if (_checkingAuth || (_loggedIn && _outfits.isLoading))
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (!_loggedIn)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        title: 'Daxil olun',
                        subtitle:
                            'Saxladığınız kombinləri görmək üçün hesabınıza daxil olun.',
                        actionLabel: 'Daxil ol',
                        onAction: _promptLogin,
                      ),
                    )
                  else if (_outfits.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        title: 'Kombinlərim',
                        subtitle:
                            'Məhsul səhifəsində «Kombinlərimə əlavə et» ilə buraya əlavə edin.',
                        actionLabel: 'AI kombini generasiya et',
                        onAction: _openAiOutfitBuilder,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverList.separated(
                        itemCount: _outfits.outfits.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final outfit = _outfits.outfits[index];
                          return _SavedOutfitCard(
                            outfit: outfit,
                            onProductTap: _openProduct,
                            deleting: _deletingOutfits.contains(outfit.id),
                            onDelete: () => _confirmDeleteOutfit(outfit),
                            generatingAiImage:
                                _generatingAiImages.contains(outfit.id),
                            onGenerateAiImage: () => _generateAiImage(outfit),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 56,
            color: TarzColors.inkMuted.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: TarzColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: TarzColors.inkMuted.withValues(alpha: 0.9),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: TarzColors.ink,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _SavedOutfitCard extends StatelessWidget {
  const _SavedOutfitCard({
    required this.outfit,
    this.deleting = false,
    this.generatingAiImage = false,
    this.onDelete,
    this.onProductTap,
    this.onGenerateAiImage,
  });

  final TarzSavedOutfit outfit;
  final bool deleting;
  final bool generatingAiImage;
  final VoidCallback? onDelete;
  final ValueChanged<TarzProductPreview>? onProductTap;
  final VoidCallback? onGenerateAiImage;

  @override
  Widget build(BuildContext context) {
    final products = outfit.items.map((e) => e.product).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                outfit.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TarzColors.ink,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: deleting ? null : onDelete,
              icon: deleting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red.shade700,
                      ),
                    )
                  : Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Colors.red.shade700,
                    ),
              label: Text(
                'Sil',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECECEC)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            if (products.isNotEmpty)
              SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final product = products[i];
                    final url = product.imageUrl;
                    final cache = TarzImageCache.px(context, 96);
                    return GestureDetector(
                      onTap: onProductTap == null
                          ? null
                          : () => onProductTap!(product),
                      child: SizedBox(
                        width: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: url == null || url.isEmpty
                                    ? ColoredBox(
                                        color: const Color(0xFFF0F0F0),
                                        child: Icon(
                                          Icons.checkroom_outlined,
                                          color: TarzColors.inkMuted
                                              .withValues(alpha: 0.4),
                                        ),
                                      )
                                    : Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        cacheWidth: cache,
                                        cacheHeight: cache,
                                        errorBuilder: (_, __, ___) =>
                                            const ColoredBox(
                                          color: Color(0xFFF0F0F0),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: TarzColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Text(
                '${outfit.items.length} məhsul',
                style: TextStyle(
                  fontSize: 13,
                  color: TarzColors.inkMuted.withValues(alpha: 0.9),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              '${outfit.items.length} məhsul',
              style: TextStyle(
                fontSize: 12,
                color: TarzColors.inkMuted.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 12),
            if (outfit.hasAiImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Image.network(
                    outfit.aiImageUrl!,
                    fit: BoxFit.cover,
                    cacheWidth: TarzImageCache.px(context, 360),
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: Color(0xFFF0F0F0)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              height: 46,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: generatingAiImage ? null : onGenerateAiImage,
                icon: generatingAiImage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(
                  generatingAiImage
                      ? 'AI obraz yaradılır...'
                      : outfit.hasAiImage
                          ? 'AI obrazı yenilə'
                          : 'AI obraz yarat',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TarzColors.ink,
                  side: const BorderSide(color: TarzColors.ink, width: 1.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (outfit.aiImageStatus != null &&
                outfit.aiImageStatus!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'AI status: ${_aiStatusLabel(outfit.aiImageStatus!)}',
                style: TextStyle(
                  fontSize: 11,
                  color: TarzColors.inkMuted.withValues(alpha: 0.8),
                ),
              ),
            ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _aiStatusLabel(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('complete')) return 'hazırdır';
    if (value.contains('pending') || value.contains('process')) {
      return 'hazırlanır';
    }
    if (value.contains('fail') || value.contains('error')) return 'alınmadı';
    return raw;
  }
}
