import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../models/auth_user.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../tarz/cart/tarz_cart_controller.dart';
import '../tarz/widgets/keyboard_aware_scroll_view.dart';
import '../tarz/widgets/tarz_flash_message.dart';
import '../tarz/wishlist/tarz_wishlist_controller.dart';
import '../widgets/register/register_social_button.dart';
import '../widgets/register/register_social_icons.dart';
import '../widgets/register/register_underline_field.dart';

/// “Register Menu” — Figma üzrə qeydiyyat / sosial giriş ekranı.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _authService = AuthService();

  bool _newsletter = false;
  bool _isLoading = false;

  static const Color _pageGrey = Color(0xFFF2F2F2);
  static const Color _barGrey = Color(0xFFE6E6E6);
  static const Color _charcoal = Color(0xFF2D2D2D);

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toast(String m) => TarzFlashMessage.show(context, m);

  Future<void> _submitRegister() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await _authService.register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        phone: _phone.text,
      );
      if (!mounted) return;
      try {
        await TarzWishlistController.instance.reload();
        await TarzCartController.instance.reload();
      } catch (_) {
        // Qeydiyyat uğurludur; səbət/seçilmişlər sinxronu sonra təkrarlanır.
      }
      if (!mounted) return;
      _toast('Qeydiyyat uğurla tamamlandı');
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 403) {
        _toast(
          e.message.contains('email') || e.message.contains('Email')
              ? e.message
              : 'Bu email ilə artıq hesab ola bilər. Daxil ol sınayın.',
        );
        return;
      }
      _toast(e.message);
    } on AuthParseException catch (e) {
      if (mounted) _toast(e.message);
    } on ApiParseException catch (e) {
      if (mounted) _toast(e.message);
    } catch (e) {
      if (mounted) _toast('Gözlənilməz xəta baş verdi');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageGrey,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width >= 600 ? 520 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: _barGrey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacementNamed(context, AppRoutes.login);
                            }
                          },
                          tooltip: 'Geri',
                        ),
                        const Expanded(
                          child: Text(
                            'Register Menu',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5C5C5C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: KeyboardAwareScrollView(
                    keyboardExtra: 28,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: ColoredBox(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                const Text(
                                  'Daxil olun və ya hesab yaradın',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: Color(0xFF121212),
                                  ),
                                ),
                                const SizedBox(height: 36),
                                RegisterUnderlineField(
                                  label: 'Email',
                                  hint: 'Email adresinizi bura qeyd edin',
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 28),
                                RegisterUnderlineField(
                                  label: 'Şifrə',
                                  hint: 'Şifrənizi daxil edin',
                                  controller: _password,
                                  obscureText: true,
                                ),
                                const SizedBox(height: 28),
                                RegisterUnderlineField(
                                  label: 'Ad',
                                  hint: 'Adınızı bura qeyd edin',
                                  controller: _name,
                                ),
                                const SizedBox(height: 28),
                                RegisterUnderlineField(
                                  label: 'Telefon',
                                  hint: '+994 ** *** ** **',
                                  controller: _phone,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 28),
                                _LegalConsentText(
                                  onTerms: () => _toast('İstifadə şərtləri'),
                                  onPrivacy: () => _toast('Məxfilik siyasəti'),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _newsletter,
                                        onChanged: (v) => setState(() => _newsletter = v ?? false),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Yeni imtiyazlar və sevimli brendlərin kolleksiyalarını '
                                        'qaçırmamaq üçün bülletenə abunə olun.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: Color(0xFF3D3D3D),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _charcoal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: _isLoading ? null : _submitRegister,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Qeydiyyatdan keç',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                const Center(
                                  child: Text(
                                    'yaxud',
                                    style: TextStyle(
                                      color: Color(0xFF6B6B6B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                RegisterSocialButton(
                                  label: 'Google ilə daxil ol',
                                  leading: RegisterSocialIcons.google(),
                                  onPressed: () => _toast('Google'),
                                ),
                                const SizedBox(height: 14),
                                RegisterSocialButton(
                                  label: 'Apple ilə daxil ol',
                                  leading: RegisterSocialIcons.apple(),
                                  onPressed: () => _toast('Apple'),
                                ),
                                const SizedBox(height: 14),
                                RegisterSocialButton(
                                  label: 'Facebook ilə daxil ol',
                                  leading: RegisterSocialIcons.facebook(),
                                  onPressed: () => _toast('Facebook'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalConsentText extends StatefulWidget {
  const _LegalConsentText({
    required this.onTerms,
    required this.onPrivacy,
  });

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  State<_LegalConsentText> createState() => _LegalConsentTextState();
}

class _LegalConsentTextState extends State<_LegalConsentText> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = widget.onTerms;
    _privacyTap = TapGestureRecognizer()..onTap = widget.onPrivacy;
  }

  @override
  void didUpdateWidget(covariant _LegalConsentText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTerms != widget.onTerms) {
      _termsTap.onTap = widget.onTerms;
    }
    if (oldWidget.onPrivacy != widget.onPrivacy) {
      _privacyTap.onTap = widget.onPrivacy;
    }
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = const TextStyle(
      fontSize: 13,
      height: 1.5,
      color: Color(0xFF5C5C5C),
    );
    final link = TextStyle(
      fontSize: 13,
      height: 1.5,
      color: const Color(0xFF121212),
      decoration: TextDecoration.underline,
      decorationColor: Colors.black.withValues(alpha: 0.6),
    );

    return RichText(
      text: TextSpan(
        style: base,
        children: [
          const TextSpan(
            text: 'Qeydiyyatdan keçməklə siz loyallıq proqramına daxil olur, ',
          ),
          TextSpan(
            text: 'istifadə şərtləri',
            style: link,
            recognizer: _termsTap,
          ),
          const TextSpan(text: ' və '),
          TextSpan(
            text: 'Məxfilik siyasəti',
            style: link,
            recognizer: _privacyTap,
          ),
          const TextSpan(text: ' ilə razılaşırsınız.'),
        ],
      ),
    );
  }
}
