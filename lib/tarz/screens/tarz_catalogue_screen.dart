import 'package:flutter/material.dart';

import '../data/tarz_mock_catalog.dart';
import '../theme/tarz_breakpoints.dart';
import '../widgets/catalogue/catalogue_search_bar.dart';
import '../widgets/catalogue/category_list_item.dart';
import '../widgets/catalogue/children_catalogue_section.dart';
import '../widgets/catalogue/gender_selector.dart';

/// Kataloq ekranı — cins seqmenti və animasiyalı kateqoriya siyahısı.
class TarzCatalogueScreen extends StatefulWidget {
  const TarzCatalogueScreen({
    super.key,
    required this.onSearchTap,
    required this.onCartTap,
    required this.onCategoryTap,
    required this.genderIndex,
    required this.onGenderChanged,
    this.selectedCategoryIndex = 0,
    this.onCategoryIndexChanged,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;
  final ValueChanged<String> onCategoryTap;
  final int genderIndex;
  final ValueChanged<int> onGenderChanged;
  final int selectedCategoryIndex;
  final ValueChanged<int>? onCategoryIndexChanged;

  static const int kidsGenderIndex = 2;

  @override
  State<TarzCatalogueScreen> createState() => _TarzCatalogueScreenState();
}

class _TarzCatalogueScreenState extends State<TarzCatalogueScreen> {
  static const Duration _underlineDuration = Duration(milliseconds: 200);
  static const double _underlineHeight = 4;
  static const double _underlineGap = 6;

  final GlobalKey _listKey = GlobalKey();
  late final List<GlobalKey> _textKeys;

  double _underlineLeft = 0;
  double _underlineTop = 0;
  double _underlineWidth = 0;
  bool _underlineReady = false;

  List<String> get _categories => TarzMockCatalog.catalogueCategories;

  bool get _isKidsMode => widget.genderIndex == TarzCatalogueScreen.kidsGenderIndex;

  int get _safeCategoryIndex => widget.selectedCategoryIndex.clamp(
        0,
        _categories.length - 1,
      );

  Color get _accentColor => GenderSelector.colorForIndex(widget.genderIndex);

  @override
  void initState() {
    super.initState();
    _textKeys = List.generate(_categories.length, (_) => GlobalKey());
    if (!_isKidsMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureUnderline());
    }
  }

  @override
  void didUpdateWidget(TarzCatalogueScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.genderIndex != widget.genderIndex) {
      if (_isKidsMode) {
        setState(() => _underlineReady = false);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measureUnderline());
      }
    } else if (!_isKidsMode &&
        oldWidget.selectedCategoryIndex != widget.selectedCategoryIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureUnderline());
    }
  }

  void _onGenderChanged(int index) {
    widget.onGenderChanged(index);
    if (index != TarzCatalogueScreen.kidsGenderIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureUnderline());
    }
  }

  void _onCategorySelected(int index) {
    widget.onCategoryIndexChanged?.call(index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureUnderline();
      widget.onCategoryTap(_categories[index]);
    });
  }

  void _measureUnderline() {
    if (_isKidsMode) return;

    final listContext = _listKey.currentContext;
    final textContext = _textKeys[_safeCategoryIndex].currentContext;
    if (listContext == null || textContext == null) return;

    final listBox = listContext.findRenderObject() as RenderBox?;
    final textBox = textContext.findRenderObject() as RenderBox?;
    if (listBox == null || textBox == null || !listBox.hasSize || !textBox.hasSize) {
      return;
    }

    final offset = textBox.localToGlobal(Offset.zero, ancestor: listBox);
    setState(() {
      _underlineLeft = offset.dx;
      _underlineTop = offset.dy + textBox.size.height + _underlineGap;
      _underlineWidth = textBox.size.width;
      _underlineReady = true;
    });
  }

  Widget _buildCategoryList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Stack(
        key: _listKey,
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(_categories.length, (index) {
              final label = _categories[index];
              return CategoryListItem(
                label: label,
                isSelected: index == _safeCategoryIndex,
                textKey: _textKeys[index],
                onTap: () => _onCategorySelected(index),
              );
            }),
          ),
          if (_underlineReady)
            AnimatedPositioned(
              duration: _underlineDuration,
              curve: Curves.easeOutCubic,
              left: _underlineLeft,
              top: _underlineTop,
              width: _underlineWidth,
              height: _underlineHeight,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: _underlineDuration,
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKidsCatalogue() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: ChildrenCatalogueSection(
        blocks: TarzMockCatalog.childrenCatalogueBlocks(),
        onBlockTap: widget.onCategoryTap,
        onSubcategoryTap: widget.onCategoryTap,
      ),
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatalogueSearchBar(
                  onSearchTap: widget.onSearchTap,
                  onCartTap: widget.onCartTap,
                ),
                GenderSelector(
                  labels: TarzMockCatalog.categories,
                  selectedIndex: widget.genderIndex,
                  onSelected: _onGenderChanged,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _isKidsMode
                        ? KeyedSubtree(
                            key: const ValueKey('kids_catalogue'),
                            child: _buildKidsCatalogue(),
                          )
                        : KeyedSubtree(
                            key: const ValueKey('standard_catalogue'),
                            child: _buildCategoryList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
