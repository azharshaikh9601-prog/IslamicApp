import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

Widget buildShortsPlayer({
  required String youtubeId,
  required String title,
  VoidCallback? onWatched,
}) {
  return StubShortsPlayer(
    youtubeId: youtubeId,
    title: title,
    onWatched: onWatched,
  );
}

class StubShortsPlayer extends StatefulWidget {
  final String youtubeId;
  final String title;
  final VoidCallback? onWatched;

  const StubShortsPlayer({
    super.key,
    required this.youtubeId,
    required this.title,
    this.onWatched,
  });

  @override
  State<StubShortsPlayer> createState() => _StubShortsPlayerState();
}

class _StubShortsPlayerState extends State<StubShortsPlayer> {
  bool _isPlaying = true;
  bool _isMuted = false;
  double _progress = 0.0;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    widget.onWatched?.call();
    _startPlaybackTimer();
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!_isPlaying) return;
      if (!mounted) return;
      setState(() {
        _progress += 0.008;
        if (_progress >= 1.0) {
          _progress = 0.0; // Loop like Instagram reels / YouTube shorts
        }
      });
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int currentSeconds = (_progress * 55).round();
    final String timeStr = '0:${currentSeconds.toString().padLeft(2, '0')} / 0:55';

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. High-res video thumbnail
          Image.network(
            'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surfaceEmerald,
              child: const Icon(Icons.bolt, color: AppColors.primaryGold, size: 60),
            ),
          ),

          // 2. Subtle in-app dimming
          Container(
            color: Colors.black.withOpacity(0.25),
          ),

          // 3. Play / Pause feedback overlay when paused
          if (!_isPlaying)
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.brightGold,
                  size: 46,
                ),
              ),
            ),

          // 4. In-App Verified Video Indicator Top Bar
          Positioned(
            top: 20,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _isPlaying ? const Color(0xFF10B981) : Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isPlaying ? 'Playing In-App' : 'Paused',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Sound Mute / Unmute Toggle Button (Top Right)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: AppColors.brightGold,
                  size: 18,
                ),
              ),
            ),
          ),

          // 6. Smooth Red YouTube-style Bottom Progress Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
                  minHeight: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
