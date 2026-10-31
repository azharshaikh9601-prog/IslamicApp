class VideoModel {
  final String id;
  final String youtubeId;
  final String title;
  final String category;
  final String format;
  final String duration;
  final String views;
  final String date;
  final bool featured;
  final bool isMasterclass;
  final String description;

  const VideoModel({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.category,
    this.format = 'video',
    required this.duration,
    required this.views,
    required this.date,
    this.featured = false,
    this.isMasterclass = false,
    required this.description,
  });

  String get thumbnailUrl => 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
  String get maxResThumbnailUrl => 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';
  String get videoUrl => 'https://www.youtube.com/watch?v=$youtubeId';

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? '',
      youtubeId: json['youtubeId'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'all',
      format: json['format'] ?? 'video',
      duration: json['duration'] ?? '',
      views: json['views'] ?? '',
      date: json['date'] ?? '',
      featured: json['featured'] ?? false,
      isMasterclass: json['isMasterclass'] ?? false,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'youtubeId': youtubeId,
      'title': title,
      'category': category,
      'format': format,
      'duration': duration,
      'views': views,
      'date': date,
      'featured': featured,
      'isMasterclass': isMasterclass,
      'description': description,
    };
  }
}
