class PrayerLocation {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double tz;
  final String group;

  const PrayerLocation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.tz,
    required this.group,
  });

  factory PrayerLocation.fromJson(String id, Map<String, dynamic> json) {
    return PrayerLocation(
      id: id,
      name: json['name'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      tz: (json['tz'] as num).toDouble(),
      group: json['group'] ?? 'General',
    );
  }
}
