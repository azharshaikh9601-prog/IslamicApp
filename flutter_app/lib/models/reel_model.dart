class ReelModel {
  final String id;
  final String youtubeId;
  final String title;
  final String views;
  final String likes;
  final String shares;
  final String category;
  final String format;
  final String duration;
  final String description;
  final bool isLiked;

  const ReelModel({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.views,
    required this.likes,
    required this.shares,
    required this.category,
    this.format = 'short',
    required this.duration,
    required this.description,
    this.isLiked = false,
  });

  String get thumbnailUrl => 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
  String get shortsUrl => 'https://www.youtube.com/shorts/$youtubeId';

  ReelModel copyWith({bool? isLiked}) {
    return ReelModel(
      id: id,
      youtubeId: youtubeId,
      title: title,
      views: views,
      likes: likes,
      shares: shares,
      category: category,
      format: format,
      duration: duration,
      description: description,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'] ?? '',
      youtubeId: json['youtubeId'] ?? '',
      title: json['title'] ?? '',
      views: json['views'] ?? '',
      likes: json['likes']?.toString() ?? '0',
      shares: json['shares']?.toString() ?? '0',
      category: json['category'] ?? 'namaz',
      format: json['format'] ?? 'short',
      duration: json['duration'] ?? '0:55',
      description: json['description'] ?? '',
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'youtubeId': youtubeId,
      'title': title,
      'views': views,
      'likes': likes,
      'shares': shares,
      'category': category,
      'format': format,
      'duration': duration,
      'description': description,
      'isLiked': isLiked,
    };
  }
}
