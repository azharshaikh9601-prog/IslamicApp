import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../models/video_model.dart';
import '../../models/playlist_model.dart';
import '../../services/storage_service.dart';
import 'video_player_widget.dart';

class InAppPlayerModal extends StatefulWidget {
  final VideoModel video;
  final PlaylistModel? playlist;
  final int? playlistIndex;

  const InAppPlayerModal({
    super.key,
    required this.video,
    this.playlist,
    this.playlistIndex,
  });

  static void show(
    BuildContext context, {
    required VideoModel video,
    PlaylistModel? playlist,
    int? playlistIndex,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InAppPlayerModal(
        video: video,
        playlist: playlist,
        playlistIndex: playlistIndex,
      ),
    );
  }

  @override
  State<InAppPlayerModal> createState() => _InAppPlayerModalState();
}

class _InAppPlayerModalState extends State<InAppPlayerModal> {
  late VideoModel _currentVideo;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _currentIndex = widget.playlistIndex ?? 0;

    final appState = AppStateService();
    appState.markVideoWatched(_currentVideo.id);
  }

  void _playTrackAt(int index) {
    if (widget.playlist == null) return;
    if (index >= 0 && index < widget.playlist!.videos.length) {
      setState(() {
        _currentIndex = index;
        _currentVideo = widget.playlist!.videos[index];
      });
      AppStateService().markVideoWatched(_currentVideo.id);
    }
  }

  void _shareCurrentVideo() {
    Share.share(
      '🌟 Islamic Lesson by Hafiz Hasnain Jaani:\n\n'
      '${_currentVideo.title}\n\n'
      'Watch: https://www.youtube.com/watch?v=${_currentVideo.youtubeId}\n\n'
      'Hafiz Hasnain Jaani Official App',
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();
    final bool hasPlaylist =
        widget.playlist != null && widget.playlist!.videos.isNotEmpty;
    final isWatched = appState.isVideoWatched(_currentVideo.id);
    final isBookmarked = appState.isBookmarked(_currentVideo.id);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF041912),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
            decoration: const BoxDecoration(
              color: Color(0xFF02120C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: AppColors.borderEmerald)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_fill,
                          color: Colors.redAccent, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'IN-APP YOUTUBE PLAYER',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasPlaylist) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.playlist!.title,
                      style: const TextStyle(
                        color: AppColors.lightGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close Player',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // 16:9 In-App Video Player (Persistent Dimensions)
          Container(
            color: Colors.black,
            width: double.infinity,
            height: 220,
            child: buildInAppVideoPlayer(
              key: ValueKey(_currentVideo.youtubeId),
              youtubeId: _currentVideo.youtubeId,
              title: _currentVideo.title,
              onWatched: () => appState.markVideoWatched(_currentVideo.id),
            ),
          ),

          // Scrollable Body Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title
                Text(
                  _currentVideo.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Channel Info Row
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primaryGold, width: 1.5),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'Hafiz Hasnain Jaani',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.verified,
                                color: AppColors.brightGold, size: 14),
                          ],
                        ),
                        Text(
                          '${_currentVideo.views} • Official Lesson',
                          style: const TextStyle(
                            color: AppColors.darkTextMuted,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C241C),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderEmerald),
                      ),
                      child: Text(
                        _currentVideo.duration,
                        style: const TextStyle(
                          color: AppColors.brightGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Actions Row: Watched toggle, Star, Share
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            appState.toggleVideoWatched(_currentVideo.id),
                        icon: Icon(
                          isWatched
                              ? Icons.check_circle
                              : Icons.visibility_outlined,
                          color: isWatched ? Colors.white : AppColors.primaryGold,
                          size: 16,
                        ),
                        label: Text(
                          isWatched ? 'Watched ✓' : 'Mark Watched',
                          style: TextStyle(
                            color: isWatched
                                ? Colors.white
                                : AppColors.primaryGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isWatched
                              ? Colors.redAccent
                              : const Color(0xFF0C241C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isWatched
                                  ? Colors.redAccent
                                  : AppColors.borderEmerald,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () =>
                          appState.toggleBookmark(_currentVideo.id),
                      icon: Icon(
                        isBookmarked
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isBookmarked
                            ? AppColors.brightGold
                            : Colors.white70,
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF0C241C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.borderEmerald),
                        ),
                      ),
                      tooltip: 'Save',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _shareCurrentVideo,
                      icon: const Icon(Icons.share_rounded,
                          color: Colors.white70, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF0C241C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.borderEmerald),
                        ),
                      ),
                      tooltip: 'Share',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF082218),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderEmerald),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lesson Details',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _currentVideo.description.isNotEmpty
                            ? _currentVideo.description
                            : 'Authentic Islamic lecture and practical rulings by Hafiz Hasnain Jaani according to the Holy Quran, Sunnah, and Fiqh-e-Hanafi.',
                        style: const TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Playlist Tracklist
                if (hasPlaylist) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Playlist Queue (${widget.playlist!.videos.length} Lessons)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_currentIndex + 1} of ${widget.playlist!.videos.length}',
                        style: const TextStyle(
                          color: AppColors.lightGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _currentIndex > 0
                              ? () => _playTrackAt(_currentIndex - 1)
                              : null,
                          icon: const Icon(Icons.skip_previous_rounded, size: 16),
                          label: const Text('Previous',
                              style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                                color: AppColors.borderEmerald),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _currentIndex <
                                  widget.playlist!.videos.length - 1
                              ? () => _playTrackAt(_currentIndex + 1)
                              : null,
                          icon: const Icon(Icons.skip_next_rounded,
                              size: 16, color: AppColors.darkEmerald),
                          label: const Text('Next Lesson',
                              style: TextStyle(
                                color: AppColors.darkEmerald,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(widget.playlist!.videos.length, (idx) {
                    final track = widget.playlist!.videos[idx];
                    final isCurrent = idx == _currentIndex;
                    final isTrackWatched = appState.isVideoWatched(track.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isCurrent
                            ? AppColors.primaryGold.withOpacity(0.12)
                            : const Color(0xFF082218),
                        borderRadius: BorderRadius.circular(10),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrent
                                  ? AppColors.brightGold
                                  : AppColors.borderEmerald,
                              width: isCurrent ? 1.2 : 0.8,
                            ),
                          ),
                          child: ListTile(
                        onTap: () => _playTrackAt(idx),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.primaryGold
                                : Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isCurrent
                                ? const Icon(Icons.play_arrow_rounded,
                                    size: 16, color: AppColors.darkEmerald)
                                : Text(
                                    '${idx + 1}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(
                          track.title,
                          style: TextStyle(
                            color:
                                isCurrent ? AppColors.brightGold : Colors.white,
                            fontSize: 12,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${track.duration} • ${track.views}',
                          style: const TextStyle(
                            color: AppColors.darkTextMuted,
                            fontSize: 10,
                          ),
                        ),
                        trailing: isTrackWatched
                            ? const Icon(Icons.check_circle_rounded,
                                color: Colors.redAccent, size: 16)
                            : null,
                      ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
