import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../models/tarz_store_preview.dart';
import '../../theme/tarz_colors.dart';
import '../../theme/tarz_home_layout.dart';

/// «Mağazalar» — Figma 469×235, 2 sıralı üfüqi scroll (vertical parent ilə).
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
    debugPrint('[rebuild] StoreChipsSection');
    final columns = _buildColumns(stores);

    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth;
          final gridHeight =
              TarzHomeLayout.scaledStoresGridHeight(viewportWidth);
          final cardWidth =
              TarzHomeLayout.scaledStoreCardWidth(viewportWidth);
          final cardHeight =
              TarzHomeLayout.scaledStoreCardHeight(viewportWidth);
          final cardGap =
              TarzHomeLayout.scaledStoreCardGap(viewportWidth);
          final fontSize = (15 * TarzHomeLayout.storesContentScale(viewportWidth))
              .clamp(13.0, 16.0);

          return Column(
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
                height: gridHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: TarzHomeLayout.horizontalPadding,
                  ),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  primary: false,
                  clipBehavior: Clip.hardEdge,
                  dragStartBehavior: DragStartBehavior.down,
                  itemCount: columns.length,
                  separatorBuilder: (_, __) => SizedBox(width: cardGap),
                  itemBuilder: (context, index) {
                    final (top, bottom) = columns[index];
                    return _StoreColumn(
                      top: top,
                      bottom: bottom,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      cardGap: cardGap,
                      labelFontSize: fontSize,
                      onStoreTap: onStoreTap,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

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
    required this.cardWidth,
    required this.cardHeight,
    required this.cardGap,
    required this.labelFontSize,
    this.onStoreTap,
  });

  final TarzStorePreview? top;
  final TarzStorePreview? bottom;
  final double cardWidth;
  final double cardHeight;
  final double cardGap;
  final double labelFontSize;
  final ValueChanged<TarzStorePreview>? onStoreTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (top != null)
          _StoreCard(
            store: top!,
            width: cardWidth,
            height: cardHeight,
            labelFontSize: labelFontSize,
            onTap: () => onStoreTap?.call(top!),
          ),
        if (top != null && bottom != null) SizedBox(height: cardGap),
        if (bottom != null)
          _StoreCard(
            store: bottom!,
            width: cardWidth,
            height: cardHeight,
            labelFontSize: labelFontSize,
            onTap: () => onStoreTap?.call(bottom!),
          ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.store,
    required this.width,
    required this.height,
    required this.labelFontSize,
    this.onTap,
  });

  final TarzStorePreview store;
  final double width;
  final double height;
  final double labelFontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius =
        BorderRadius.circular(TarzHomeLayout.storeCardRadius);
    final scale = width / TarzHomeLayout.storeCardWidth;
    final borderWidth = TarzHomeLayout.storeCardBorderWidth * scale;

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: TarzHomeLayout.storeCardBackground,
            borderRadius: borderRadius,
            border: Border.all(
              color: TarzHomeLayout.storeCardBorderColor,
              width: borderWidth,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              child: Text(
                store.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: TarzHomeLayout.storeCardLabelColor,
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
