import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/prayer_locations.dart';
import '../../services/storage_service.dart';
import '../../services/prayer_calculator_service.dart';
import '../../services/gps_location_service.dart';
import '../../models/prayer_location_model.dart';

class ToolsScreen extends StatefulWidget {
  final int initialTabIndex;

  const ToolsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Tool Tabs (Digital Tasbeeh & Salah Times)
        Container(
          color: AppColors.darkEmerald,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryGold,
            indicatorWeight: 3,
            labelColor: AppColors.brightGold,
            unselectedLabelColor: AppColors.darkTextSecondary,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(icon: Icon(Icons.fingerprint), text: 'Digital Tasbeeh'),
              Tab(icon: Icon(Icons.access_time), text: 'Salah Times'),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTasbeehTab(),
              _buildPrayerTimesTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TAB 1: DIGITAL TASBEEH COUNTER
  // ==========================================================================
  Widget _buildTasbeehTab() {
    final appState = AppStateService();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        final currentDhikr = appState.currentDhikr;
        final count = appState.tasbeehCount;
        final target = currentDhikr.target;
        final progress = (count / target).clamp(0.0, 1.0);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Dhikr Selector Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderEmerald),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: appState.dhikrList.any((d) => d.id == currentDhikr.id)
                      ? currentDhikr.id
                      : appState.dhikrList.first.id,
                  dropdownColor: AppColors.darkEmerald,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: AppColors.primaryGold),
                  isExpanded: true,
                  items: appState.dhikrList.map((dhikr) {
                    return DropdownMenuItem<String>(
                      value: dhikr.id,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              dhikr.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: Text(
                              dhikr.arabic,
                              style: AppTheme.arabicStyle.copyWith(
                                fontSize: 14,
                                color: AppColors.lightGold,
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newDhikrId) {
                    if (newDhikrId != null) {
                      final selected = appState.dhikrList.firstWhere(
                        (d) => d.id == newDhikrId,
                        orElse: () => appState.dhikrList.first,
                      );
                      appState.selectDhikr(selected);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Arabic Calligraphy Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    currentDhikr.arabic,
                    style: AppTheme.arabicStyle.copyWith(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentDhikr.meaning,
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Interactive Bead Click Button with Circular Progress
            Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  appState.incrementTasbeeh();
                },
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular Progress Ring
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: AppColors.surfaceEmerald,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.brightGold),
                        ),
                      ),
                      // Core Bead Circle
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFF0C3D2E), Color(0xFF032219)],
                          ),
                          border: Border.all(
                            color: AppColors.primaryGold,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGold.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Target: $target',
                              style: const TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'TAP TO COUNT',
                              style: TextStyle(
                                color: AppColors.darkTextMuted,
                                fontSize: 9,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Reset and Total Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reset Button
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    appState.resetTasbeeh();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset Count'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkTextSecondary,
                    side: const BorderSide(color: AppColors.borderEmerald),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Total Count Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderEmerald),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.all_inclusive,
                          color: AppColors.primaryGold, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Total: ${appState.tasbeehTotal}',
                        style: const TextStyle(
                          color: AppColors.lightGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // TAB 2: PRAYER TIMES & DISTRICT SELECTOR
  // ==========================================================================
  Widget _buildPrayerTimesTab() {
    final appState = AppStateService();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        PrayerLocation location;
        if (appState.isGpsActive && appState.gpsLocation != null) {
          location = appState.gpsLocation!;
        } else {
          location = PrayerLocationsData.locations.firstWhere(
            (l) => l.id == appState.selectedLocationId,
            orElse: () => PrayerLocationsData.locations.firstWhere(
              (l) => l.id == 'in_mh_sindhudurg',
              orElse: () => PrayerLocationsData.locations.first,
            ),
          );
        }

        final times = PrayerCalculatorService.calculate(
          lat: location.lat,
          lng: location.lng,
          tz: location.tz,
          asrFactor: appState.asrFactor,
        );

        final allLocations = [
          if (appState.gpsLocation != null) appState.gpsLocation!,
          ...PrayerLocationsData.locations,
        ];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // GPS Location Tracking Button
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brightGold),
                          ),
                          SizedBox(width: 12),
                          Expanded(child: Text('Detecting live location via GPS/Network...')),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF0C241C),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  final detected = await GpsLocationService.detectLocation();
                  if (detected != null) {
                    appState.setGpsLocation(detected);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📍 Live GPS Detected: ${detected.name}. Salah times updated!'),
                          backgroundColor: const Color(0xFF133629),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                icon: Icon(
                  appState.isGpsActive ? Icons.my_location_rounded : Icons.gps_fixed_rounded,
                  color: appState.isGpsActive ? AppColors.darkEmerald : AppColors.primaryGold,
                  size: 18,
                ),
                label: Text(
                  appState.isGpsActive
                      ? 'GPS Active: ${location.name.split(',')[0]}'
                      : 'Auto-Track Live Location (GPS)',
                  style: TextStyle(
                    color: appState.isGpsActive ? AppColors.darkEmerald : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appState.isGpsActive ? AppColors.primaryGold : const Color(0xFF061811),
                  side: BorderSide(color: appState.isGpsActive ? AppColors.brightGold : AppColors.borderEmerald),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            // Location Dropdown Picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderEmerald),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: location.id,
                  dropdownColor: AppColors.darkEmerald,
                  icon: const Icon(Icons.location_on, color: AppColors.primaryGold),
                  isExpanded: true,
                  items: allLocations.map((loc) {
                    return DropdownMenuItem(
                      value: loc.id,
                      child: Text(
                        loc.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newId) {
                    if (newId != null) appState.setLocation(newId);
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Fiqh Calculation Switcher (Hanafi vs Shafi'i)
            Row(
              children: [
                Expanded(
                  child: _buildFiqhOption(
                    title: 'Hanafi (Asr Mithlayn)',
                    subtitle: 'Standard Indian Subcontinent',
                    isSelected: appState.asrFactor == 2,
                    onTap: () => appState.setAsrFactor(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFiqhOption(
                    title: "Shafi'i / Maliki / Hanbali",
                    subtitle: 'Single Shadow Length',
                    isSelected: appState.asrFactor == 1,
                    onTap: () => appState.setAsrFactor(1),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Today's Date Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceEmerald,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Astronomical Solar Calculation',
                        style: TextStyle(
                          color: AppColors.lightGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Location: ${location.name}',
                        style: const TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.wb_sunny_rounded,
                      color: AppColors.brightGold, size: 24),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Prayer Times Schedule Cards
            _buildPrayerRow('Fajr (Dawn)', times.fajr, Icons.nightlight_round),
            _buildPrayerRow('Sunrise (Tulu)', times.sunrise, Icons.wb_twilight),
            _buildPrayerRow('Dhuhr (Noon)', times.dhuhr, Icons.wb_sunny),
            _buildPrayerRow(
              'Asr (${appState.asrFactor == 2 ? 'Hanafi' : "Shafi'i"})',
              times.asr,
              Icons.cloud_queue_rounded,
            ),
            _buildPrayerRow('Maghrib (Sunset)', times.maghrib, Icons.wb_twilight),
            _buildPrayerRow('Isha (Night)', times.isha, Icons.nights_stay),
          ],
        );
      },
    );
  }

  Widget _buildFiqhOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.brightGold : AppColors.borderEmerald,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.darkEmerald : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected
                    ? AppColors.darkEmerald.withOpacity(0.8)
                    : AppColors.darkTextMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerRow(String name, String time24, IconData icon) {
    final time12 = PrayerCalculatorService.format12Hour(time24);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderEmerald),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 22),
          const SizedBox(width: 14),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            time12,
            style: const TextStyle(
              color: AppColors.lightGold,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
