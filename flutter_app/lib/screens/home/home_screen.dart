import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../data/initial_data.dart';
import '../../models/video_model.dart';
import '../../models/reel_model.dart';
import '../../services/storage_service.dart';
import '../../widgets/salah_schedule_widget.dart';
import '../../widgets/video_player/in_app_player_modal.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onTabSelected;
  final VoidCallback onOpenAskMasala;

  const HomeScreen({
    super.key,
    required this.onTabSelected,
    required this.onOpenAskMasala,
  });

  void _playVideoInApp(BuildContext context, VideoModel video) {
    InAppPlayerModal.show(context, video: video);
  }

  void _shareVideo(VideoModel video) {
    Share.share(
      '🌟 Watch this Islamic Bayan by Hafiz Hasnain Jaani:\n\n'
      '${video.title}\n\n'
      'Watch: https://www.youtube.com/watch?v=${video.youtubeId}\n\n'
      'Hafiz Hasnain Jaani Official App',
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.only(top: 14, bottom: 32),
          children: [
            // -----------------------------------------------------------------
            // 1. ESSENTIAL LEARNING TOPICS AT THE VERY TOP OF HOME PAGE
            // -----------------------------------------------------------------
            _buildNineTopicBlocks(context, appState),

            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // 2. SALAH TIME TABLE BELOW ESSENTIAL TOPICS
            // -----------------------------------------------------------------
            const SalahScheduleWidget(),

            const SizedBox(height: 12),

            // Real World Time & Islamic Date Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A241A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderEmerald),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_filled, color: AppColors.primaryGold, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${DateFormat('EEEE, d MMM yyyy').format(DateTime.now())} • Local: ${DateFormat('hh:mm a').format(DateTime.now())}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF133629),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi, color: Color(0xFF34D399), size: 10),
                          SizedBox(width: 4),
                          Text(
                            'LIVE SYNC',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // -----------------------------------------------------------------
            // 3. LONG VIDEO SECTION (LATEST YOUTUBE BAYANAAT & LESSONS)
            // -----------------------------------------------------------------
            _buildFeaturedBayanaat(context, appState.videos, appState),

            const SizedBox(height: 26),

            // -----------------------------------------------------------------
            // 4. SHORT VIDEO SECTION (ISLAMIC SHORT CLIPS / REELS)
            // -----------------------------------------------------------------
            _buildShortsSection(context, appState.freshReels, appState),

            const SizedBox(height: 26),

            // -----------------------------------------------------------------
            // 5. DAILY QUOTES AT LAST
            // -----------------------------------------------------------------
            _buildQuotesSnippet(context),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 1. THE 9 ESSENTIAL LEARNING BLOCKS (AT THE VERY TOP)
  // ---------------------------------------------------------------------------
  Widget _buildNineTopicBlocks(BuildContext context, AppStateService appState) {
    final List<Map<String, dynamic>> blocks = [
      {
        'num': '1',
        'title': 'Wazu & Ghusal',
        'urdu': 'وضو اور غسل',
        'icon': Icons.water_drop_outlined,
        'color': const Color(0xFF0D9488),
        'onTap': () {
          appState.selectTopic('Wazu & Ghusal', playlistId: 'pl-wudu-ghusl');
          onTabSelected(2); // Lessons tab
        },
      },
      {
        'num': '2',
        'title': 'Namaz Ka Aasan Tarika',
        'urdu': 'نماز کا آسان طریقہ',
        'icon': Icons.accessibility_new_rounded,
        'color': AppColors.primaryGold,
        'onTap': () {
          appState.selectTopic('Namaz Ka Tarika');
          onTabSelected(2); // Lessons tab
        },
      },
      {
        'num': '3',
        'title': 'Aurat Ki Namaz',
        'urdu': 'عورت کی نماز',
        'icon': Icons.person_outline_rounded,
        'color': const Color(0xFFEC4899),
        'onTap': () {
          appState.selectTopic('Aurat Ki Namaz', playlistId: 'pl-aurat-namaz');
          onTabSelected(2); // Lessons tab
        },
      },
      {
        'num': '4',
        'title': 'Namaz ke Zaroori Masail',
        'urdu': 'نماز کے ضروری مسائل',
        'icon': Icons.help_outline_rounded,
        'color': const Color(0xFFF59E0B),
        'onTap': () {
          appState.selectTopic('Namaz ke Zaroori Masail', playlistId: 'pl-masail-namaz');
          onTabSelected(2); // Lessons tab
        },
      },
      {
        'num': '5',
        'title': 'NAMAZ COURSE',
        'urdu': 'مکمل نماز کورس',
        'icon': Icons.workspace_premium_rounded,
        'isCourse': true,
        'color': const Color(0xFFFFD700),
        'onTap': () {
          onTabSelected(3); // Courses tab
        },
      },
      {
        'num': '6',
        'title': 'Shariat ke Masail',
        'urdu': 'شریعت کے مسائل',
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF10B981),
        'onTap': () {
          appState.selectTopic('Shariat ke Masail', playlistId: 'pl-shariat-masail');
          onTabSelected(2); // Lessons tab
        },
      },
      {
        'num': '7',
        'title': 'Qaza Namaz Ka Tarika',
        'urdu': 'قضا نماز کا طریقہ',
        'icon': Icons.update_rounded,
        'color': const Color(0xFF6366F1),
        'onTap': () {
          appState.selectTopic('Qaza Namaz Ka Tarika', playlistId: 'pl-qaza-namaz');
          onTabSelected(2); // Lessons tab
        },
      },
      {
        'num': '8',
        'title': 'Fatiha Dene ka tarika',
        'urdu': 'فاتحہ دینے کا طریقہ',
        'icon': Icons.volunteer_activism_outlined,
        'color': const Color(0xFF8B5CF6),
        'onTap': () {
          appState.selectTopic('Fatiha Dene ka tarika', playlistId: 'pl-fatiha-tarika');
          onTabSelected(2); // Lessons tab
        },
      },
      {
        'num': '9',
        'title': 'Imam Ke Peeche Namaz ka Tarika',
        'urdu': 'امام کے پیچھے نماز',
        'icon': Icons.groups_rounded,
        'color': const Color(0xFF14B8A6),
        'onTap': () {
          appState.selectTopic('Imam Ke Peeche Namaz ka Tarika', playlistId: 'pl-imam-peeche');
          onTabSelected(2); // Lessons tab
        },
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_rounded,
                    color: AppColors.primaryGold, size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Essential Learning Topics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Select any topic to watch dedicated lessons in-app',
                      style: TextStyle(
                        color: AppColors.darkTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3x3 Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: blocks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final b = blocks[index];
              final bool isCourse = b['isCourse'] == true;
              final Color accentColor = b['color'] as Color;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: b['onTap'] as VoidCallback,
                  borderRadius: BorderRadius.circular(14),
                  splashColor: accentColor.withOpacity(0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isCourse
                          ? const LinearGradient(
                              colors: [Color(0xFF281E08), Color(0xFF140F04)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF082218), Color(0xFF041710)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCourse
                            ? AppColors.brightGold
                            : accentColor.withOpacity(0.4),
                        width: isCourse ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isCourse ? AppColors.primaryGold : Colors.black)
                              .withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon (Clean without numbers)
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isCourse
                                ? AppColors.primaryGold.withOpacity(0.25)
                                : accentColor.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCourse
                                  ? AppColors.brightGold
                                  : accentColor.withOpacity(0.6),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            b['icon'] as IconData,
                            color: isCourse ? AppColors.brightGold : accentColor,
                            size: 21,
                          ),
                        ),
                        const SizedBox(height: 7),

                        // Title
                        Text(
                          b['title'] as String,
                          style: TextStyle(
                            color: isCourse ? AppColors.brightGold : Colors.white,
                            fontSize: 10.5,
                            fontWeight: isCourse ? FontWeight.w900 : FontWeight.bold,
                            height: 1.15,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Urdu Subtitle
                        Text(
                          b['urdu'] as String,
                          style: TextStyle(
                            color: isCourse
                                ? AppColors.lightGold
                                : AppColors.darkTextMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. LONG VIDEO SECTION (PLAYS IN-APP!)
  // ---------------------------------------------------------------------------
  Widget _buildFeaturedBayanaat(
    BuildContext context,
    List<VideoModel> videos,
    AppStateService appState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🎥', style: TextStyle(fontSize: 18)),
              SizedBox(width: 6),
              Text(
                'Latest Islamic Videos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Watch Islamic Videos, Namaz Tutorials & Authentic Deeni Guidance',
            style: TextStyle(
              color: AppColors.darkTextMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              appState.clearTopicSelection();
              onTabSelected(2); // Islamic Lessons tab
            },
            child: const Text(
              'Browse All Playlists & Videos →',
              style: TextStyle(
                color: AppColors.primaryGold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Horizontal Video Cards
          SizedBox(
            height: 285,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: videos.take(6).length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final video = videos[index];
                final isBookmarked = appState.isBookmarked(video.id);
                final isWatched = appState.isVideoWatched(video.id);

                return _buildVideoCard(context, video, isBookmarked, isWatched, appState);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(
    BuildContext context,
    VideoModel video,
    bool isBookmarked,
    bool isWatched,
    AppStateService appState,
  ) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF0C241C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWatched
              ? AppColors.primaryGold.withOpacity(0.5)
              : AppColors.borderEmerald,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with in-app play trigger
          GestureDetector(
            onTap: () => _playVideoInApp(context, video),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceEmerald,
                        child: const Icon(Icons.video_library,
                            color: AppColors.primaryGold),
                      ),
                    ),
                  ),
                ),

                // Category Badges Top Left
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF032B1F).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: AppColors.primaryGold.withOpacity(0.5)),
                          ),
                          child: Text(
                            video.category == 'namaz'
                                ? 'Namaz'
                                : 'Baghdadi / Qaida',
                            style: const TextStyle(
                              color: AppColors.lightGold,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (video.isMasterclass) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🎓 ', style: TextStyle(fontSize: 8)),
                              Text(
                                'MASTERCLASS',
                                style: TextStyle(
                                  color: Color(0xFF032B1F),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Watched Badge Top Right
                if (isWatched)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.redAccent, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.redAccent, size: 10),
                          SizedBox(width: 3),
                          Text(
                            'Watched',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Play Icon in Center
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.brightGold,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Duration Badge Bottom Right
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // YouTube-Style Red Progress Bar at the bottom
                if (isWatched)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3.5,
                      color: const Color(0xFFFF0000), // YouTube Red!
                    ),
                  ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Hafiz Hasnain Jaani',
                        style: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('•', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(
                      video.views,
                      style: const TextStyle(
                        color: AppColors.darkTextMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Action Buttons Row (Play In-App, Seen toggle, Star)
                Row(
                  children: [
                    InkWell(
                      onTap: () => _playVideoInApp(context, video),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF133629),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderEmerald),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.play_arrow,
                                color: AppColors.primaryGold, size: 12),
                            SizedBox(width: 2),
                            Text(
                              'Play In-App',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => appState.toggleVideoWatched(video.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: isWatched
                              ? Colors.redAccent.withOpacity(0.18)
                              : Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isWatched ? Colors.redAccent : Colors.white24,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isWatched ? Icons.check : Icons.visibility_outlined,
                              color: isWatched ? Colors.redAccent : Colors.white70,
                              size: 11,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isWatched ? 'Seen ✓' : 'Mark Seen',
                              style: TextStyle(
                                color: isWatched ? Colors.redAccent : Colors.white70,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _shareVideo(video),
                      child: const Icon(
                        Icons.share_rounded,
                        color: AppColors.darkTextSecondary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => appState.toggleBookmark(video.id),
                      child: Icon(
                        isBookmarked ? Icons.star : Icons.star_border,
                        color: isBookmarked
                            ? AppColors.brightGold
                            : AppColors.darkTextMuted,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. SHORT VIDEO SECTION (REELS / SHORTS)
  // ---------------------------------------------------------------------------
  Widget _buildShortsSection(
    BuildContext context,
    List<ReelModel> reels,
    AppStateService appState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text('⚡', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 6),
                  Text(
                    'Islamic Short Clips (Reels)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                'Quick 60-second Sunnah reminders, common mistakes & viral tips',
                style: TextStyle(
                  color: AppColors.darkTextMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () => onTabSelected(1), // Switch to Short Clips tab
                child: const Text(
                  'Watch Fullscreen Reels In-App →',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 195,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: reels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final reel = reels[index];
              final isSeen = appState.isShortSeen(reel.id);
              return _buildShortCard(context, reel, isSeen, appState);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShortCard(
      BuildContext context, ReelModel reel, bool isSeen, AppStateService appState) {
    return GestureDetector(
      onTap: () {
        appState.setActiveReel(reel.id);
        onTabSelected(1); // Plays directly in-app on Reels tab
      },
      child: Container(
        width: 125,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSeen ? Colors.redAccent.withOpacity(0.6) : AppColors.borderEmerald,
            width: isSeen ? 1.5 : 1,
          ),
          image: DecorationImage(
            image: NetworkImage(reel.thumbnailUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Top Status Badge (Watched or NEW)
            Positioned(
              top: 8,
              left: 8,
              child: isSeen
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.redAccent, width: 0.8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check, color: Colors.redAccent, size: 8),
                          SizedBox(width: 2),
                          Text(
                            'Watched',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '✨ NEW',
                        style: TextStyle(
                          color: AppColors.darkEmerald,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
            ),

            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.bolt, color: AppColors.brightGold, size: 16),
            ),

            Positioned(
              left: 8,
              right: 8,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reel.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reel.views,
                    style: const TextStyle(
                      color: AppColors.lightGold,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            // YouTube Red progress bar if watched
            if (isSeen)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  color: const Color(0xFFFF0000),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. DAILY QUOTES (AT LAST)
  // ---------------------------------------------------------------------------
  Widget _buildQuotesSnippet(BuildContext context) {
    final quote = InitialData.quotes.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('💬', style: TextStyle(fontSize: 18)),
              SizedBox(width: 6),
              Text(
                'Today\'s Sacred Guidance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Ayah & Hadith with Arabic calligraphy & Urdu translation',
            style: TextStyle(
              color: AppColors.darkTextMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => onTabSelected(4), // Daily Quotes tab
            child: const Text(
              'All Quotes Studio →',
              style: TextStyle(
                color: AppColors.primaryGold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0C241C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderEmerald),
            ),
            child: Column(
              children: [
                Text(
                  quote.arabic,
                  style: const TextStyle(
                    color: AppColors.lightGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  quote.urdu,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '— ${quote.reference}',
                  style: const TextStyle(
                    color: AppColors.darkTextMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
