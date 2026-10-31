class QuoteModel {
  final String id;
  final String category;
  final String arabic;
  final String urdu;
  final String english;
  final String reference;
  final String theme;
  final int likes;
  final bool isBookmarked;

  const QuoteModel({
    required this.id,
    required this.category,
    required this.arabic,
    required this.urdu,
    required this.english,
    required this.reference,
    this.theme = 'theme-emerald',
    this.likes = 0,
    this.isBookmarked = false,
  });

  QuoteModel copyWith({bool? isBookmarked, int? likes}) {
    return QuoteModel(
      id: id,
      category: category,
      arabic: arabic,
      urdu: urdu,
      english: english,
      reference: reference,
      theme: theme,
      likes: likes ?? this.likes,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] ?? '',
      category: json['category'] ?? 'Daily Hadith',
      arabic: json['arabic'] ?? '',
      urdu: json['urdu'] ?? '',
      english: json['english'] ?? '',
      reference: json['reference'] ?? '',
      theme: json['theme'] ?? 'theme-emerald',
      likes: json['likes'] is int ? json['likes'] : int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'arabic': arabic,
      'urdu': urdu,
      'english': english,
      'reference': reference,
      'theme': theme,
      'likes': likes,
      'isBookmarked': isBookmarked,
    };
  }
}
