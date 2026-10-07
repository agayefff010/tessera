import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/plp_category_option.dart';
import '../models/product_filter_state.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../widgets/filter/tarz_filter_chip.dart';
import '../widgets/filter/tarz_filter_color_dot.dart';
import '../widgets/filter/tarz_filter_expandable_section.dart';
import '../widgets/filter/tarz_filter_outlined_tile.dart';
import '../widgets/filter/tarz_filter_season_section.dart';

/// Moda e-ticarət filtr səhifəsi (Zara / AboutYou üslubu).
class TarzFilterScreen extends StatefulWidget {
  const TarzFilterScreen({
    super.key,
    this.productCount,
    this.initial = const ProductFilterState(),
    this.categories = const [],
  });

  /// API/state-dən gələn məhsul sayı; null olduqda UI-da göstərilmir.
  final int? productCount;
  final ProductFilterState initial;
  final List<PlpCategoryOption> categories;

  @override
  State<TarzFilterScreen> createState() => _TarzFilterScreenState();
}

class _TarzFilterScreenState extends State<TarzFilterScreen> {
  static const Color _pageBg = Color(0xFFFAFAFA);
  static const Color _fieldBg = Colors.white;
  static const Color _fieldBorder = Color(0xFFE5E5E5);
  static const double _priceDomainMin = 0;
  static const double _priceDomainMax = 5000;

  int _quickFilterIndex = 2;

  final Set<String> _seasons = {};
  final TextEditingController _minPrice = TextEditingController();
  final TextEditingController _maxPrice = TextEditingController();
  RangeValues _priceRange = const RangeValues(100, 2480);

  bool _sortCheapFirst = false;
  bool _sortExpensiveFirst = false;

  bool _categoriesExpanded = false;
  bool _colorsExpanded = true;
  bool _sizesExpanded = true;
  bool _sortingExpanded = false;
  bool _categoriesShowMore = false;
  bool _colorsShowMore = false;

  final Set<String> _selectedSubcategoryIds = {};
  final Set<String> _selectedColors = {};
  final Set<String> _selectedSizes = {};

  static const _quickFilters = ['Endirimlər', 'Yenilər', 'Trend'];

  List<PlpCategoryOption> get _categoryOptions {
    if (widget.categories.isNotEmpty) return widget.categories;
    return const [
      PlpCategoryOption(id: 'fallback-1', name: 'Geyim'),
      PlpCategoryOption(id: 'fallback-2', name: 'Ayaqqabı'),
      PlpCategoryOption(id: 'fallback-3', name: 'Çantalar'),
      PlpCategoryOption(id: 'fallback-4', name: 'Aksesuarlar'),
      PlpCategoryOption(id: 'fallback-5', name: 'Donlar'),
    ];
  }

  static final _colorOptions = [
    const TarzFilterColorOption(id: 'black', label: 'Qara', color: Color(0xFF1A1A1A)),
    const TarzFilterColorOption(id: 'white', label: 'Ağ', color: Color(0xFFFFFFFF)),
    const TarzFilterColorOption(id: 'blue', label: 'Göy', color: Color(0xFF3D5A80)),
    const TarzFilterColorOption(id: 'green', label: 'Yaşıl', color: Color(0xFF4A6741)),
    const TarzFilterColorOption(id: 'orange', label: 'Narıncı', color: Color(0xFFE07A3A)),
    const TarzFilterColorOption(id: 'brown', label: 'Qəhvəyi', color: Color(0xFF6B4423)),
    const TarzFilterColorOption(id: 'gray', label: 'Boz', color: Color(0xFF9E9E9E)),
    const TarzFilterColorOption(id: 'pink', label: 'Çəhrayı', color: Color(0xFFE8A0BF)),
    const TarzFilterColorOption(id: 'red', label: 'Qırmızı', color: Color(0xFFC62828)),
    const TarzFilterColorOption(id: 'tan', label: 'Tan', color: Color(0xFFD4B896)),
  ];

