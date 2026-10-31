import 'package:flutter/material.dart';
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
}
