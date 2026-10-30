import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/tarz_colors.dart';

/// clientOrigin üçün istifadə olunan sabit dəyər.
const String kEpointClientOrigin = 'tessera-app://checkout';

/// Epoint ödəniş WebView ekranı.
///
/// Ödəniş URL-ini açır və müştəri ödənişi tamamladıqda (və ya ləğv etdikdə)
/// qaytarılma URL-ini tutaraq nəticəni bildirir.
///
/// Qaytarılan `true` — ödəniş qaytarılma URL-i tutuldu (verifikasiya lazımdır).
/// Qaytarılan `false` — istifadəçi ləğv etdi / WebView-ni bağladı.
/// Qaytarılan `null` — WebView açılmadı / xəta baş verdi.
class EpointPaymentScreen extends StatefulWidget {
  const EpointPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
  });

  /// HTTPS ödəniş URL-i (əvvəlcədən doğrulanıb).
  final String paymentUrl;

  /// Init-dən qaytarılan sifariş ID-si.
  final String orderId;

  @override
  State<EpointPaymentScreen> createState() => _EpointPaymentScreenState();
}

class _EpointPaymentScreenState extends State<EpointPaymentScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _hasReturned = false;
  String? _errorMessage;

  /// clientOrigin scheme/host/path — return URL uyğunluğu üçün.
  static final Uri _clientOriginUri = Uri.parse(kEpointClientOrigin);

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            // 3D Secure redirectləri bəzən cancel/error verir — tez bağlamayın.
            debugPrint(
              '[epoint] WebView error: ${error.errorType} ${error.description}',
            );
          },
          onNavigationRequest: (request) {
            return _handleNavigation(request);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Return URL-ni scheme/host/path ilə yoxlayır (substring contains() yox).
  NavigationDecision _handleNavigation(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.navigate;

    // clientOrigin scheme uyğunluğu: tessera-app://checkout...
    if (uri.scheme == _clientOriginUri.scheme &&
        uri.host == _clientOriginUri.host) {
      _onPaymentReturn();
      return NavigationDecision.prevent;
    }

    // HTTPS olmayan xarici URL-ləri blokla (javascript:, data: və s.)
    // Amma about:blank, https kimi normal URL-lərə icazə ver.
    if (uri.scheme != 'https' &&
        uri.scheme != 'http' &&
        uri.scheme != 'about') {
      debugPrint('[epoint] Blocked non-https navigation: ${uri.scheme}');
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _onPaymentReturn() {
    if (_hasReturned) return; // Dublikat callback-lərin qarşısını al.
    _hasReturned = true;
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _onCancel() {
    if (_hasReturned) return;
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onCancel();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: TarzColors.ink),
            onPressed: _onCancel,
          ),
          title: const Text(
            'Ödəniş',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: TarzColors.ink,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: TarzColors.inkMuted),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: TarzColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              WebViewWidget(controller: _controller),
            if (_loading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: TarzColors.ink,
                  backgroundColor: Colors.transparent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
