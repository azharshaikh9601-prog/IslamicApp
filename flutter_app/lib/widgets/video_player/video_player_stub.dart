import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/in_app_player_server.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onWatched?.call();
      }
    });
    _initWebView();
  }

  @override
  void didUpdateWidget(covariant WindowsInAppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.youtubeId != widget.youtubeId && _isInitialized) {
      _loadCurrentVideo();
    }
  }

  Future<void> _loadCurrentVideo() async {
    try {
      await InAppPlayerServer().ensureStarted();
      final playerUrl = InAppPlayerServer().getUrlForVideo(widget.youtubeId, isShort: false);
      await _controller.loadUrl(playerUrl);
    } catch (_) {
      try {
        await _controller.loadStringContent(
            _buildEmbedHtml(widget.youtubeId, isShort: false));
      } catch (_) {}
    }
  }

  Future<void> _initWebView() async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.black);

      await _loadCurrentVideo();

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

  static String _buildEmbedHtml(String videoId, {required bool isShort}) {
    final loopParam = isShort ? '&loop=1&playlist=$videoId' : '';
    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <meta name="referrer" content="strict-origin-when-cross-origin">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      height: 100%;
      background-color: #000000;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    iframe {
      width: 100%;
      height: 100%;
      border: 0;
    }
  </style>
</head>
<body>
  <iframe
    src="https://www.youtube-nocookie.com/embed/$videoId?autoplay=1&controls=1&rel=0&playsinline=1&modestbranding=1$loopParam"
    title="Hafiz Hasnain Video Player"
    referrerpolicy="strict-origin-when-cross-origin"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen>
  </iframe>
</body>
</html>''';
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
            if (!_isInitialized)
              Image.network(
                'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.play_circle_fill,
                      color: AppColors.primaryGold, size: 64),
                ),
              ),

            if (!_isInitialized && !_hasError)
              const CircularProgressIndicator(
                color: AppColors.primaryGold,
                strokeWidth: 3,
              ),

            if (_hasError)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.primaryGold, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Playback error for ${widget.title}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

            if (_isInitialized)
              Webview(_controller),
          ],
        ),
      ),
    );
  }
}
