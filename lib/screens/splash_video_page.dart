import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../routes/app_routes.dart';

/// Full-screen video splash — plays once, then navigates to home.
class SplashVideoPage extends StatefulWidget {
  const SplashVideoPage({super.key});

  @override
  State<SplashVideoPage> createState() => _SplashVideoPageState();
}

class _SplashVideoPageState extends State<SplashVideoPage> {
  static const _videoAsset = 'assets/videos/splash.mp4';

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
      controller.addListener(_onPlaybackUpdate);
      setState(() {});

      await controller.play();
    } catch (_) {
      await controller.dispose();
      _controller = null;
      _goToHome();
    }
  }

  void _onPlaybackUpdate() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration <= Duration.zero) return;

    if (position >= duration - const Duration(milliseconds: 100)) {
      _goToHome();
    }
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
      controller.removeListener(_onPlaybackUpdate);
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
