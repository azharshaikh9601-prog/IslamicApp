import 'video_model.dart';

class PlaylistModel {
  final String id;
  final String title;
  final String urduTitle;
  final String category;
  final String topicKey;
  final String thumbnail;
  final String description;
  final List<VideoModel> videos;

  const PlaylistModel({
    required this.id,
    required this.title,
    required this.urduTitle,
    required this.category,
    required this.topicKey,
    required this.thumbnail,
    required this.description,
    required this.videos,
  });

  int get videoCount => videos.length;
}

