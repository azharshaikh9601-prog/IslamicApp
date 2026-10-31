import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

Widget buildShortsPlayer({
  Key? key,
  required String youtubeId,
  required String title,
  VoidCallback? onWatched,
}) {
  return WindowsShortsPlayer(
    key: key,
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

  @override
  void didUpdateWidget(covariant WindowsShortsPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.youtubeId != widget.youtubeId && _isInitialized) {
      _loadCurrentShort();
    }
  }

  Future<void> _loadCurrentShort() async {
    final backendPlayerUrl =
        '${ApiService.baseUrl}/player?v=${widget.youtubeId}&isShort=true';
    try {
      await _controller.loadUrl(backendPlayerUrl);
    } catch (_) {
      await _controller.loadStringContent(
          _buildEmbedHtml(widget.youtubeId, isShort: true));
    }
  }

  Future<void> _initWebView() async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.black);

      await _loadCurrentShort();

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
    title="Hafiz Hasnain Short Player"
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

          if (_isInitialized)
            Webview(_controller),
        ],
      ),
    );
  }
}
