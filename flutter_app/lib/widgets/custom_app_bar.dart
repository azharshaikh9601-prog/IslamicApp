import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import 'auth/auth_modal.dart';

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

              const SizedBox(width: 6),

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
                      Text(
                        AppStateService().isLoggedIn
                            ? AppStateService().currentUser!.username
                            : 'Sign In',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
}
