import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

/// Singleton manager for WebView2 instance to achieve instant Shorts playback.
/// Eliminates the 2-4 second process startup latency by keeping Chromium pre-warmed.
class ShortsWebviewPool {
  static final ShortsWebviewPool instance = ShortsWebviewPool._();
  ShortsWebviewPool._();

  WebviewController? _controller;
  bool _isInitializing = false;
  bool _isReady = false;
  String? _currentLoadedVideoId;
  final ValueNotifier<bool> readyNotifier = ValueNotifier<bool>(false);

  bool get isReady => _isReady && _controller != null;
  WebviewController? get controller => _controller;

  Future<void> prewarm() async {
    if (_isReady || _isInitializing) return;
    _isInitializing = true;
    try {
      final ctrl = WebviewController();
      await ctrl.initialize();
      await ctrl.setBackgroundColor(Colors.black);
      _controller = ctrl;
      _isReady = true;
      readyNotifier.value = true;
      debugPrint('[ShortsWebviewPool] WebView2 pre-warmed successfully.');
    } catch (e) {
      debugPrint('[ShortsWebviewPool] Prewarm error: $e');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> loadVideo(String youtubeId) async {
    if (_currentLoadedVideoId == youtubeId) return;

    if (!_isReady) {
      await prewarm();
    }
    if (_controller == null) return;

    _currentLoadedVideoId = youtubeId;
    final playerUrl =
        '${ApiService.baseUrl}/player?v=$youtubeId&isShort=true';
    try {
      await _controller!.loadUrl(playerUrl);
    } catch (e) {
      debugPrint('[ShortsWebviewPool] Error loading video $youtubeId: $e');
    }
  }

  void pause() {
    if (_isReady && _controller != null && _currentLoadedVideoId != null) {
      try {
        _currentLoadedVideoId = null;
        _controller!.loadUrl('about:blank');
      } catch (_) {}
    }
  }
}

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
  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onWatched?.call();
        }
      });
      _activateAndPlay();
    }
  }

  @override
  void didUpdateWidget(covariant WindowsShortsPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && (!oldWidget.isActive || oldWidget.youtubeId != widget.youtubeId)) {
      widget.onWatched?.call();
      _activateAndPlay();
    } else if (!widget.isActive && oldWidget.isActive) {
      ShortsWebviewPool.instance.pause();
    }
  }

  void _activateAndPlay() {
    ShortsWebviewPool.instance.loadVideo(widget.youtubeId);
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl =
        'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg';

    if (!widget.isActive) {
      return Container(
        color: Colors.black,
        child: Image.network(
          thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.bolt, color: AppColors.primaryGold, size: 60),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background thumbnail prevents black flickers while new video buffers
          Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.bolt, color: AppColors.primaryGold, size: 60),
            ),
          ),

          // Active Shared WebView2
          ValueListenableBuilder<bool>(
            valueListenable: ShortsWebviewPool.instance.readyNotifier,
            builder: (context, isReady, _) {
              if (isReady && ShortsWebviewPool.instance.controller != null) {
                return Webview(ShortsWebviewPool.instance.controller!);
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGold,
                  strokeWidth: 3,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
