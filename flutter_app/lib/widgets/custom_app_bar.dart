import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

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

              // Right Actions: User Profile Chip [HJ] Hafiz ⌄ (as in Screenshot)
              GestureDetector(
                onTap: onAdminTap ?? () => onTabSelected(5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C241C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderEmerald),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGold,
                        ),
                        child: const Center(
                          child: Text(
                            'HJ',
                            style: TextStyle(
                              color: Color(0xFF032B1F),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Hafiz',
                        style: TextStyle(
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