  static const _letterSizes = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];

  @override
  void initState() {
    super.initState();
    _quickFilterIndex = widget.initial.quickFilterIndex;
    _sortCheapFirst = widget.initial.sortCheapFirst;
    _sortExpensiveFirst = widget.initial.sortExpensiveFirst;
    _selectedSubcategoryIds.addAll(widget.initial.subcategoryIds);

    if (widget.initial.minPrice != null || widget.initial.maxPrice != null) {
      _priceRange = RangeValues(
        widget.initial.minPrice ?? _priceDomainMin,
        widget.initial.maxPrice ?? _priceDomainMax,
      );
    }

    _minPrice.addListener(_syncPriceFromFields);
    _maxPrice.addListener(_syncPriceFromFields);
    _syncControllersFromRange();
  }

  @override
  void dispose() {
    _minPrice.removeListener(_syncPriceFromFields);
    _maxPrice.removeListener(_syncPriceFromFields);
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  void _syncControllersFromRange() {
    _minPrice.text = _priceRange.start.round().toString();
    _maxPrice.text = _priceRange.end.round().toString();
  }

  void _syncPriceFromFields() {
    final min = double.tryParse(_minPrice.text);
    final max = double.tryParse(_maxPrice.text);
    if (min == null || max == null || min > max) return;

    final next = RangeValues(
      min.clamp(_priceDomainMin, _priceDomainMax),
      max.clamp(_priceDomainMin, _priceDomainMax),
    );
    if (next.start != _priceRange.start || next.end != _priceRange.end) {
      setState(() => _priceRange = next);
    }
  }

  void _onPriceRangeChanged(RangeValues values) {
    setState(() {
      _priceRange = values;
      _minPrice.text = values.start.round().toString();
      _maxPrice.text = values.end.round().toString();
    });
  }

  void _resetFilters() {
    setState(() {
      _quickFilterIndex = 2;
      _seasons.clear();
      _priceRange = const RangeValues(100, 2480);
      _syncControllersFromRange();
      _sortCheapFirst = false;
      _sortExpensiveFirst = false;
      _selectedSubcategoryIds.clear();
      _selectedColors.clear();
      _selectedSizes.clear();
    });
  }

  void _toggleSeason(String s) {
    setState(() {
      if (_seasons.contains(s)) {
        _seasons.remove(s);
      } else {
        _seasons.add(s);
      }
    });
  }

  void _toggleSubcategory(String id) {
    setState(() {
      if (_selectedSubcategoryIds.contains(id)) {
        _selectedSubcategoryIds.remove(id);
      } else {
        _selectedSubcategoryIds.add(id);
      }
    });
  }

  void _toggleColor(String id) {
    setState(() {
      if (_selectedColors.contains(id)) {
        _selectedColors.remove(id);
      } else {
        _selectedColors.add(id);
      }
    });
  }

  void _toggleSize(String s) {
    setState(() {
      if (_selectedSizes.contains(s)) {
        _selectedSizes.remove(s);
      } else {
        _selectedSizes.add(s);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] TarzFilterScreen');
    final visibleCategories = _categoriesShowMore
        ? _categoryOptions
        : _categoryOptions.take(5).toList();
    final primaryColors = _colorOptions.take(5).toList();
    final extraColors = _colorOptions.skip(5).toList();
    final visibleExtraColors = _colorsShowMore ? extraColors : <TarzFilterColorOption>[];

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  TarzSpacing.md,
                  TarzSpacing.sm,
                  TarzSpacing.md,
                  TarzSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQuickFilters(),
                    const SizedBox(height: 14),
                    _buildSeasonSection(),
                    const SizedBox(height: 14),
                    _buildPriceSection(),
                    const SizedBox(height: 14),
                    _buildColorsSection(primaryColors, visibleExtraColors),
                    const SizedBox(height: 14),
                    _buildSizesSection(),
                    const SizedBox(height: 8),
                    _buildSortingSection(),
                    _buildCategoriesSection(visibleCategories),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  tooltip: 'Bağla',
                  style: IconButton.styleFrom(foregroundColor: TarzColors.ink),
                ),
                const Expanded(
                  child: Text(
                    'Filtrlər',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  style: TextButton.styleFrom(
                    foregroundColor: TarzColors.ink,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text(
                    'Sıfırla',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          if (widget.productCount != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${widget.productCount} məhsul',
                style: TextStyle(
                  fontSize: 12,
                  color: TarzColors.inkMuted.withValues(alpha: 0.9),
                ),
              ),
            ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_quickFilters.length, (i) {
        return TarzFilterChip(
          label: _quickFilters[i],
          selected: _quickFilterIndex == i,
          compact: true,
          onTap: () => setState(() => _quickFilterIndex = i),
        );
      }),
    );
  }

  Widget _buildSeasonSection() {
    return TarzFilterSeasonSection(
      selectedSeasons: _seasons,
      onSeasonToggled: _toggleSeason,
    );
  }

  Widget _buildPriceSection() {
    final rangeLabel =
        '${_priceRange.start.round()} ₼ — ${_priceRange.end.round()} ₼';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Qiymət'),
        const SizedBox(height: 6),
        Text(
          rangeLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TarzColors.ink,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            activeTrackColor: TarzColors.ink,
            inactiveTrackColor: const Color(0xFFE0E0E0),
            thumbColor: TarzColors.ink,
            overlayColor: TarzColors.ink.withValues(alpha: 0.08),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: RangeSlider(
            values: _priceRange,
            min: _priceDomainMin,
            max: _priceDomainMax,
            onChanged: _onPriceRangeChanged,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: _priceField(_minPrice, 'Minimum')),
            const SizedBox(width: 10),
            Expanded(child: _priceField(_maxPrice, 'Maksimum')),
          ],
        ),
      ],
    );
  }

  Widget _priceField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 14, color: TarzColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: TarzColors.inkMuted.withValues(alpha: 0.55),
        ),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TarzColors.ink, width: 1.2),
        ),
        suffixText: '₼',
        suffixStyle: TextStyle(
          fontSize: 13,
          color: TarzColors.inkMuted.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildColorsSection(
    List<TarzFilterColorOption> primary,
    List<TarzFilterColorOption> extra,
  ) {
    return TarzFilterExpandableSection(
      title: 'Rəng',
      expanded: _colorsExpanded,
      onToggle: () => setState(() => _colorsExpanded = !_colorsExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: primary.map((opt) {
              return TarzFilterColorDot(
                option: opt,
                selected: _selectedColors.contains(opt.id),
                compact: true,
                onTap: () => _toggleColor(opt.id),
              );
            }).toList(),
          ),
          if (extra.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: extra.map((opt) {
                return TarzFilterColorDot(
                  option: opt,
                  selected: _selectedColors.contains(opt.id),
                  compact: true,
                  onTap: () => _toggleColor(opt.id),
                );
              }).toList(),
            ),
          ],
          if (!_colorsShowMore && _colorOptions.length > 5)
            _moreButton(() => setState(() => _colorsShowMore = true)),
        ],
      ),
    );
  }

  Widget _buildSizesSection() {
    return TarzFilterExpandableSection(
      title: 'Ölçü',
      expanded: _sizesExpanded,
      onToggle: () => setState(() => _sizesExpanded = !_sizesExpanded),
      child: _sizeGrid(_letterSizes),
    );
  }

  Widget _sizeGrid(List<String> sizes) {
    return LayoutBuilder(
      builder: (context, c) {
        const cols = 4;
        const gap = 8.0;
        final w = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: sizes.map((s) {
            return SizedBox(
              width: w,
              child: TarzFilterOutlinedTile(
                label: s,
                selected: _selectedSizes.contains(s),
                onTap: () => _toggleSize(s),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSortingSection() {
    return TarzFilterExpandableSection(
      title: 'Çeşidləmə',
      expanded: _sortingExpanded,
      onToggle: () => setState(() => _sortingExpanded = !_sortingExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sortCheckbox(
            label: 'Əvvəlcə ucuz',
            value: _sortCheapFirst,
            onChanged: (v) => setState(() {
              _sortCheapFirst = v ?? false;
              if (_sortCheapFirst) _sortExpensiveFirst = false;
            }),
          ),
          _sortCheckbox(
            label: 'Əvvəlcə bahalı',
            value: _sortExpensiveFirst,
            onChanged: (v) => setState(() {
              _sortExpensiveFirst = v ?? false;
              if (_sortExpensiveFirst) _sortCheapFirst = false;
            }),
          ),
        ],
      ),
    );
  }

  Widget _sortCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(visualDensity: VisualDensity.compact),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: TarzColors.ink,
        side: const BorderSide(color: _fieldBorder, width: 1.2),
        title: Text(
          label,
          style: const TextStyle(fontSize: 13, color: TarzColors.ink),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(List<PlpCategoryOption> visible) {
    return TarzFilterExpandableSection(
      title: 'Kateqoriyalar',
      expanded: _categoriesExpanded,
      onToggle: () => setState(() => _categoriesExpanded = !_categoriesExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...visible.map(_subcategoryCheckbox),
          if (!_categoriesShowMore && _categoryOptions.length > 5)
            _moreButton(() => setState(() => _categoriesShowMore = true)),
        ],
      ),
    );
  }

  Widget _subcategoryCheckbox(PlpCategoryOption option) {
    return Theme(
      data: Theme.of(context).copyWith(visualDensity: VisualDensity.compact),
      child: CheckboxListTile(
        value: _selectedSubcategoryIds.contains(option.id),
        onChanged: (_) => _toggleSubcategory(option.id),
        contentPadding: EdgeInsets.zero,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: TarzColors.ink,
        side: const BorderSide(color: _fieldBorder, width: 1.2),
        title: Text(
          option.name,
          style: const TextStyle(fontSize: 13, color: TarzColors.ink, height: 1.3),
        ),
      ),
    );
  }

  ProductFilterState _buildResult() {
    final min = double.tryParse(_minPrice.text);
    final max = double.tryParse(_maxPrice.text);
    return ProductFilterState(
      quickFilterIndex: _quickFilterIndex,
      minPrice: min,
      maxPrice: max,
      sortCheapFirst: _sortCheapFirst,
      sortExpensiveFirst: _sortExpensiveFirst,
      subcategoryIds: Set.from(_selectedSubcategoryIds),
    );
  }

  Widget _moreButton(VoidCallback onTap) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: TarzColors.ink,
          padding: const EdgeInsets.symmetric(vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Daha çox +',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TarzSpacing.md,
              12,
              TarzSpacing.md,
              12,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(_buildResult());
                },
                style: FilledButton.styleFrom(
                  backgroundColor: TarzColors.ink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Saxla',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: TarzColors.ink,
      ),
    );
  }
}
