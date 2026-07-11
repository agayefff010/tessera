import 'package:flutter/material.dart';

import '../../models/tarz_store_preview.dart';
import '../../theme/tarz_colors.dart';
import '../../theme/tarz_home_layout.dart';

/// «Mağazalar» — 2 sıralı üfüqi scroll grid (Figma).
class StoreChipsSection extends StatelessWidget {
  const StoreChipsSection({
    super.key,
    required this.stores,
    this.onStoreTap,
  });

  final List<TarzStorePreview> stores;
  final ValueChanged<TarzStorePreview>? onStoreTap;

  @override
  Widget build(BuildContext context) {
    final columns = _buildColumns(stores);

    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: TarzHomeLayout.horizontalPadding,
            ),
            child: Text(
              'Mağazalar',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TarzColors.ink,
              ),
            ),
          ),
          const SizedBox(height: TarzHomeLayout.storesTitleSpacing),
          SizedBox(
            height: TarzHomeLayout.storesGridHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: TarzHomeLayout.horizontalPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var col = 0; col < columns.length; col++) ...[
                    if (col > 0)
                      const SizedBox(width: TarzHomeLayout.storeCardGap),
                    _StoreColumn(
                      top: columns[col].$1,
                      bottom: columns[col].$2,
                      onStoreTap: onStoreTap,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sütunlar: [üst, alt] — Figma düzülüşü.
  static List<(TarzStorePreview?, TarzStorePreview?)> _buildColumns(
    List<TarzStorePreview> stores,
  ) {
    final columns = <(TarzStorePreview?, TarzStorePreview?)>[];
    for (var i = 0; i < stores.length; i += 2) {
      final top = stores[i];
      final bottom = i + 1 < stores.length ? stores[i + 1] : null;
      columns.add((top, bottom));
    }
    return columns;
  }

  /// TODO: API-dən mağaza siyahısı ilə əvəz et.
  static List<TarzStorePreview> mockStores() => const [
        TarzStorePreview(id: 'sterns', name: 'STERNS'),
        TarzStorePreview(id: 'fabiani', name: 'FABIANI'),
        TarzStorePreview(id: 'archive', name: 'ARCHIVE'),
        TarzStorePreview(id: 'bottega', name: 'BOTTEGA VENETA'),
        TarzStorePreview(id: 'gant', name: 'GANT'),
        TarzStorePreview(id: 'the_fix', name: 'THE FIX'),
      ];
}

class _StoreColumn extends StatelessWidget {
  const _StoreColumn({
    required this.top,
    required this.bottom,
    this.onStoreTap,
  });

  final TarzStorePreview? top;
  final TarzStorePreview? bottom;
  final ValueChanged<TarzStorePreview>? onStoreTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (top != null)
          _StoreCard(
            store: top!,
            onTap: () => onStoreTap?.call(top!),
          ),
        if (top != null && bottom != null)
          const SizedBox(height: TarzHomeLayout.storeCardGap),
        if (bottom != null)
          _StoreCard(
            store: bottom!,
            onTap: () => onStoreTap?.call(bottom!),
          ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.store,
    this.onTap,
  });

  final TarzStorePreview store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius =
        BorderRadius.circular(TarzHomeLayout.storeCardRadius);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          width: TarzHomeLayout.storeCardWidth,
          height: TarzHomeLayout.storeCardHeight,
          decoration: BoxDecoration(
            color: TarzHomeLayout.storeCardBackground,
            borderRadius: borderRadius,
            border: Border.all(
              color: TarzHomeLayout.storeCardBorderColor,
              width: TarzHomeLayout.storeCardBorderWidth,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _StoreLogo(store: store),
        ),
      ),
    );
  }
}

class _StoreLogo extends StatelessWidget {
  const _StoreLogo({required this.store});

  final TarzStorePreview store;

  @override
  Widget build(BuildContext context) {
    final logoUrl = store.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _StoreLabel(name: store.name),
      );
    }

    final logoAsset = store.logoAsset;
    if (logoAsset != null && logoAsset.isNotEmpty) {
      return Image.asset(
        logoAsset,
        fit: BoxFit.fill,
        errorBuilder: (_, __, ___) => _StoreLabel(name: store.name),
      );
    }

    return _StoreLabel(name: store.name);
  }
}

class _StoreLabel extends StatelessWidget {
  const _StoreLabel({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: TarzHomeLayout.storeCardLabelColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
