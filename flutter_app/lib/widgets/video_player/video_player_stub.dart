import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

Widget buildInAppVideoPlayer({
  Key? key,
  required String youtubeId,
  required String title,
  VoidCallback? onWatched,
}) {
  return StubInAppVideoPlayer(
    key: key,
    youtubeId: youtubeId,
    title: title,
    onWatched: onWatched,
  );
}

class StubInAppVideoPlayer extends StatefulWidget {
  final String youtubeId;
  final String title;
  final VoidCallback? onWatched;

  const StubInAppVideoPlayer({
    super.key,
    required this.youtubeId,
    required this.title,
    this.onWatched,
  });

  @override
  State<StubInAppVideoPlayer> createState() => _StubInAppVideoPlayerState();
}

class _StubInAppVideoPlayerState extends State<StubInAppVideoPlayer> {
  bool _isPlaying = true;
  double _progress = 0.05;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.onWatched?.call();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (!_isPlaying) return;
      if (!mounted) return;
      setState(() {
        _progress += 0.003;
        if (_progress >= 1.0) _progress = 0.0;
      });
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
            Image.network(
              'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.darkCard,
                child: const Icon(Icons.ondemand_video, color: AppColors.primaryGold, size: 48),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.35)),
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.55),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.darkEmerald,
                  size: 38,
                ),
              ),
            ),
            // In-App Status Badge Top Left
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isPlaying ? const Color(0xFF10B981) : Colors.orangeAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isPlaying ? 'Playing In-App' : 'Paused',
                      style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // Progress Bar Bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
                minHeight: 3.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
