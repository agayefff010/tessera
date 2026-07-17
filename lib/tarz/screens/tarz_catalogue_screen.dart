import 'package:flutter/material.dart';

import '../data/category_repository.dart';
import '../models/plp_category_option.dart';
import '../models/tarz_children_catalogue_block.dart';
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
  final ValueChanged<PlpCategoryOption> onCategoryTap;
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
  final CategoryRepository _categoryRepo = CategoryRepository.instance;
  late List<GlobalKey> _textKeys;

  List<PlpCategoryOption> _categories = const [];
  List<TarzChildrenCatalogueBlock> _kidsBlocks = const [];
  bool _categoriesLoading = true;
  bool _kidsLoading = false;

  double _underlineLeft = 0;
  double _underlineTop = 0;
  double _underlineWidth = 0;
  bool _underlineReady = false;

  bool get _isKidsMode =>
      widget.genderIndex == TarzCatalogueScreen.kidsGenderIndex;

  int get _safeCategoryIndex => widget.selectedCategoryIndex.clamp(
        0,
        _categories.isEmpty ? 0 : _categories.length - 1,
      );

  Color get _accentColor => GenderSelector.colorForIndex(widget.genderIndex);

  @override
  void initState() {
    super.initState();
    _textKeys = [];
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _categoriesLoading = true);
    try {
      if (_isKidsMode) {
        setState(() {
          _categoriesLoading = false;
          _categories = const [];
        });
        await _loadKidsBlocks();
        return;
      }

      final cats =
          await _categoryRepo.fetchCatalogueCategories(widget.genderIndex);
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _categoriesLoading = false;
        _textKeys = List.generate(cats.length, (_) => GlobalKey());
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureUnderline());
    } catch (_) {
      if (!mounted) return;
      setState(() => _categoriesLoading = false);
    }
  }

  Future<void> _loadKidsBlocks() async {
    setState(() => _kidsLoading = true);
    try {
      final blocks = await _categoryRepo.fetchKidsCatalogueBlocks();
      if (!mounted) return;
      setState(() {
        _kidsBlocks = blocks;
        _kidsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _kidsLoading = false);
    }
  }

  @override
  void didUpdateWidget(TarzCatalogueScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.genderIndex != widget.genderIndex) {
      _loadCategories();
      if (_isKidsMode) {
        setState(() => _underlineReady = false);
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
      if (index < _categories.length) {
        widget.onCategoryTap(_categories[index]);
      }
    });
  }

  void _measureUnderline() {
    if (_isKidsMode || _categories.isEmpty) return;

    final listContext = _listKey.currentContext;
    final textContext = _textKeys[_safeCategoryIndex].currentContext;
    if (listContext == null || textContext == null) return;

    final listBox = listContext.findRenderObject() as RenderBox?;
    final textBox = textContext.findRenderObject() as RenderBox?;
    if (listBox == null ||
        textBox == null ||
        !listBox.hasSize ||
        !textBox.hasSize) {
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
    if (_categoriesLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('Kateqoriya tapılmadı'));
    }

    return SingleChildScrollView(
      key: PageStorageKey<String>('catalogue_scroll_${widget.genderIndex}'),
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
              final option = _categories[index];
              return CategoryListItem(
                label: option.name,
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
    if (_kidsLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_kidsBlocks.isEmpty) {
      return const Center(child: Text('Kateqoriya tapılmadı'));
    }

    return SingleChildScrollView(
      key: PageStorageKey<String>('catalogue_kids_scroll'),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: ChildrenCatalogueSection(
        blocks: _kidsBlocks,
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
