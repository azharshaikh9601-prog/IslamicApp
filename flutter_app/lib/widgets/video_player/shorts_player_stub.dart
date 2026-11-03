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
      final playerUrl =
          '${ApiService.baseUrl}/player?v=${widget.youtubeId}&isShort=true';
      await _controller.loadUrl(playerUrl);
    } catch (e) {
      debugPrint('[ShortsPlayer] Error loading short: $e');
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
