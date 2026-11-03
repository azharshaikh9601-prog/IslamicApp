import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../core/theme/app_colors.dart';
import '../../services/in_app_player_server.dart';

Widget buildShortsPlayer({
  Key? key,
  required String youtubeId,
  required String title,
  VoidCallback? onWatched,
  bool isActive = true,
}) {
  return WindowsShortsPlayer(
    key: key,
    youtubeId: youtubeId,
    title: title,
    onWatched: onWatched,
    isActive: isActive,
  );
}

class WindowsShortsPlayer extends StatefulWidget {
  final String youtubeId;
  final String title;
  final VoidCallback? onWatched;
  final bool isActive;

  const WindowsShortsPlayer({
    super.key,
    required this.youtubeId,
    required this.title,
    this.onWatched,
    this.isActive = true,
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
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onWatched?.call();
        }
      });
    }
    _initWebView();
  }

  @override
  void didUpdateWidget(covariant WindowsShortsPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        if (_isInitialized) {
          _loadCurrentShort();
          widget.onWatched?.call();
        }
      } else {
        if (_isInitialized) {
          try {
            _controller.loadUrl('about:blank');
          } catch (_) {}
        }
      }
    } else if (widget.isActive && oldWidget.youtubeId != widget.youtubeId) {
      if (_isInitialized) {
        _loadCurrentShort();
      }
    }
  }

  Future<void> _loadCurrentShort() async {
    try {
      await InAppPlayerServer().ensureStarted();
      final playerUrl = InAppPlayerServer().getUrlForVideo(widget.youtubeId, isShort: true);
      await _controller.loadUrl(playerUrl);
    } catch (_) {
      try {
        await _controller.loadStringContent(
            _buildEmbedHtml(widget.youtubeId, isShort: true));
      } catch (_) {}
    }
  }

  Future<void> _initWebView() async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.black);

      if (widget.isActive) {
        await _loadCurrentShort();
      }

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
    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <meta name="referrer" content="strict-origin-when-cross-origin">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%; height: 100%;
      background-color: #000;
      overflow: hidden;
      display: flex; align-items: center; justify-content: center;
    }
    #player, iframe { width: 100%; height: 100%; border: 0; }
  </style>
</head>
<body>
  <div id="player"></div>
  <script>
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    var player;
    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        height: '100%',
        width: '100%',
        videoId: '$videoId',
        playerVars: {
          'autoplay': 1,
          'playsinline': 1,
          'controls': ${isShort ? 0 : 1},
          'rel': 0,
          'modestbranding': 1,
          ${isShort ? "'loop': 1, 'playlist': '$videoId'," : ""}
          'origin': 'https://www.youtube.com'
        },
        events: {
          'onReady': function(event) {
            ${isShort ? "event.target.playVideo();" : ""}
          }
        }
      });
    }
  </script>
</body>
</html>''';
  }

  @override
  void dispose() {
    try {
      _controller.loadUrl('about:blank');
    } catch (_) {}
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

    if (!widget.isActive) {
      return Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.bolt, color: AppColors.primaryGold, size: 60),
              ),
            ),
          ],
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
