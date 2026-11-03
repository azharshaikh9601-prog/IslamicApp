import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import 'auth/auth_modal.dart';
import 'video_player/in_app_player_modal.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentTabIndex;
  final Function(int) onTabSelected;
  final VoidCallback? onAdminTap;

  const CustomAppBar({
    super.key,
    required this.currentTabIndex,
    required this.onTabSelected,
    this.onAdminTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF031E16),
        border: Border(
          bottom: BorderSide(color: AppColors.borderEmerald, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Row(
            children: [
              // 3-Line Vertical Hamburger Menu Button
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.primaryGold, size: 24),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Menu',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ),
              const SizedBox(width: 4),

              // Brand / Scholar Avatar & Title
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabSelected(0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGold, width: 1.5),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/logo.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Flexible(
                                  child: Text(
                                    'Hafiz Hasnain Jaani',
                                    style: TextStyle(
                                      color: Color(0xFFE2C475),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.verified,
                                  color: Color(0xFF38BDF8),
                                  size: 14,
                                ),
                              ],
                            ),
                            const Text(
                              'Official Islamic App',
                              style: TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // On wide screens: Show tab pills
              if (!isMobile) ...[
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabBtn(index: 0, icon: Icons.home_rounded, label: 'Home'),
                        _buildTabBtn(index: 1, icon: Icons.bolt, label: 'Short Clips'),
                        _buildTabBtn(index: 2, icon: Icons.ondemand_video_rounded, label: 'Islamic Lessons'),
                        _buildTabBtn(index: 3, icon: Icons.school_outlined, label: 'Courses'),
                        _buildTabBtn(index: 4, icon: Icons.format_quote_rounded, label: 'Daily Quotes'),
                        _buildTabBtn(index: 5, icon: Icons.access_time_rounded, label: 'Deen Tools'),
                        _buildTabBtn(index: 6, icon: Icons.person_outline_rounded, label: 'Scholar Profile'),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(width: 4),

              // Notification Bell Icon with Badge for New Video Uploads
              AnimatedBuilder(
                animation: AppStateService(),
                builder: (context, _) {
                  final appState = AppStateService();
                  final count = appState.unreadNotificationsCount;
                  return IconButton(
                    onPressed: () => _showNotificationsModal(context, appState),
                    tooltip: 'New Video Notifications',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.redAccent,
                      child: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryGold, size: 21),
                    ),
                  );
                },
              ),

              const SizedBox(width: 4),

              // Right Actions: User Profile Chip
              GestureDetector(
                onTap: () {
                  final appState = AppStateService();
                  if (!appState.isLoggedIn) {
                    AuthModal.show(context);
                  } else {
                    _showUserMenu(context, appState.currentUser!, appState);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C241C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppStateService().isLoggedIn ? AppColors.primaryGold : AppColors.borderEmerald,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppStateService().isLoggedIn ? AppColors.primaryGold : Colors.white24,
                        ),
                        child: Center(
                          child: Text(
                            AppStateService().isLoggedIn && AppStateService().currentUser!.username.isNotEmpty
                                ? AppStateService().currentUser!.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Color(0xFF032B1F),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isMobile ? 85 : 140),
                        child: Text(
                          AppStateService().isLoggedIn
                              ? AppStateService().currentUser!.username
                              : 'Sign In',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context, UserModel user, AppStateService appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF041E16),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryGold,
                  child: Text(
                    user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Color(0xFF032B1F), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.username,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: user.isAdmin ? AppColors.primaryGold.withOpacity(0.2) : const Color(0xFF10B981).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: user.isAdmin ? AppColors.primaryGold : const Color(0xFF10B981), width: 0.8),
                            ),
                            child: Text(
                              user.isAdmin ? 'ADMIN' : 'STUDENT',
                              style: TextStyle(
                                color: user.isAdmin ? AppColors.primaryGold : const Color(0xFF34D399),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(user.email, style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderEmerald),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.school, color: AppColors.primaryGold),
              title: const Text('Enrolled Courses', style: TextStyle(color: Colors.white, fontSize: 13)),
              trailing: Text('${user.enrolledCourseIds.length}', style: const TextStyle(color: AppColors.brightGold, fontWeight: FontWeight.bold)),
              contentPadding: EdgeInsets.zero,
            ),
            if (user.isAdmin && onAdminTap != null)
              ListTile(
                leading: const Icon(Icons.dashboard_customize, color: AppColors.primaryGold),
                title: const Text('Open Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  onAdminTap?.call();
                },
                contentPadding: EdgeInsets.zero,
              ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Sign Out (لاگ آؤٹ)', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                appState.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully signed out.'), backgroundColor: AppColors.darkEmerald),
                );
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBtn({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentTabIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFECC24E) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? const Color(0xFF032B1F)
                    : AppColors.darkTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF032B1F)
                      : AppColors.darkTextSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsModal(BuildContext context, AppStateService appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final notifications = appState.newVideoNotifications.isNotEmpty
            ? appState.newVideoNotifications
            : appState.videos.take(5).toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF031E16),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.primaryGold.withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.notifications_active, color: AppColors.primaryGold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'New Video Notifications',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      appState.markNotificationsRead();
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.done_all, size: 16, color: AppColors.lightGold),
                    label: const Text('Mark Read', style: TextStyle(color: AppColors.lightGold, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Latest authentic Islamic uploads from Hafiz Hasnain Jaani (Live YouTube Sync)',
                style: TextStyle(color: AppColors.darkTextMuted, fontSize: 11),
              ),
              const SizedBox(height: 14),

              // Videos List
              Expanded(
                child: notifications.isEmpty
                    ? const Center(
                        child: Text(
                          'No new video notifications right now.',
                          style: TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const Divider(color: AppColors.borderEmerald, height: 16),
                        itemBuilder: (context, idx) {
                          final video = notifications[idx];
                          final isFirst = idx < 3;
                          return InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              appState.markVideoWatched(video.id);
                              InAppPlayerModal.show(context, video: video, playlist: appState.playlists.isNotEmpty ? appState.playlists.first : null);
                            },
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        video.thumbnailUrl,
                                        width: 100,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 100,
                                          height: 60,
                                          color: AppColors.surfaceEmerald,
                                          child: const Icon(Icons.play_circle_fill, color: AppColors.primaryGold),
                                        ),
                                      ),
                                    ),
                                    if (isFirst)
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'NEW',
                                            style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video.title,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.visibility, size: 12, color: AppColors.lightGold),
                                          const SizedBox(width: 4),
                                          Text(video.views, style: const TextStyle(color: AppColors.lightGold, fontSize: 10.5)),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF133629),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              video.category.toUpperCase(),
                                              style: const TextStyle(color: AppColors.brightGold, fontSize: 8.5, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.play_arrow_rounded, color: AppColors.primaryGold, size: 24),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
