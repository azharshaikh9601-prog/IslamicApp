import 'dart:math' as math;

class PrayerTimesResult {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final DateTime calculationDate;

  PrayerTimesResult({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.calculationDate,
  });

  Map<String, String> asMap() {
    return {
      'Fajr': fajr,
      'Sunrise': sunrise,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
  }
}

class PrayerCalculatorService {
  static double _deg2rad(double deg) => deg * math.pi / 180.0;
  static double _rad2deg(double rad) => rad * 180.0 / math.pi;

  /// Astronomical Solar Calculation Engine for Islamic Prayer Times
  /// asrFactor: 2 = Hanafi (default), 1 = Shafi'i / Hanbali / Maliki
  static PrayerTimesResult calculate({
    required double lat,
    required double lng,
    required double tz,
    DateTime? date,
    int asrFactor = 2,
  }) {
    final now = date ?? DateTime.now();
    int y = now.year;
    int m = now.month;
    final int d = now.day;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final int a = (y / 100).floor();
    final int b = 2 - a + (a / 4).floor();
    final double jd = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
    final double dayOffset = jd - 2451545.0;

    final double g = (357.529 + 0.98560028 * dayOffset) % 360;
    final double q = (280.459 + 0.98564736 * dayOffset) % 360;
    final double l = (q +
            1.915 * math.sin(_deg2rad(g)) +
            0.020 * math.sin(_deg2rad(2 * g))) %
        360;
    final double e = 23.439 - 0.00000036 * dayOffset;

    final double sinL = math.sin(_deg2rad(l));
    final double cosL = math.cos(_deg2rad(l));
    final double sinE = math.sin(_deg2rad(e));
    final double cosE = math.cos(_deg2rad(e));

    double ra = (_rad2deg(math.atan2(cosE * sinL, cosL))) % 360;
    if (ra < 0) ra += 360;
    ra = ra / 15.0;

    final double decl = _rad2deg(math.asin(sinE * sinL));

    double eqT = (q / 15.0) - ra;
    if (eqT > 12) eqT -= 24;
    if (eqT < -12) eqT += 24;

    final double noonLocal = 12.0 + tz - (lng / 15.0) - eqT;

    double hourAngle(double alt) {
      final double radLat = _deg2rad(lat);
      final double radDecl = _deg2rad(decl);
      final double radAlt = _deg2rad(alt);
      final double cosH = (math.sin(radAlt) -
              math.sin(radLat) * math.sin(radDecl)) /
          (math.cos(radLat) * math.cos(radDecl));
      if (cosH > 1.0) return 0.0;
      if (cosH < -1.0) return 180.0;
      return _rad2deg(math.acos(cosH));
    }

    // Fajr (-18 deg, Karachi / Ahle Sunnat standard)
    final double hFajr = hourAngle(-18.0);
    final double tFajr = noonLocal - (hFajr / 15.0);

    // Sunrise (-0.833 deg)
    final double hSun = hourAngle(-0.833);
    final double tSunrise = noonLocal - (hSun / 15.0);
    final double tMaghrib = noonLocal + (hSun / 15.0);

    // Isha (-18.0 deg)
    final double hIsha = hourAngle(-18.0);
    final double tIsha = noonLocal + (hIsha / 15.0);

    // Asr (shadow factor: 2 = Hanafi, 1 = Shafi'i)
    final double diff = (lat - decl).abs();
    final double altAsr =
        _rad2deg(math.atan(1.0 / (asrFactor + math.tan(_deg2rad(diff)))));
    final double hAsr = hourAngle(altAsr);
    final double tAsr = noonLocal + (hAsr / 15.0);

    String toTimeStr(double val) {
      val = (val % 24 + 24) % 24;
      int hour = val.floor();
      int min = ((val - hour) * 60).round();
      if (min == 60) {
        hour = (hour + 1) % 24;
        min = 0;
      }
      final hStr = hour < 10 ? '0$hour' : '$hour';
      final mStr = min < 10 ? '0$min' : '$min';
      return '$hStr:$mStr';
    }

    return PrayerTimesResult(
      fajr: toTimeStr(tFajr),
      sunrise: toTimeStr(tSunrise),
      dhuhr: toTimeStr(noonLocal + 0.033), // +2 min precaution
      asr: toTimeStr(tAsr),
      maghrib: toTimeStr(tMaghrib + 0.033), // +2 min precaution
      isha: toTimeStr(tIsha),
      calculationDate: now,
    );
  }

  /// Format 24hr string (e.g., "13:30") to 12hr AM/PM string ("01:30 PM")
  static String format12Hour(String time24) {
    try {
      final parts = time24.split(':');
      int h = int.parse(parts[0]);
      final m = parts[1];
      final period = h >= 12 ? 'PM' : 'AM';
      h = h % 12;
      if (h == 0) h = 12;
      final hStr = h < 10 ? '0$h' : '$h';
      return '$hStr:$m $period';
    } catch (e) {
      return time24;
    }
  }
}
