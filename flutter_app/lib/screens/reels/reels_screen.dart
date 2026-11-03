import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../models/reel_model.dart';
import '../../services/storage_service.dart';
import '../../widgets/video_player/shorts_player_widget.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  void _shareShort(ReelModel reel) {
    Share.share(
      '⚡ Islamic Short by Hafiz Hasnain Jaani:\n\n'
      '${reel.title}\n\n'
      'Watch: https://www.youtube.com/shorts/${reel.youtubeId}\n\n'
      'Hafiz Hasnain Jaani Official App',
    );
  }

  void _nextShort(int totalCount) {
    if (_currentPageIndex < totalCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevShort() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        // Smart unseen-first queue: unseen reels come first!
        final reels = appState.freshReels;

        // If an active reel was selected from Home, jump directly to it
        if (appState.activeReelId != null) {
          final targetIdx = reels.indexWhere((r) => r.id == appState.activeReelId);
          if (targetIdx >= 0 && targetIdx != _currentPageIndex) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) {
                _pageController.jumpToPage(targetIdx);
                setState(() => _currentPageIndex = targetIdx);
              }
              appState.setActiveReel(null);
            });
          }
        }

        if (reels.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'No shorts available right now',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 1. Vertical PageView for Reels
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: reels.length,
                onPageChanged: (index) {
                  setState(() => _currentPageIndex = index);
                  if (index >= 0 && index < reels.length) {
                    appState.markShortSeen(reels[index].id);
                  }
                },
                itemBuilder: (context, index) {
                  final reel = reels[index];
                  final isLiked = appState.isShortLiked(reel.id);
                  final isSeen = appState.isShortSeen(reel.id);

                  return _buildReelPage(
                    context,
                    reel,
                    isLiked,
                    isSeen,
                    index,
                    reels.length,
                    appState,
                  );
                },
              ),

              // 2. Next / Prev Quick Floating Nav Buttons (Right edge center)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_currentPageIndex > 0)
                        GestureDetector(
                          onTap: _prevShort,
                          child: Container(
                            width: 38,
                            height: 38,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primaryGold.withOpacity(0.5)),
                            ),
                            child: const Icon(Icons.keyboard_arrow_up_rounded,
                                color: Colors.white, size: 26),
                          ),
                        ),
                      if (_currentPageIndex < reels.length - 1)
                        GestureDetector(
                          onTap: () => _nextShort(reels.length),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primaryGold.withOpacity(0.5)),
                            ),
                            child: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.white, size: 26),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReelPage(
    BuildContext context,
    ReelModel reel,
    bool isLiked,
    bool isSeen,
    int index,
    int totalCount,
    AppStateService appState,
  ) {
    return Stack(
      children: [
        // 1. Working Embedded In-App Video Player
        Positioned.fill(
          child: buildShortsPlayer(
            youtubeId: reel.youtubeId,
            title: reel.title,
          ),
        ),

        // 2. Semi-transparent gradients for readable text
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ),

        // 3. Top Row Status (Watched / NEW & Official In-App badge)
        Positioned(
          top: 20,
          left: 16,
          right: 16,
          child: Row(
            children: [
              // YouTube-style Watched or New badge
              if (isSeen)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.redAccent, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.redAccent, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Watched',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '✨ NEW SHORT',
                    style: TextStyle(
                      color: AppColors.darkEmerald,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              const Spacer(),

              // In-App Reel Indicator Badge (No external jumping!)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGold, width: 1),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.bolt, color: AppColors.brightGold, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'In-App Short',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 4. Right Action Bar (Like, Share, Views, Scholar Avatar)
        Positioned(
          right: 16,
          bottom: 34,
          child: Column(
            children: [
              // Like Button
              _buildActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                iconColor: isLiked ? AppColors.liveRed : Colors.white,
                label: isLiked
                    ? '${(int.tryParse(reel.likes) ?? 0) + 1}'
                    : reel.likes,
                onTap: () => appState.toggleLikeShort(reel.id),
              ),
              const SizedBox(height: 16),

              // WhatsApp Share Button
              _buildActionButton(
                icon: Icons.share,
                iconColor: Colors.white,
                label: reel.shares,
                onTap: () => _shareShort(reel),
              ),
              const SizedBox(height: 16),

              // Views Counter
              _buildActionButton(
                icon: Icons.remove_red_eye_outlined,
                iconColor: AppColors.lightGold,
                label: reel.views,
                onTap: () {},
              ),
              const SizedBox(height: 16),

              // Scholar Profile Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 5. Bottom Left Video Description
        Positioned(
          left: 16,
          right: 76,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.primaryGold, width: 1.5),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Hafiz Hasnain Jaani',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified,
                    color: AppColors.brightGold,
                    size: 13,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                reel.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '#HafizHasnainJaani #Namaz #IslamicShorts',
                  style: TextStyle(
                    color: AppColors.lightGold,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 6. YouTube-Style Red Watched Progress Bar across bottom
        if (isSeen)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3.5,
              color: const Color(0xFFFF0000), // YouTube red!
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
