import 'package:flutter/material.dart';

import '../../models/tarz_children_catalogue_block.dart';
import 'children_catalogue_block.dart';

/// Uşaq kataloqu — 3 vizual blokun şaquli siyahısı.
class ChildrenCatalogueSection extends StatelessWidget {
  const ChildrenCatalogueSection({
    super.key,
    required this.blocks,
    required this.onBlockTap,
    this.onSubcategoryTap,
  });

  final List<TarzChildrenCatalogueBlock> blocks;
  final ValueChanged<String> onBlockTap;
  final ValueChanged<String>? onSubcategoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 2),
          ChildrenCatalogueBlock(
            data: blocks[i],
            onBlockTap: () => onBlockTap(blocks[i].title),
            onSubcategoryTap: onSubcategoryTap,
          ),
        ],
      ],
    );
  }
}
