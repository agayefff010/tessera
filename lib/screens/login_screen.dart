import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _TopBanner(),
            const _AppHeader(),
            const _CategoryTabsRow(),
            Expanded(
              child: ColoredBox(
                color: const Color(0xFFF7F7F7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    _LoginBlock(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBanner extends StatelessWidget {
  const _TopBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1F1F1F),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Center(
        child: Text(
          '150 AZN ÜZƏRİ ALIŞ-VERİŞLƏRDƏ ƏLAVƏ ÖDƏNİŞSİZ, TAM\n'
          'PULSUZ ÇATDIRILMA İMKANI',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.menu, size: 24),
              SizedBox(width: 14),
              Icon(Icons.search, size: 22),
            ],
          ),
          const Text(
            'TESSERA',
            style: TextStyle(
              fontSize: 36,
              letterSpacing: 3,
              fontWeight: FontWeight.w300,
            ),
          ),
          Row(
            children: const [
              Icon(Icons.favorite_border, size: 24),
              SizedBox(width: 14),
              Icon(Icons.shopping_bag_outlined, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTabsRow extends StatelessWidget {
  const _CategoryTabsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          _tab('Qadın', true),
          _tab('Kişi', false),
          _tab('Uşaq', false),
        ],
      ),
    );
  }

  static Widget _tab(String text, bool active) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: active ? Colors.black : Colors.black54,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

Widget _LoginBlock(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Daxil ol',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Hesabınıza daxil olaraq alış-verişə davam edin',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 40),
        _authTextField(hint: 'E-poçt ünvanı'),
        const SizedBox(height: 18),
        _authTextField(hint: 'Şifrə', obscure: true),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Şifrəni unutmusunuz?',
              style: TextStyle(
                color: Colors.black54,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () {},
            child: const Text(
              'Hesaba daxil ol',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hesabınız yoxdur? ',
              style: TextStyle(color: Colors.black54),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.register),
              child: const Text(
                'Qeydiyyatdan keçin',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _authTextField({required String hint, bool obscure = false}) {
  return SizedBox(
    height: 60,
    child: TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
  );
}
