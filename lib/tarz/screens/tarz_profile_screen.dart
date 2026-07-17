import 'package:flutter/material.dart';

import '../../models/auth_user.dart';
import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/auth_service.dart';
import '../orders/tarz_orders_controller.dart';
import '../widgets/profile/tarz_profile_orders_section.dart';
import '../widgets/tarz_flash_message.dart';
import '../theme/tarz_breakpoints.dart';
import '../theme/tarz_colors.dart';

/// Profil səhifəsi — API profil məlumatları.
class TarzProfileScreen extends StatefulWidget {
  const TarzProfileScreen({
    super.key,
    this.onWishlistTap,
    this.onOutfitsTap,
    this.onNotificationsTap,
  });

  final VoidCallback? onWishlistTap;
  final VoidCallback? onOutfitsTap;
  final VoidCallback? onNotificationsTap;

  @override
  State<TarzProfileScreen> createState() => _TarzProfileScreenState();
}

class _TarzProfileScreenState extends State<TarzProfileScreen> {
  final _authService = AuthService();
  final _orders = TarzOrdersController.instance;

  AuthUser? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _orders.addListener(_onOrdersChanged);
  }

  @override
  void dispose() {
    _orders.removeListener(_onOrdersChanged);
    _authService.dispose();
    super.dispose();
  }

  void _onOrdersChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final loggedIn = await _authService.isLoggedIn();
      if (!loggedIn) {
        if (!mounted) return;
        setState(() {
          _user = null;
          _loading = false;
        });
        return;
      }

      final cached = await _authService.getCachedUser();
      if (mounted && cached != null) {
        setState(() => _user = cached);
      }

      final fresh = await _authService.fetchCurrentUser();
      if (!mounted) return;
      setState(() {
        _user = fresh ?? cached;
        _loading = false;
        _error = null;
      });

      try {
        if (forceRefresh) {
          await _orders.reload();
        } else {
          await _orders.ensureLoaded();
        }
      } catch (_) {
        // Sifarişlər yüklənməsə profil işləməyə davam edir.
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _authService.logout();
        if (!mounted) return;
        setState(() {
          _user = null;
          _error = null;
          _loading = false;
        });
        _toast('Sessiya bitib. Yenidən daxil olun.');
        return;
      }
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Profil yüklənmədi';
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    _orders.clearSession();
    if (!mounted) return;
    setState(() => _user = null);
    _toast('Hesabdan çıxış edildi');
  }

  Future<void> _openEditProfile() async {
    final user = _user;
    if (user == null) return;

    final result = await showModalBottomSheet<({String name, String phone})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _EditProfileSheet(
        initialName: user.name,
        initialPhone: user.phone ?? '',
      ),
    );

    if (result == null || !mounted) return;

    try {
      final updated = await _authService.updateProfile(
        name: result.name,
        phone: result.phone,
      );
      if (!mounted) return;
      setState(() => _user = updated);
      _toast('Profil yeniləndi');
    } on ApiException catch (e) {
      if (mounted) _toast(e.message);
    } catch (_) {
      if (mounted) _toast('Profil yenilənmədi');
    }
  }

  void _toast(String message) => TarzFlashMessage.show(context, message);

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
              onRefresh: () => _loadProfile(forceRefresh: true),
              child: SingleChildScrollView(
                key: const PageStorageKey<String>('tarz_profile_scroll'),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: TarzColors.ink,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_loading && _user == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_user != null)
                      _LoggedInHeader(
                        user: _user!,
                        onEdit: _openEditProfile,
                        onLogout: _logout,
                      )
                    else
                      _GuestHeader(
                        onLogin: () async {
                          await Navigator.of(context)
                              .pushNamed(AppRoutes.login);
                          if (mounted) _loadProfile();
                        },
                        onRegister: () async {
                          await Navigator.of(context)
                              .pushNamed(AppRoutes.register);
                          if (mounted) _loadProfile();
                        },
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    _MenuSection(
                      items: [
                        _ProfileMenuItem(
                          icon: Icons.favorite_border_rounded,
                          title: 'Seçilmişlər',
                          onTap: widget.onWishlistTap ??
                              () => _toast('Seçilmişlər'),
                        ),
                        _ProfileMenuItem(
                          icon: Icons.checkroom_outlined,
                          title: 'Kombinlərim',
                          onTap: widget.onOutfitsTap ??
                              () => _toast('Kombinlərim'),
                        ),
                        _ProfileMenuItem(
                          icon: Icons.notifications_none_rounded,
                          title: 'Bildirişlər',
                          onTap: widget.onNotificationsTap ??
                              () => Navigator.of(context)
                                  .pushNamed(AppRoutes.notifications),
                        ),
                        _ProfileMenuItem(
                          icon: Icons.language_rounded,
                          title: 'Dil — Azərbaycan',
                          onTap: () => _toast('Dil seçimi'),
                        ),
                        _ProfileMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Kömək',
                          onTap: () => _toast('Kömək'),
                        ),
                      ],
                    ),
                    if (_user != null) ...[
                      const SizedBox(height: 24),
                      TarzProfileOrdersSection(
                        orders: _orders.orders.take(5).toList(),
                        loading: _orders.isLoading,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoggedInHeader extends StatelessWidget {
  const _LoggedInHeader({
    required this.user,
    required this.onEdit,
    required this.onLogout,
  });

  final AuthUser user;
  final VoidCallback onEdit;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: TarzColors.ink,
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
            if (user.phone != null && user.phone!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                user.phone!,
                style: TextStyle(
                  fontSize: 13,
                  color: TarzColors.inkMuted.withValues(alpha: 0.85),
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: onEdit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: TarzColors.ink,
                  side: const BorderSide(color: TarzColors.ink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Profili redaktə et',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: onLogout,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                ),
                child: const Text(
                  'Çıxış',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader({
    required this.onLogin,
    required this.onRegister,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: TarzColors.ink.withValues(alpha: 0.08),
              child: Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: TarzColors.ink.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Şəxsi kabinetə daxil olun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sifarişlərinizi izləyin və seçilmişlərinizi saxlayın',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: onLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: TarzColors.ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Daxil ol',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: onRegister,
                style: OutlinedButton.styleFrom(
                  foregroundColor: TarzColors.ink,
                  side: const BorderSide(color: TarzColors.ink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Qeydiyyatdan keç',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.items});

  final List<_ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEEEEEE)),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: TarzColors.ink.withValues(alpha: 0.7)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: TarzColors.ink,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: TarzColors.inkMuted.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.initialName,
    required this.initialPhone,
  });

  final String initialName;
  final String initialPhone;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop((
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Profili redaktə et',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                labelText: 'Telefon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: TarzColors.ink,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
              ),
              child: const Text('Saxla'),
            ),
          ],
        ),
      ),
    );
  }
}
