import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../data/initial_data.dart';
import '../../services/storage_service.dart';

class ScholarProfileScreen extends StatelessWidget {
  final VoidCallback onOpenAskMasala;

  const ScholarProfileScreen({super.key, required this.onOpenAskMasala});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();
    final profile = InitialData.scholarProfile;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // User Deen Progress Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0C241C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderEmerald),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'HJ',
                        style: TextStyle(
                          color: Color(0xFF032B1F),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hafiz (Student of Deen)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Active Ummah Member',
                          style: TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF133629),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderEmerald),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fingerprint,
                            color: AppColors.brightGold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${appState.tasbeehTotal} Dhikr',
                          style: const TextStyle(
                            color: AppColors.lightGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Scholar Official Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.4),
                  width: 1.5,
                ),
                gradient: const LinearGradient(
                  colors: [Color(0xFF072A1F), Color(0xFF021711)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.brightGold,
                        width: 2.5,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withOpacity(0.3),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Name and Verified Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          profile['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: AppColors.brightGold,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile['title']} • ${profile['location']}',
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Bio
                  Text(
                    profile['bio'] as String,
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  // Stats Grid
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceEmerald.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderEmerald.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildProfileStat(
                            (profile['subscribers'] as String).replaceAll(' Subscribers', ''),
                            'Subscribers',
                          ),
                        ),
                        Container(height: 30, width: 1, color: AppColors.borderEmerald),
                        Expanded(
                          child: _buildProfileStat(
                            (profile['totalViews'] as String).replaceAll(' Total Views', ''),
                            'Total Views',
                          ),
                        ),
                        Container(height: 30, width: 1, color: AppColors.borderEmerald),
                        Expanded(
                          child: _buildProfileStat(
                            (profile['videosCount'] as String).replaceAll(' Videos', ''),
                            'Videos',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Official YouTube Button
                  ElevatedButton.icon(
                    onPressed: () => _launchUrl(profile['youtubeUrl'] as String),
                    icon: const Icon(Icons.play_circle_fill, size: 20),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Subscribe on YouTube (@HAFIZHASNAINJAANI)'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.youTube,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // WhatsApp Contact
                  OutlinedButton.icon(
                    onPressed: onOpenAskMasala,
                    icon: const Icon(Icons.chat_bubble, color: AppColors.whatsApp, size: 18),
                    label: const Text('Ask a Mas\'ala via WhatsApp Office'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.borderEmerald),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.lightGold,
              fontSize: 10.5,
            ),
          ),
        ),
      ],
    );
  }
}
