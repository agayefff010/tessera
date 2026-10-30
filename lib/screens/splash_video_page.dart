import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../bootstrap/app_bootstrap.dart';
import '../routes/app_routes.dart';

/// Full-screen video splash — plays once while background init runs in
/// parallel, then navigates to home when both are done.
class SplashVideoPage extends StatefulWidget {
  const SplashVideoPage({super.key});

  @override
  State<SplashVideoPage> createState() => _SplashVideoPageState();
}

class _SplashVideoPageState extends State<SplashVideoPage> {
  static const _videoAsset = 'assets/videos/Tessplash.mp4';

  VideoPlayerController? _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initVideo();
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset(_videoAsset);
    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      controller.setLooping(false);
      setState(() {});
      await controller.play();

      // Wait for BOTH the video to finish AND background init to complete.
      await Future.wait<void>([
        _videoCompleted(controller),
        AppBootstrap.instance.ready,
      ]);

      _goToHome();
    } catch (_) {
      await controller.dispose();
      _controller = null;
      // Even on error, wait for init before navigating.
      await AppBootstrap.instance.ready;
      _goToHome();
    }
  }

  /// Completes when the video reaches its end.
  Future<void> _videoCompleted(VideoPlayerController controller) {
    final completer = _VideoCompleter(controller);
    return completer.future;
  }

  void _goToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      controller.dispose();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final initialized =
        controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AbsorbPointer(
        child: initialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
            : const ColoredBox(color: Colors.black),
      ),
    );
  }
}

/// Helper that resolves when [controller] reaches the end of playback.
class _VideoCompleter {
  _VideoCompleter(this._controller) {
    _controller.addListener(_onUpdate);
  }

  final VideoPlayerController _controller;
  final _completer = Completer<void>();

  Future<void> get future => _completer.future;

  void _onUpdate() {
    if (_completer.isCompleted) return;
    if (!_controller.value.isInitialized) return;

    final position = _controller.value.position;
    final duration = _controller.value.duration;
    if (duration <= Duration.zero) return;

    if (position >= duration - const Duration(milliseconds: 100)) {
      _controller.removeListener(_onUpdate);
      _completer.complete();
    }
  }
}
