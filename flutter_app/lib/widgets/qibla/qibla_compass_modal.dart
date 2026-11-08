import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../data/prayer_locations.dart';
import '../../models/prayer_location_model.dart';
import '../../services/storage_service.dart';

class QiblaCalculator {
  static const double makkahLat = 21.422487;
  static const double makkahLng = 39.826206;

  /// Great-circle bearing from user coordinates to Holy Kaaba (0° - 360°)
  static double getQiblaBearing(double lat, double lng) {
    final phi1 = lat * (math.pi / 180.0);
    final phi2 = makkahLat * (math.pi / 180.0);
    final deltaLambda = (makkahLng - lng) * (math.pi / 180.0);

    final y = math.sin(deltaLambda);
    final x = math.cos(phi1) * math.tan(phi2) - math.sin(phi1) * math.cos(deltaLambda);
    final qiblaRad = math.atan2(y, x);
    final qiblaDeg = qiblaRad * (180.0 / math.pi);
    return (qiblaDeg + 360.0) % 360.0;
  }

  /// Great-circle distance to Kaaba in kilometers
  static double getDistanceToMakkah(double lat, double lng) {
    const double r = 6371.0; // Earth radius in km
    final dLat = (makkahLat - lat) * (math.pi / 180.0);
    final dLon = (makkahLng - lng) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat * (math.pi / 180.0)) *
            math.cos(makkahLat * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static String getDirectionCardinal(double deg) {
    if (deg >= 337.5 || deg < 22.5) return 'North (उत्तर)';
    if (deg >= 22.5 && deg < 67.5) return 'Northeast (उत्तर-पूर्व)';
    if (deg >= 67.5 && deg < 112.5) return 'East (पूर्व)';
    if (deg >= 112.5 && deg < 157.5) return 'Southeast (दक्षिण-पूर्व)';
    if (deg >= 157.5 && deg < 202.5) return 'South (दक्षिण)';
    if (deg >= 202.5 && deg < 247.5) return 'Southwest (दक्षिण-पश्चिम)';
    if (deg >= 247.5 && deg < 292.5) return 'West-Northwest (पश्चिम-उत्तर)';
    return 'Northwest (उत्तर-पश्चिम)';
  }
}

class QiblaCompassModal extends StatefulWidget {
  const QiblaCompassModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QiblaCompassModal(),
    );
  }

  @override
  State<QiblaCompassModal> createState() => _QiblaCompassModalState();
}

class _QiblaCompassModalState extends State<QiblaCompassModal> with SingleTickerProviderStateMixin {
  // Current device heading (0° = pointing North, rotates dynamically)
  double _deviceHeading = 0.0;
  Offset _panStart = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();
    final locations = PrayerLocationsData.locations;

    PrayerLocation loc;
    if (appState.isGpsActive && appState.gpsLocation != null) {
      loc = appState.gpsLocation!;
    } else {
      loc = locations.firstWhere(
        (l) => l.id == appState.selectedLocationId,
        orElse: () => locations.firstWhere(
          (l) => l.id == 'in_mh_sindhudurg',
          orElse: () => locations.first,
        ),
      );
    }

    final qiblaBearing = QiblaCalculator.getQiblaBearing(loc.lat, loc.lng);
    final distance = QiblaCalculator.getDistanceToMakkah(loc.lat, loc.lng);
    final cardinal = QiblaCalculator.getDirectionCardinal(qiblaBearing);

