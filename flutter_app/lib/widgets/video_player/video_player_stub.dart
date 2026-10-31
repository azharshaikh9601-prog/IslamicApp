import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../core/theme/app_colors.dart';

Widget buildInAppVideoPlayer({
  Key? key,
  required String youtubeId,
  required String title,
  VoidCallback? onWatched,
}) {
  return WindowsInAppVideoPlayer(
    key: key,
    youtubeId: youtubeId,
    title: title,
    onWatched: onWatched,
  );
}

class WindowsInAppVideoPlayer extends StatefulWidget {
  final String youtubeId;
  final String title;
  final VoidCallback? onWatched;

  const WindowsInAppVideoPlayer({
    super.key,
    required this.youtubeId,
    required this.title,
    this.onWatched,
  });

  @override
  State<WindowsInAppVideoPlayer> createState() => _WindowsInAppVideoPlayerState();
}

class _WindowsInAppVideoPlayerState extends State<WindowsInAppVideoPlayer> {
  final _controller = WebviewController();
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    widget.onWatched?.call();
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.black);

      final embedUrl =
          'https://www.youtube.com/embed/${widget.youtubeId}?autoplay=1&controls=1&rel=0&playsinline=1&modestbranding=1';

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
    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Preview thumbnail while loading
            if (!_isInitialized)
              Image.network(
                'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.darkCard,
                  child: const Icon(
                    Icons.ondemand_video,
                    color: AppColors.primaryGold,
                    size: 48,
                  ),
                ),
              ),

            if (!_isInitialized && !_hasError)
              const CircularProgressIndicator(
                color: AppColors.primaryGold,
                strokeWidth: 3,
              ),

            // Actual Webview Player
            if (_isInitialized)
              Webview(_controller),
          ],
        ),
      ),
    );
  }
}
