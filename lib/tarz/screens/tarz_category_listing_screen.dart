import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../models/tarz_product_preview.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../widgets/tarz_home_drawer.dart';
import '../widgets/tarz_home_top_bar.dart';
import '../widgets/tarz_listing_product_tile.dart';

/// Kateqoriya / «Trend» tipli məhsul siyahısı səhifəsi.
class TarzCategoryListingScreen extends StatefulWidget {
  const TarzCategoryListingScreen({
    super.key,
    required this.title,
    required this.products,
  });

  final String title;
  final List<TarzProductPreview> products;

  @override
  State<TarzCategoryListingScreen> createState() => _TarzCategoryListingScreenState();
}

class _TarzCategoryListingScreenState extends State<TarzCategoryListingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _drawerGenderIndex = 0;

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: TarzHomeDrawer(
        selectedGenderIndex: _drawerGenderIndex,
        onGenderSelected: (i) => setState(() => _drawerGenderIndex = i),
        onCategoryTap: (label) => _toast(label),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TarzHomeTopBar(
              onMenu: _openDrawer,
              onSearch: () => Navigator.of(context).pushNamed(AppRoutes.search),
              onWishlist: () => _toast('Seçilmişlər'),
              onCart: () => _toast('Səbət'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TarzSpacing.xs,
                0,
                TarzSpacing.md,
                TarzSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    tooltip: 'Geri',
                    style: IconButton.styleFrom(foregroundColor: TarzColors.ink),
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TarzSpacing.md,
                0,
                TarzSpacing.md,
                TarzSpacing.md,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _toast('Çeşidləmə'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Çeşidləmə',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: TarzColors.ink.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 22,
                            color: TarzColors.ink.withValues(alpha: 0.55),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => _toast('Filtrlər'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Filtrlər',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: TarzColors.ink.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.filter_list_rounded,
                            size: 20,
                            color: TarzColors.ink.withValues(alpha: 0.55),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  TarzSpacing.md,
                  0,
                  TarzSpacing.md,
                  TarzSpacing.xl,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.54,
                ),
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  final p = widget.products[index];
                  return TarzListingProductTile(
                    product: p,
                    onTap: () => _toast(p.title),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
