import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../data/prayer_locations.dart';
import '../models/prayer_location_model.dart';
import '../services/prayer_calculator_service.dart';
import '../services/storage_service.dart';
import '../services/gps_location_service.dart';

class SalahScheduleWidget extends StatefulWidget {
  const SalahScheduleWidget({super.key});

  @override
  State<SalahScheduleWidget> createState() => _SalahScheduleWidgetState();
}

class _SalahScheduleWidgetState extends State<SalahScheduleWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _timer;
  String _searchFilter = '';
  bool _isLocatingGps = false;

  @override
  void initState() {
    super.initState();
    // Update countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleGpsTracking(BuildContext context, AppStateService appState) async {
    if (_isLocatingGps) return;
    setState(() => _isLocatingGps = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brightGold),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Tracking live location via GPS/Network...')),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF0C241C),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final detected = await GpsLocationService.detectLocation();
    if (!mounted) return;
    setState(() => _isLocatingGps = false);

    if (detected != null) {
      appState.setGpsLocation(detected);
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.brightGold, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text('📍 Live Location: ${detected.name}\nSalah times calculated for your exact coordinates!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF133629),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Could not detect GPS location. Please select your district from the list.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLocationPicker(
      BuildContext context, AppStateService appState, List<PrayerLocation> list) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkEmerald,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = list.where((loc) {
              final q = query.toLowerCase().trim();
              return q.isEmpty || loc.name.toLowerCase().contains(q);
            }).toList();

            return Container(
              padding: const EdgeInsets.all(16),
              height: 480,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select District or City',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderEmerald),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Search Ratnagiri, Mumbai, Purnia, Delhi...',
                        hintStyle: TextStyle(
                            color: AppColors.darkTextMuted, fontSize: 12),
                        prefixIcon: Icon(Icons.search,
                            color: AppColors.primaryGold, size: 18),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) {
                        setModalState(() => query = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Live GPS Quick Tile
                  InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleGpsTracking(context, appState);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: appState.isGpsActive ? AppColors.primaryGold.withOpacity(0.2) : const Color(0xFF061811),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: appState.isGpsActive ? AppColors.brightGold : AppColors.primaryGold.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location_rounded, color: AppColors.brightGold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Use Live GPS / Current Location',
                                  style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  appState.gpsLocation != null
                                      ? 'Active: ${appState.gpsLocation!.name}'
                                      : 'Auto-detect exact coordinates & calculate Salah times',
                                  style: const TextStyle(color: AppColors.lightGold, fontSize: 10.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryGold, size: 12),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: AppColors.borderEmerald, height: 1),
                      itemBuilder: (context, index) {
                        final loc = filtered[index];
                        final isSelected = loc.id == appState.selectedLocationId;

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          leading: Icon(
                            Icons.location_on,
                            color: isSelected
                                ? AppColors.brightGold
                                : AppColors.darkTextSecondary,
                            size: 18,
                          ),
                          title: Text(
                            loc.name,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.brightGold
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            loc.group,
                            style: const TextStyle(
                              color: AppColors.darkTextMuted,
                              fontSize: 11,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check,
                                  color: AppColors.brightGold, size: 18)
                              : null,
                          onTap: () {
                            appState.setLocation(loc.id);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();
    final locations = PrayerLocationsData.locations;

    // Pick location (matching GPS, selected, Sindhudurg, Ratnagiri, or default)
    PrayerLocation currentLocation;
    if (appState.isGpsActive && appState.gpsLocation != null) {
      currentLocation = appState.gpsLocation!;
    } else {
      currentLocation = locations.firstWhere(
        (l) => l.id == appState.selectedLocationId,
        orElse: () => locations.firstWhere(
          (l) => l.id == 'in_mh_sindhudurg',
          orElse: () => locations.firstWhere(
            (l) => l.id == 'in_mh_ratnagiri',
            orElse: () => locations.first,
          ),
        ),
      );
    }

    // Calculate prayer times
    final times = PrayerCalculatorService.calculate(
      lat: currentLocation.lat,
      lng: currentLocation.lng,
      tz: currentLocation.tz,
      asrFactor: appState.asrFactor,
    );

    final fiqhLabel = appState.asrFactor == 2 ? 'Hanafi' : "Shafi'i";

    // Dynamic Prayer Active & Countdown Calculator
    final now = DateTime.now();
    int activeIndex = 5; // 0=Fajr, 1=Sunrise, 2=Dhuhr, 3=Asr, 4=Maghrib, 5=Isha
    String nextPrayerName = 'Fajr';
    Duration countdownDiff = Duration.zero;

    DateTime parsePrayerTime(String hhmm) {
      final parts = hhmm.split(':');
      return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    }

    final dFajr = parsePrayerTime(times.fajr);
    final dSunrise = parsePrayerTime(times.sunrise);
    final dDhuhr = parsePrayerTime(times.dhuhr);
    final dAsr = parsePrayerTime(times.asr);
    final dMaghrib = parsePrayerTime(times.maghrib);
    final dIsha = parsePrayerTime(times.isha);

    if (now.isBefore(dFajr)) {
      activeIndex = 5; // Isha
      nextPrayerName = 'Fajr';
      countdownDiff = dFajr.difference(now);
    } else if (now.isBefore(dSunrise)) {
      activeIndex = 0; // Fajr
      nextPrayerName = 'Sunrise';
      countdownDiff = dSunrise.difference(now);
    } else if (now.isBefore(dDhuhr)) {
      activeIndex = 1; // Sunrise
      nextPrayerName = 'Dhuhr';
      countdownDiff = dDhuhr.difference(now);
    } else if (now.isBefore(dAsr)) {
      activeIndex = 2; // Dhuhr
      nextPrayerName = 'Asr';
      countdownDiff = dAsr.difference(now);
    } else if (now.isBefore(dMaghrib)) {
      activeIndex = 3; // Asr
      nextPrayerName = 'Maghrib';
      countdownDiff = dMaghrib.difference(now);
    } else if (now.isBefore(dIsha)) {
      activeIndex = 4; // Maghrib
      nextPrayerName = 'Isha';
      countdownDiff = dIsha.difference(now);
    } else {
      activeIndex = 5; // Isha
      nextPrayerName = 'Fajr';
      final tomorrowFajr = dFajr.add(const Duration(days: 1));
      countdownDiff = tomorrowFajr.difference(now);
    }

    final cdHours = countdownDiff.inHours;
    final cdMins = countdownDiff.inMinutes % 60;
    final cdSecs = countdownDiff.inSeconds % 60;
    final locationDisplayName = currentLocation.name;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2219),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Next Prayer Countdown Header (Matches Screenshot)
          Row(
            children: [
              const Text('✦', style: TextStyle(color: AppColors.brightGold, fontSize: 13)),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13),
                    children: [
                      const TextSpan(
                        text: 'Next: ',
                        style: TextStyle(
                          color: AppColors.lightGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '$nextPrayerName ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'in ${cdHours}h ${cdMins}m ${cdSecs}s ',
                        style: const TextStyle(
                          color: AppColors.brightGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '($fiqhLabel)',
                        style: const TextStyle(
                          color: AppColors.darkTextMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Full-Width Location Button (📍 Location Name)
          GestureDetector(
            onTap: () => _showLocationPicker(context, appState, locations),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF061811),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: appState.isGpsActive ? AppColors.brightGold : AppColors.borderEmerald,
                ),
              ),
              child: Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (appState.isGpsActive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                      ),
                      child: const Text(
                        'GPS',
                        style: TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3. Full-Width Search District / State Input Box
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF061811),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderEmerald),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.darkTextMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Search District, State, or Country (Purnia, Bareilly...',
                      hintStyle: TextStyle(
                        color: AppColors.darkTextMuted,
                        fontSize: 11,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      setState(() => _searchFilter = val);
                    },
                  ),
                ),
                if (_searchFilter.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchFilter = '');
                    },
                    child: const Icon(Icons.close, color: Colors.white70, size: 14),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 4. Full-Width Dropdown Selector Button (Location ⌄)
          GestureDetector(
            onTap: () => _showLocationPicker(context, appState, locations),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF061811),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderEmerald),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      locationDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGold, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 5. Controls Row: GPS Button (50%) + Fiqh Toggle (50%)
          Row(
            children: [
              // GPS Button
              Expanded(
                child: GestureDetector(
                  onTap: _isLocatingGps ? null : () => _handleGpsTracking(context, appState),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: appState.isGpsActive
                          ? AppColors.primaryGold.withOpacity(0.2)
                          : const Color(0xFF061811),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: appState.isGpsActive ? AppColors.brightGold : AppColors.borderEmerald,
                        width: appState.isGpsActive ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLocatingGps)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brightGold),
                          )
                        else
                          Icon(
                            Icons.gps_fixed_rounded,
                            color: appState.isGpsActive ? AppColors.brightGold : AppColors.primaryGold,
                            size: 14,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          _isLocatingGps
                              ? 'Locating...'
                              : (appState.isGpsActive ? 'GPS ACTIVE' : 'GPS TRACK'),
                          style: TextStyle(
                            color: appState.isGpsActive ? AppColors.brightGold : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (appState.isGpsActive) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Fiqh Asr Switcher (Hanafi / Shafi'i pill)
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF061811),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderEmerald),
                  ),
                  child: Row(
                    children: [
                      // Hanafi
                      Expanded(
                        child: GestureDetector(
                          onTap: () => appState.setAsrFactor(2),
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: appState.asrFactor == 2
                                  ? AppColors.primaryGold
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Hanafi',
                              style: TextStyle(
                                color: appState.asrFactor == 2
                                    ? const Color(0xFF032B1F)
                                    : AppColors.darkTextSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Shafi'i
                      Expanded(
                        child: GestureDetector(
                          onTap: () => appState.setAsrFactor(1),
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: appState.asrFactor == 1
                                  ? AppColors.primaryGold
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Shafi'i",
                              style: TextStyle(
                                color: appState.asrFactor == 1
                                    ? const Color(0xFF032B1F)
                                    : AppColors.darkTextSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 6. The 3x2 Grid of Prayer Times (Matches Screenshot!)
          Column(
            children: [
              // Top Row: FAJR, SUNRISE, DHUHR
              Row(
                children: [
                  Expanded(
                    child: _buildGridPrayerCard(
                      name: 'FAJR',
                      time24: times.fajr,
                      sublabel: 'Dawn Prayer',
                      isActive: activeIndex == 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildGridPrayerCard(
                      name: 'SUNRISE',
                      time24: times.sunrise,
                      sublabel: 'Tulu-e-Aftab',
                      isActive: activeIndex == 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildGridPrayerCard(
                      name: 'DHUHR',
                      time24: times.dhuhr,
                      sublabel: 'Noon Prayer',
                      isActive: activeIndex == 2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bottom Row: ASR, MAGHRIB, ISHA
              Row(
                children: [
                  Expanded(
                    child: _buildGridPrayerCard(
                      name: 'ASR',
                      time24: times.asr,
                      sublabel: fiqhLabel,
                      isActive: activeIndex == 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildGridPrayerCard(
                      name: 'MAGHRIB',
                      time24: times.maghrib,
                      sublabel: 'Sunset Prayer',
                      isActive: activeIndex == 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildGridPrayerCard(
                      name: 'ISHA',
                      time24: times.isha,
                      sublabel: 'Night Prayer',
                      isActive: activeIndex == 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridPrayerCard({
    required String name,
    required String time24,
    required String sublabel,
    required bool isActive,
  }) {
    final time12 = PrayerCalculatorService.format12Hour(time24);
    final displayTime = time12.startsWith('0') ? time12.substring(1) : time12;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF13362A) : const Color(0xFF0C241C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.brightGold : AppColors.borderEmerald,
              width: isActive ? 1.5 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isActive ? AppColors.brightGold : AppColors.darkTextMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                sublabel,
                style: TextStyle(
                  color: isActive
                      ? AppColors.primaryGold
                      : AppColors.darkTextMuted,
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isActive)
          Positioned(
            top: -7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                'NOW',
                style: TextStyle(
                  color: Color(0xFF032B1F),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
