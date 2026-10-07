import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../models/auth_user.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../tarz/widgets/hide_when_keyboard_open.dart';
import '../tarz/widgets/tarz_bottom_navigation.dart';
import '../tarz/widgets/tarz_flash_message.dart';
import '../tarz/cart/tarz_cart_controller.dart';
import '../tarz/orders/tarz_orders_controller.dart';
import '../tarz/wishlist/tarz_wishlist_controller.dart';
import '../widgets/register/register_social_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _ink = Color(0xFF2D2D2D);
  static const double _hMargin = 20;

  final _scrollController = ScrollController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _emailFieldKey = GlobalKey();
  final _passwordFieldKey = GlobalKey();
  final _authService = AuthService();
  final _loading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onEmailFocus);
    _passwordFocus.addListener(_onPasswordFocus);
  }

  @override
  void dispose() {
    _emailFocus.removeListener(_onEmailFocus);
    _passwordFocus.removeListener(_onPasswordFocus);
    _scrollController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _loading.dispose();
    _authService.dispose();
    super.dispose();
  }

  void _onEmailFocus() {
    if (_emailFocus.hasFocus) _ensureVisible(_emailFieldKey);
  }

  void _onPasswordFocus() {
    if (_passwordFocus.hasFocus) _ensureVisible(_passwordFieldKey);
  }

  void _ensureVisible(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = key.currentContext;
      if (ctx == null || !mounted) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: 0.2,
      );
    });
  }

  void _toast(String message) => TarzFlashMessage.show(context, message);

  void _onNavChanged(int index) {
    if (index == 4) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
      arguments: index,
    );
  }

  Future<void> _submitLogin() async {
    if (_loading.value) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _toast('Email və şifrə daxil edin');
      return;
    }

    FocusScope.of(context).unfocus();
    _loading.value = true;
    
    try {
      final result =
          await _authService.login(email: email, password: password);
      
      if (!mounted) return;
      try {
        await TarzWishlistController.instance.reload();
        await TarzCartController.instance.reload();
        await TarzOrdersController.instance.reload();
      } catch (_) {}
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on ApiException catch (e) {
     
      if (mounted) _toast(e.message);
    } on AuthParseException catch (e) {
      
      if (mounted) _toast(e.message);
    } on ApiParseException catch (e) {
     
      if (mounted) _toast(e.message);
    } catch (e) {
      
      if (mounted) _toast('Gözlənilməz xəta: $e');
    } finally {
      if (mounted) _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      // false: navbar klaviatura ilə yuxarı qalxmır.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(_hMargin, 56, _hMargin, 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Daxil olun\nvə ya hesab yaradın',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 28),
                    KeyedSubtree(
                      key: _emailFieldKey,
                      child: _CredentialsBox(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        emailFocus: _emailFocus,
                        passwordFocus: _passwordFocus,
                        passwordFieldKey: _passwordFieldKey,
                        onSubmit: _submitLogin,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<bool>(
                      valueListenable: _loading,
                      builder: (context, isLoading, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: FilledButton(
                            onPressed: isLoading ? null : _submitLogin,
                            style: FilledButton.styleFrom(
                              backgroundColor: _ink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const StadiumBorder(),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Daxil ol',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const _LoginRegisterLink(),
                    const SizedBox(height: 20),
                    _LoginSocialButton(
                      label: 'Google ilə daxil ol',
                      leading: RegisterSocialIcons.google(),
                      onPressed: () => _toast('Google ilə daxil ol'),
                    ),
                    const SizedBox(height: 9),
                    _LoginSocialButton(
                      label: 'Apple ilə daxil ol',
                      leading: RegisterSocialIcons.apple(),
                      onPressed: () => _toast('Apple ilə daxil ol'),
                    ),
                    const SizedBox(height: 9),
                    _LoginSocialButton(
                      label: 'Facebook ilə daxil ol',
                      leading: RegisterSocialIcons.facebook(),
                      onPressed: () => _toast('Facebook ilə daxil ol'),
                    ),
                    const KeyboardBottomSpacer(extra: 24),
                  ],
                ),
              ),
            ),
            HideWhenKeyboardOpen(
              child: _LoginBottomChrome(
                onToast: _toast,
                onNavChanged: _onNavChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginBottomChrome extends StatelessWidget {
  const _LoginBottomChrome({
    required this.onToast,
    required this.onNavChanged,
  });

  final ValueChanged<String> onToast;
  final ValueChanged<int> onNavChanged;

  static const double _hMargin = 20;

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] LoginScreen._LoginBottomChrome');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_hMargin, 0, _hMargin, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BottomLink(
                text: 'Dəstək xidməti',
                onTap: () => onToast('Dəstək xidməti'),
              ),
              const SizedBox(height: 6),
              _BottomLink(
                text: 'Bildiriş tənzimləmələri',
                onTap: () => onToast('Bildiriş tənzimləmələri'),
              ),
            ],
          ),
        ),
        TarzBottomNavigation(
          currentIndex: 4,
          onChanged: onNavChanged,
        ),
      ],
    );
  }
}

class _CredentialsBox extends StatelessWidget {
  const _CredentialsBox({
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.passwordFieldKey,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final GlobalKey passwordFieldKey;
  final VoidCallback onSubmit;

  static const Color _ink = Color(0xFF2D2D2D);
  static const Color _border = Color(0xFF909090);
  static const Color _placeholder = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] LoginScreen._CredentialsBox');
    const fieldStyle = TextStyle(fontSize: 14, color: _ink);
    const hintStyle = TextStyle(fontSize: 13, color: _placeholder);

    return Container(
      height: 84,
      decoration: BoxDecoration(
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: emailController,
              focusNode: emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              style: fieldStyle,
              onSubmitted: (_) => passwordFocus.requestFocus(),
              decoration: const InputDecoration(
                hintText: 'Email və ya telefon',
                hintStyle: hintStyle,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _border),
          Expanded(
            child: KeyedSubtree(
              key: passwordFieldKey,
              child: TextField(
                controller: passwordController,
                focusNode: passwordFocus,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                style: fieldStyle,
                decoration: const InputDecoration(
                  hintText: 'Şifrə',
                  hintStyle: hintStyle,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomLink extends StatelessWidget {
  const _BottomLink({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          decoration: TextDecoration.underline,
          decorationColor: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _LoginRegisterLink extends StatefulWidget {
  const _LoginRegisterLink();

  @override
  State<_LoginRegisterLink> createState() => _LoginRegisterLinkState();
}

class _LoginRegisterLinkState extends State<_LoginRegisterLink> {
  late final TapGestureRecognizer _registerTap;

  @override
  void initState() {
    super.initState();
    _registerTap = TapGestureRecognizer()
      ..onTap = () => Navigator.pushNamed(context, AppRoutes.register);
  }

  @override
  void dispose() {
    _registerTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] LoginScreen._LoginRegisterLink');
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF5C5C5C),
          ),
          children: [
            const TextSpan(text: 'Hesabınız yoxdur? '),
            TextSpan(
              text: 'Qeydiyyatdan keçin',
              style: const TextStyle(
                color: Color(0xFF2D2D2D),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
              recognizer: _registerTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginSocialButton extends StatelessWidget {
  const _LoginSocialButton({
    required this.label,
    required this.leading,
    this.onPressed,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onPressed;

  static const Color _border = Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _border,
          side: BorderSide(color: _border.withValues(alpha: 0.85), width: 1),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 28, child: Center(child: leading)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _border,
                ),
              ),
            ),
            const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}
