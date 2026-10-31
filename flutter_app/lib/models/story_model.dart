class StoryModel {
  final String id;
  final String title;
  final String subtitle;
  final String arabic;
  final String message;
  final String category;
  final bool isLive;
  final String image;

  const StoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.arabic = '',
    required this.message,
    required this.category,
    this.isLive = false,
    this.image = '',
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      arabic: json['arabic'] ?? '',
      message: json['message'] ?? '',
      category: json['category'] ?? '',
      isLive: json['isLive'] ?? false,
      image: json['image'] ?? '',
    );
  }
}
