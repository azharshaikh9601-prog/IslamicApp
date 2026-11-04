import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../services/storage_service.dart';
import 'auth/auth_modal.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onTabSelected;
  final VoidCallback onOpenDashboard;
  final VoidCallback onOpenAskMasala;

  const AppDrawer({
    super.key,
    required this.onTabSelected,
    required this.onOpenDashboard,
    required this.onOpenAskMasala,
  });

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.darkEmerald,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
          // Scholar Header Card
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.darkEmerald, AppColors.deepEmerald],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.borderEmerald, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGold, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Flexible(
                            child: Text(
                              'Hafiz Hasnain Jaani',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            color: AppColors.brightGold,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Islamic Scholar & Creator',
                        style: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.4),
                          ),
                        ),
                        child: const Text(
                          '413K Subscribers',
                          style: TextStyle(
                            color: AppColors.lightGold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Links List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(0);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.bolt,
                  title: 'Short Clips',
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(1);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.ondemand_video_rounded,
                  title: 'Islamic Lessons',
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(2);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.school_outlined,
                  title: 'Courses',
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(3);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.format_quote_rounded,
                  title: 'Daily Quotes',
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(4);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.access_time_rounded,
                  title: 'Deen Tools',
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(6);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Scholar Profile',
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(7);
                  },
                ),
                const Divider(color: AppColors.borderEmerald, thickness: 1),
                _buildDrawerItem(
                  icon: Icons.question_answer_rounded,
                  title: "Ask a Mas'ala (Fatwa Office)",
                  badge: 'WhatsApp',
                  onTap: () {
                    Navigator.pop(context);
                    onOpenAskMasala();
                  },
                ),
                if (AppStateService().isAdmin)
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Scholar Dashboard',
                    badge: 'Admin',
                    onTap: () {
                      Navigator.pop(context);
                      onOpenDashboard();
                    },
                  ),
                const Divider(color: AppColors.borderEmerald, thickness: 1),
                // External Scholar Links
                _buildDrawerItem(
                  icon: Icons.language_rounded,
                  title: 'Official Website',
                  subtitle: 'hafizhasnainjaani.com',
                  onTap: () => _openUrl('https://hafizhasnainjaani.com'),
                ),
                _buildDrawerItem(
                  icon: Icons.ondemand_video_rounded,
                  title: 'YouTube Channel',
                  subtitle: '@HAFIZHASNAINJAANI',
                  onTap: () => _openUrl('https://youtube.com/@hafizhasnainjaani'),
                ),
                const Divider(color: AppColors.borderEmerald, thickness: 1),
                // Account / Auth
                Builder(
                  builder: (context) {
                    final appState = AppStateService();
                    final user = appState.currentUser;
                    if (user != null) {
                      return _buildDrawerItem(
                        icon: Icons.logout,
                        title: 'Sign Out (${user.username})',
                        subtitle: user.email,
                        onTap: () {
                          Navigator.pop(context);
                          appState.signOut();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Successfully signed out.'), backgroundColor: AppColors.darkEmerald),
                          );
                        },
                      );
                    } else {
                      return _buildDrawerItem(
                        icon: Icons.login,
                        title: 'Sign In / Register',
                        subtitle: '8-digit password account',
                        badge: 'Login',
                        onTap: () {
                          Navigator.pop(context);
                          AuthModal.show(context);
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderEmerald, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Hafiz Hasnain Jaani App',
                  style: TextStyle(
                    color: AppColors.darkTextMuted,
                    fontSize: 11,
                  ),
                ),
                Text(
                  'v1.0.0 • Ahle Sunnat',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGold, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 11,
              ),
            )
          : null,
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: AppColors.lightGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(
              Icons.chevron_right,
              color: AppColors.darkTextMuted,
              size: 16,
            ),
      onTap: onTap,
    );
  }
}
