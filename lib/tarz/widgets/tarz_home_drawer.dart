import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../data/category_repository.dart';
import '../data/tarz_mock_catalog.dart';
import '../models/plp_category_option.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';

/// Yan menyu — API kateqoriyaları, cins tabları, kabinet düymələri.
class TarzHomeDrawer extends StatefulWidget {
  const TarzHomeDrawer({
    super.key,
    required this.selectedGenderIndex,
    required this.onGenderSelected,
    this.onCategoryTap,
  });

  final int selectedGenderIndex;
  final ValueChanged<int> onGenderSelected;
  final ValueChanged<PlpCategoryOption>? onCategoryTap;

  @override
  State<TarzHomeDrawer> createState() => _TarzHomeDrawerState();
}

class _TarzHomeDrawerState extends State<TarzHomeDrawer> {
  final _categoryRepo = CategoryRepository.instance;
  List<PlpCategoryOption> _categories = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void didUpdateWidget(TarzHomeDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedGenderIndex != widget.selectedGenderIndex) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    try {
      final cats =
          await _categoryRepo.fetchCatalogueCategories(widget.selectedGenderIndex);
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _close(BuildContext context) => Navigator.of(context).pop();

  void _goLogin(BuildContext context) {
    _close(context);
    Navigator.of(context).pushNamed(AppRoutes.login);
  }

  void _goRegister(BuildContext context) {
    _close(context);
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    final labels = TarzMockCatalog.categories;
    final screenW = MediaQuery.sizeOf(context).width;

    return Drawer(
      width: screenW,
      backgroundColor: TarzColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TarzSpacing.md,
                TarzSpacing.sm,
                TarzSpacing.xs,
                TarzSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(labels.length, (i) {
                        final selected = i == widget.selectedGenderIndex;
                        return Expanded(
                          child: InkWell(
                            onTap: () => widget.onGenderSelected(i),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: TarzSpacing.xs,
                                bottom: TarzSpacing.sm,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    labels[i],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: selected
                                          ? TarzColors.ink
                                          : TarzColors.inkMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    height: selected ? 2.5 : 0,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? TarzColors.ink
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _close(context),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Bağla',
                    style:
                        IconButton.styleFrom(foregroundColor: TarzColors.ink),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ListView.separated(
                      padding:
                          const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Color(0xFFF0F0F0),
                      ),
                      itemBuilder: (context, index) {
                        final option = _categories[index];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4),
                          title: Text(
                            option.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: TarzColors.ink,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: TarzColors.inkMuted.withValues(alpha: 0.45),
                          ),
                          onTap: () {
                            widget.onCategoryTap?.call(option);
                            _close(context);
                          },
                        );
                      },
                    ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E6)),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TarzSpacing.md,
                TarzSpacing.lg,
                TarzSpacing.md,
                TarzSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Şəxsi kabinetə',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: TarzColors.ink,
                    ),
                  ),
                  const SizedBox(height: TarzSpacing.lg),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: () => _goLogin(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: TarzColors.ink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Daxil ol'),
                    ),
                  ),
                  const SizedBox(height: TarzSpacing.sm),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _goRegister(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TarzColors.ink,
                        side: const BorderSide(color: TarzColors.ink, width: 1.2),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Qeydiyyatdan keç'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
