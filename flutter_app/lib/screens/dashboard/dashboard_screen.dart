import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../services/storage_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _broadcastController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _broadcastController.text = 'Hafiz Hasnain Jaani Official Islamic App';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppStateService().loadAdminUsers();
    });
  }

  @override
  void dispose() {
    _broadcastController.dispose();
    super.dispose();
  }

  Future<void> _launchYouTubeStudio() async {
    final uri = Uri.parse('https://studio.youtube.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            title: const Text('Executive Scholar Dashboard'),
            backgroundColor: AppColors.darkEmerald,
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_new, color: AppColors.primaryGold),
                onPressed: _launchYouTubeStudio,
                tooltip: 'Open YouTube Studio',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Scholar Welcome Card
              _buildWelcomeCard(),

              const SizedBox(height: 18),

              // 2. Real-Time KPI Metrics Grid
              _buildKPIGrid(appState),

              const SizedBox(height: 20),

              // 3. Live Broadcast Announcement Manager
              _buildBroadcastManager(appState),

              const SizedBox(height: 20),

              // 4. Content Distribution Progress
              _buildContentDistribution(),

              const SizedBox(height: 20),

              // 5. Inquiries & WhatsApp Inbox
              _buildInquiriesInbox(),

              const SizedBox(height: 20),

              // 6. Registered Users Management (Live from Database)
              _buildRegisteredUsersSection(appState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
        gradient: const LinearGradient(
          colors: [Color(0xFF063325), Color(0xFF021711)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
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
                    Text(
                      'Hazrat Hafiz Hasnain Jaani',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.verified, color: AppColors.brightGold, size: 16),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Channel Control & App Broadcaster',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Connected to @HAFIZHASNAINJAANI',
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
    );
  }

  Widget _buildKPIGrid(AppStateService appState) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: [
        _buildKPICard(
          title: 'Subscribers',
          value: '411.8K',
          trend: '+2.4K this month',
          icon: Icons.people_alt_rounded,
          color: AppColors.primaryGold,
        ),
        _buildKPICard(
          title: 'Bayan Videos',
          value: '${appState.videos.length} Active',
          trend: '+320K views this wk',
          icon: Icons.video_library_rounded,
          color: AppColors.info,
        ),
        _buildKPICard(
          title: 'Islamic Shorts',
          value: '${appState.reels.length} Reels',
          trend: '8.4M viral plays',
          icon: Icons.bolt,
          color: AppColors.brightGold,
        ),
        _buildKPICard(
          title: 'Ummah Tasbeeh',
          value: '${appState.tasbeehTotal} Recited',
          trend: 'Global spiritual tally',
          icon: Icons.fingerprint_rounded,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderEmerald),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            trend,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastManager(AppStateService appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderEmerald),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.admin_panel_settings_rounded,
                      color: AppColors.primaryGold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Admin Posting Permissions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Switch(
                value: appState.isAdmin,
                activeColor: AppColors.primaryGold,
                onChanged: (val) {
                  appState.setAdminMode(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'When enabled, creation buttons appear across Quotes, Lessons, and Courses allowing the Admin to post content.',
            style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildContentDistribution() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderEmerald),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Channel Content Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _buildProgressBar('Namaz Ka Tarika (Fiqh-e-Hanafi)', 0.38, '38%'),
          _buildProgressBar('Islamic Shorts & Reels', 0.24, '24%'),
          _buildProgressBar('Wudu & Ghusl Faraiz', 0.16, '16%'),
          _buildProgressBar('Baghdadi Qaida & Tajweed', 0.12, '12%'),
          _buildProgressBar('Daily Masail & Fatawa', 0.10, '10%'),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String title, double factor, String pct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                pct,
                style: const TextStyle(
                  color: AppColors.lightGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: factor,
            backgroundColor: AppColors.surfaceEmerald,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            minHeight: 5,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiriesInbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderEmerald),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Recent Masail Inquiries',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'WhatsApp Sync',
                style: TextStyle(color: AppColors.whatsApp, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInquiryTile(
            name: 'Muhammad Farhan (Patna)',
            question: 'Sajda Sahw ke bad salam kab pherna hai?',
            status: 'Answered',
          ),
          _buildInquiryTile(
            name: 'Tariq Ansari (Katihar)',
            question: 'Safar mein Qasr Namaz ki hadd kitni hai?',
            status: 'Pending',
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryTile({
    required String name,
    required String question,
    required String status,
  }) {
    final isAnswered = status == 'Answered';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceEmerald,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  question,
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isAnswered
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isAnswered ? AppColors.success : AppColors.warning,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredUsersSection(AppStateService appState) {
    final users = appState.adminUsers;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderEmerald),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.people_alt, color: AppColors.primaryGold, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registered Users & Accounts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total Users in Database: ${users.length}',
                        style: const TextStyle(
                          color: AppColors.darkTextMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primaryGold),
                tooltip: 'Refresh Users List',
                onPressed: () => appState.loadAdminUsers(),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: AppColors.borderEmerald, height: 1),
          const SizedBox(height: 14),

          if (users.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const Icon(Icons.group_off, color: Colors.white38, size: 36),
                    const SizedBox(height: 8),
                    const Text('No users loaded yet', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => appState.loadAdminUsers(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.darkEmerald,
                      ),
                      child: const Text('Fetch Users from Server'),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final u = users[index];
                final initial = u.username.isNotEmpty ? u.username[0].toUpperCase() : 'U';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF031E16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: u.isAdmin ? AppColors.primaryGold.withOpacity(0.5) : AppColors.borderEmerald,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: u.isAdmin
                                ? AppColors.primaryGold.withOpacity(0.2)
                                : const Color(0xFF10B981).withOpacity(0.2),
                            child: Text(
                              initial,
                              style: TextStyle(
                                color: u.isAdmin ? AppColors.primaryGold : const Color(0xFF34D399),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        u.username,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: u.isAdmin
                                            ? AppColors.primaryGold.withOpacity(0.2)
                                            : const Color(0xFF10B981).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: u.isAdmin ? AppColors.primaryGold : const Color(0xFF10B981),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        u.isAdmin ? 'ADMIN' : 'STUDENT',
                                        style: TextStyle(
                                          color: u.isAdmin ? AppColors.primaryGold : const Color(0xFF34D399),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  u.email,
                                  style: const TextStyle(
                                    color: AppColors.darkTextSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFF073024), height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.school, size: 13, color: AppColors.lightGold),
                              const SizedBox(width: 4),
                              Text(
                                'Enrolled: ${u.enrolledCourseIds.length} Courses',
                                style: const TextStyle(color: AppColors.lightGold, fontSize: 10.5),
                              ),
                            ],
                          ),
                          Text(
                            u.lastLoginAt != null
                                ? 'Last Active: ${dateFormat.format(u.lastLoginAt!.toLocal())}'
                                : 'Registered: ${dateFormat.format(u.createdAt.toLocal())}',
                            style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