    // Relative angle between current phone direction and Kaaba
    final relativeQiblaAngle = (qiblaBearing - _deviceHeading + 360.0) % 360.0;
    final isFacingQibla = relativeQiblaAngle <= 6.0 || relativeQiblaAngle >= 354.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF031C14),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isFacingQibla ? const Color(0xFF10B981) : AppColors.brightGold,
            width: isFacingQibla ? 3 : 2,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Drag Handle
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isFacingQibla
                          ? const Color(0xFF10B981).withOpacity(0.2)
                          : AppColors.primaryGold.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.explore_rounded,
                      color: isFacingQibla ? const Color(0xFF34D399) : AppColors.brightGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Qibla Direction (क़िबला रुख़)',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Rotate device until the 🕋 Kaaba needle points to Phone Front',
                          style: TextStyle(color: AppColors.lightGold, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Location Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF07271B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderEmerald),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primaryGold, size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (appState.isGpsActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                        ),
                        child: const Text('GPS ACTIVE', style: TextStyle(color: Color(0xFF34D399), fontSize: 8.5, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Prominent Alignment Status Banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isFacingQibla
                      ? const Color(0xFF064E3B)
                      : const Color(0xFF1F2937).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isFacingQibla ? const Color(0xFF34D399) : Colors.white24,
                    width: isFacingQibla ? 1.5 : 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFacingQibla ? Icons.check_circle : Icons.screen_rotation,
                      color: isFacingQibla ? const Color(0xFF34D399) : AppColors.primaryGold,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isFacingQibla
                            ? '✓ YOU ARE FACING QIBLA! (काबा के बिल्कुल सामने)'
                            : (relativeQiblaAngle > 180
                                ? 'Rotate phone ${(360 - relativeQiblaAngle).toStringAsFixed(0)}° Left (बाईं ओर घुमाएँ)'
                                : 'Rotate phone ${relativeQiblaAngle.toStringAsFixed(0)}° Right (दाईं ओर घुमाएँ)'),
                        style: TextStyle(
                          color: isFacingQibla ? const Color(0xFF6EE7B7) : Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Top Device Orientation Arrow (12 o'clock pointer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isFacingQibla ? const Color(0xFF10B981) : AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_upward_rounded, size: 13, color: Color(0xFF032B1F)),
                    SizedBox(width: 4),
                    Text(
                      'PHONE FRONT / फ़ोन का मुँह',
                      style: TextStyle(color: Color(0xFF032B1F), fontSize: 9, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Enhanced Interactive Rotating Compass Dial
              GestureDetector(
                onPanStart: (details) {
                  _panStart = details.localPosition;
                },
                onPanUpdate: (details) {
                  final deltaX = details.localPosition.dx - _panStart.dx;
                  setState(() {
                    _deviceHeading = (_deviceHeading + deltaX * 0.4) % 360.0;
                    if (_deviceHeading < 0) _deviceHeading += 360.0;
                    _panStart = details.localPosition;
                  });
                },
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF061811),
                    border: Border.all(
                      color: isFacingQibla ? const Color(0xFF10B981) : AppColors.brightGold,
                      width: isFacingQibla ? 3.5 : 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isFacingQibla ? const Color(0xFF10B981) : AppColors.primaryGold)
                            .withOpacity(0.3),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Compass Dial Face (Rotates relative to device heading)
                      Transform.rotate(
                        angle: -_deviceHeading * (math.pi / 180.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. Degree Ticks around dial
                            ...List.generate(36, (i) {
                              final tickAngle = (i * 10.0) * (math.pi / 180.0);
                              final isMajor = i % 3 == 0;
                              return Transform.rotate(
                                angle: tickAngle,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    width: isMajor ? 2.0 : 1.0,
                                    height: isMajor ? 8 : 4,
                                    color: isMajor ? AppColors.brightGold : Colors.white24,
                                  ),
                                ),
                              );
                            }),

                            // 2. Cardinal Directions (N, S, E, W) with Sub-Cardinals
                            const Positioned(
                              top: 10,
                              child: Text('N', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w900)),
                            ),
                            const Positioned(
                              bottom: 10,
                              child: Text('S', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const Positioned(
                              left: 10,
                              child: Text('W', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const Positioned(
                              right: 10,
                              child: Text('E', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.bold)),
                            ),

                            // Sub-cardinals (NE, SE, SW, NW)
                            ...[
                              {'angle': 45.0, 'label': 'NE'},
                              {'angle': 135.0, 'label': 'SE'},
                              {'angle': 225.0, 'label': 'SW'},
                              {'angle': 315.0, 'label': 'NW'},
                            ].map((dir) {
                              return Transform.rotate(
                                angle: (dir['angle'] as double) * (math.pi / 180.0),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 14),
                                    child: Text(
                                      dir['label'] as String,
                                      style: const TextStyle(color: Colors.white30, fontSize: 8.5, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              );
                            }),

                            // 3. Authentic 3D Magnetic Compass Needle (Red North 'N', Silver South 'S')
                            SizedBox(
                              width: 18,
                              height: 180,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // North Arrow (Red with embossed 'N')
                                  Positioned(
                                    top: 18,
                                    child: CustomPaint(
                                      size: const Size(16, 70),
                                      painter: _CompassNeedleHalfPainter(
                                        isNorth: true,
                                        color: const Color(0xFFDC2626),
                                        highlightColor: const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                  // South Arrow (Silver with embossed 'S')
                                  Positioned(
                                    bottom: 18,
                                    child: CustomPaint(
                                      size: const Size(16, 70),
                                      painter: _CompassNeedleHalfPainter(
                                        isNorth: false,
                                        color: const Color(0xFF475569),
                                        highlightColor: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                  // North tip label 'N'
                                  const Positioned(
                                    top: 22,
                                    child: Text('N', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900)),
                                  ),
                                  // South tip label 'S'
                                  const Positioned(
                                    bottom: 22,
                                    child: Text('S', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900)),
                                  ),
                                ],
                              ),
                            ),

                            // 4. Fixed Outer Rim Kaaba Marker at exact Qibla Bearing (285°)
                            Transform.rotate(
                              angle: qiblaBearing * (math.pi / 180.0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: const BoxDecoration(
                                    color: AppColors.brightGold,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Color(0xFFFFD700), blurRadius: 6),
                                    ],
                                  ),
                                  child: const Text('▲', style: TextStyle(color: Color(0xFF031C14), fontSize: 9)),
                                ),
                              ),
                            ),

                            // 5. Vibrant Golden & Emerald 3D Qibla Needle
                            Transform.rotate(
                              angle: qiblaBearing * (math.pi / 180.0),
                              child: SizedBox(
                                width: 50,
                                height: 210,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Pointer Shaft towards Kaaba
                                    Positioned(
                                      top: 18,
                                      bottom: 105,
                                      child: Container(
                                        width: 5,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              isFacingQibla ? const Color(0xFF34D399) : AppColors.brightGold,
                                              isFacingQibla ? const Color(0xFF10B981) : AppColors.primaryGold,
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(2.5),
                                        ),
                                      ),
                                    ),

                                    // Counter tail
                                    Positioned(
                                      top: 105,
                                      bottom: 45,
                                      child: Container(
                                        width: 3.5,
                                        decoration: BoxDecoration(
                                          color: Colors.white30,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),

                                    // Large, Always-Upright Kaaba Sign 🕋 on the Needle Tip
                                    Positioned(
                                      top: 4,
                                      child: Transform.rotate(
                                        // Counter-rotate so Kaaba stays perfectly upright and easy to see!
                                        angle: -(qiblaBearing - _deviceHeading) * (math.pi / 180.0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF032B1F),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isFacingQibla ? const Color(0xFF34D399) : AppColors.brightGold,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isFacingQibla ? const Color(0xFF10B981) : AppColors.primaryGold)
                                                    .withOpacity(0.7),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Text('🕋', style: TextStyle(fontSize: 14)),
                                              SizedBox(width: 4),
                                              Text(
                                                'QIBLA',
                                                style: TextStyle(
                                                  color: AppColors.brightGold,
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
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
                      ),

                      // Center Hub Pin
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isFacingQibla ? const Color(0xFF10B981) : AppColors.primaryGold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 4),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isFacingQibla ? Icons.check_circle : Icons.navigation,
                            size: 16,
                            color: const Color(0xFF032B1F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Tip: Drag or swipe compass to simulate rotating device heading',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),

              const SizedBox(height: 12),

              // Quick Calibration / Alignment Buttons (Wrap prevents any pixel overflow on all screen sizes)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _deviceHeading = (_deviceHeading - 15 + 360) % 360;
                      });
                    },
                    icon: const Icon(Icons.rotate_left, size: 14, color: AppColors.primaryGold),
                    label: const Text('Turn -15°', style: TextStyle(fontSize: 10.5, color: AppColors.primaryGold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderEmerald),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _deviceHeading = qiblaBearing;
                      });
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF032B1F)),
                    label: const Text('Auto-Align Qibla', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF032B1F))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _deviceHeading = (_deviceHeading + 15) % 360;
                      });
                    },
                    icon: const Icon(Icons.rotate_right, size: 14, color: AppColors.primaryGold),
                    label: const Text('Turn +15°', style: TextStyle(fontSize: 10.5, color: AppColors.primaryGold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderEmerald),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Degree Readout & Cardinal Heading
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF072B1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFacingQibla ? const Color(0xFF10B981) : AppColors.borderEmerald,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('QIBLA BEARING', style: TextStyle(color: AppColors.lightGold, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 3),
                            Text(
                              '${qiblaBearing.toStringAsFixed(1)}°',
                              style: const TextStyle(color: AppColors.brightGold, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(cardinal, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                          ],
                        ),
                        Container(width: 1, height: 44, color: AppColors.borderEmerald),
                        Column(
                          children: [
                            const Text('DISTANCE TO KAABA', style: TextStyle(color: AppColors.lightGold, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 3),
                            Text(
                              '${distance.toStringAsFixed(0)} km',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('Makkah al-Mukarramah', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFF0E3E2D), height: 1),
                    const SizedBox(height: 8),
                    Text(
                      'अपने नमाज़ का मुसल्ला ${qiblaBearing.toStringAsFixed(0)}° $cardinal की दिशा में बिछाएँ।',
                      style: const TextStyle(color: AppColors.lightGold, fontSize: 11.5, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Dismiss Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.darkEmerald,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Done / ठीक है', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom 3D beveled half-needle painter for authentic magnetic North & South compass needle
class _CompassNeedleHalfPainter extends CustomPainter {
  final bool isNorth;
  final Color color;
  final Color highlightColor;

  _CompassNeedleHalfPainter({
    required this.isNorth,
    required this.color,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final midX = width / 2;

    final paintDark = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final paintLight = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    if (isNorth) {
      // Left facet (darker shade)
      final pathLeft = Path()
        ..moveTo(midX, 0)
        ..lineTo(0, height)
        ..lineTo(midX, height * 0.8)
        ..close();
      canvas.drawPath(pathLeft, paintDark);

      // Right facet (lighter highlight)
      final pathRight = Path()
        ..moveTo(midX, 0)
        ..lineTo(width, height)
        ..lineTo(midX, height * 0.8)
        ..close();
      canvas.drawPath(pathRight, paintLight);
    } else {
      // South needle: Left facet (darker shade)
      final pathLeft = Path()
        ..moveTo(midX, height)
        ..lineTo(0, 0)
        ..lineTo(midX, height * 0.2)
        ..close();
      canvas.drawPath(pathLeft, paintDark);

      // South needle: Right facet (lighter highlight)
      final pathRight = Path()
        ..moveTo(midX, height)
        ..lineTo(width, 0)
        ..lineTo(midX, height * 0.2)
        ..close();
      canvas.drawPath(pathRight, paintLight);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

