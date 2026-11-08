import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/prayer_location_model.dart';
import '../data/prayer_locations.dart';

class GpsLocationService {
  /// Detect live location using high-speed network IP Geolocation
  static Future<PrayerLocation?> detectLocation() async {
    // 1. Try ip-api.com
    try {
      final res = await http
          .get(Uri.parse('http://ip-api.com/json'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final double lat = (data['lat'] as num).toDouble();
          final double lng = (data['lon'] as num).toDouble();
          final String city = (data['city'] as String? ?? '').trim();
          final String region = (data['regionName'] as String? ?? '').trim();
          final String country = (data['country'] as String? ?? 'India').trim();

          return _resolveLocation(lat, lng, city, region, country, data['timezone'] as String?);
        }
      }
    } catch (_) {}

    // 2. Fallback to ipapi.co
    try {
      final res = await http
          .get(Uri.parse('https://ipapi.co/json'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final double lat = (data['latitude'] as num).toDouble();
        final double lng = (data['longitude'] as num).toDouble();
        final String city = (data['city'] as String? ?? '').trim();
        final String region = (data['region'] as String? ?? '').trim();
        final String country = (data['country_name'] as String? ?? 'India').trim();

        return _resolveLocation(lat, lng, city, region, country, data['timezone'] as String?);
      }
    } catch (_) {}

    return null;
  }

  static PrayerLocation _resolveLocation(
    double lat,
    double lng,
    String city,
    String region,
    String country,
    String? timezoneStr,
  ) {
    final lowerCity = city.toLowerCase();
    final lowerRegion = region.toLowerCase();

    // Calibration for Sindhudurg / South Konkan:
    // Telecom ISPs (Jio/Airtel) in Sindhudurg connect to gateways in Mapusa/Goa or Ratnagiri (~60-100km).
    // When detected in this corridor, accurately map to exact Sindhudurg coordinates!
    if (lowerCity.contains('sindhudurg') ||
        lowerCity.contains('malvan') ||
        lowerCity.contains('sawantwadi') ||
        lowerCity.contains('kudal') ||
        lowerCity.contains('kankavli') ||
        lowerCity.contains('vengurla') ||
        lowerCity.contains('mapusa') ||
        lowerCity.contains('panaji') ||
        lowerCity.contains('goa') ||
        lowerRegion.contains('goa') ||
        (lat >= 15.3 && lat <= 16.5 && lng >= 73.0 && lng <= 74.5)) {
      return PrayerLocationsData.locations.firstWhere(
        (l) => l.id == 'in_mh_sindhudurg',
        orElse: () => const PrayerLocation(
          id: 'in_mh_sindhudurg',
          name: 'Sindhudurg, Maharashtra',
          lat: 16.1264,
          lng: 73.7125,
          tz: 5.5,
          group: '🇮🇳 Maharashtra Districts',
        ),
      );
    }

    // Check if there is an exact or near match in pre-defined districts (< 35km)
    final matched = findNearestPredefined(lat, lng, maxDistanceKm: 35);
    if (matched != null) {
      return matched;
    }

    final tzOffset = _calculateTimezoneOffset(lng, timezoneStr);

    return PrayerLocation(
      id: 'gps_live',
      name: '${city.isNotEmpty ? city : region}, $country',
      lat: lat,
      lng: lng,
      tz: tzOffset,
      group: '📍 Live GPS Detected',
    );
  }

  /// Calculates timezone offset in hours
  static double _calculateTimezoneOffset(double lng, String? timezoneStr) {
    if (timezoneStr != null && timezoneStr.contains('Kolkata')) {
      return 5.5; // Standard Indian Time
    }
    return (lng / 15.0).roundToDouble();
  }

  /// Finds the closest pre-defined location within [maxDistanceKm]
  static PrayerLocation? findNearestPredefined(double lat, double lng, {double maxDistanceKm = 35}) {
    PrayerLocation? bestMatch;
    double minKm = double.infinity;

    for (final loc in PrayerLocationsData.locations) {
      final d = _haversineDistance(lat, lng, loc.lat, loc.lng);
      if (d < minKm) {
        minKm = d;
        bestMatch = loc;
      }
    }

    if (minKm <= maxDistanceKm) {
      return bestMatch;
    }
    return null;
  }

  /// Haversine formula to compute distance in kilometers
  static double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }
}
