import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../tarz/widgets/tarz_bottom_navigation.dart';
import '../widgets/register/register_social_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _ink = Color(0xFF2D2D2D);
  static const Color _border = Color(0xFF909090);
  static const Color _placeholder = Color(0xFF9E9E9E);
  static const double _hMargin = 20;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onNavChanged(int index) {
    if (index == 4) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
      arguments: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: _hMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.14),
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
                    _credentialsField(),
                    const SizedBox(height: 10),
                    _loginButton(),
                    const SizedBox(height: 16),
                    _registerText(context),
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(_hMargin, 0, _hMargin, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bottomLink('Dəstək xidməti', () => _toast('Dəstək xidməti')),
                  const SizedBox(height: 6),
                  _bottomLink(
                    'Bildiriş tənzimləmələri',
                    () => _toast('Bildiriş tənzimləmələri'),
                  ),
                ],
              ),
            ),
            TarzBottomNavigation(
              currentIndex: 4,
              onChanged: _onNavChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _credentialsField() {
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: fieldStyle,
              decoration: const InputDecoration(
                hintText: 'Email və ya telefon',
                hintStyle: hintStyle,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _border),
          Expanded(
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              style: fieldStyle,
              decoration: const InputDecoration(
                hintText: 'Şifrə',
                hintStyle: hintStyle,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: FilledButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        },
        style: FilledButton.styleFrom(
          backgroundColor: _ink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: const Text(
          'Daxil ol',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _registerText(BuildContext context) {
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
                color: _ink,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.pushNamed(context, AppRoutes.register),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomLink(String text, VoidCallback onTap) {
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
