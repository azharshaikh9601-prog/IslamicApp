import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../core/theme/app_colors.dart';

Widget buildShortsPlayer({
  required String youtubeId,
  required String title,
  VoidCallback? onWatched,
}) {
  return WindowsShortsPlayer(
    youtubeId: youtubeId,
    title: title,
    onWatched: onWatched,
  );
}

class WindowsShortsPlayer extends StatefulWidget {
  final String youtubeId;
  final String title;
  final VoidCallback? onWatched;

  const WindowsShortsPlayer({
    super.key,
    required this.youtubeId,
    required this.title,
    this.onWatched,
  });

  @override
  State<WindowsShortsPlayer> createState() => _WindowsShortsPlayerState();
}

class _WindowsShortsPlayerState extends State<WindowsShortsPlayer> {
  final _controller = WebviewController();
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onWatched?.call();
      }
    });
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.black);

      // Official YouTube Embed URL with auto-play & loop
      final embedUrl =
          'https://www.youtube.com/embed/${widget.youtubeId}?autoplay=1&controls=1&rel=0&playsinline=1&modestbranding=1&loop=1';

      await _controller.loadUrl(embedUrl);

      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.play_circle_fill,
                  color: AppColors.primaryGold,
                  size: 64,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Playback unavailable',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // High-res preview while webview initializes
          if (!_isInitialized)
            Image.network(
              'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.bolt, color: AppColors.primaryGold, size: 60),
              ),
            ),

          if (!_isInitialized)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
                strokeWidth: 3,
              ),
            ),

          // Live Native WebView2 YouTube Player
          if (_isInitialized)
            Webview(_controller),
        ],
      ),
    );
  }
}
