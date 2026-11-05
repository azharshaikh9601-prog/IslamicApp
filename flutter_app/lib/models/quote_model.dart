class QuoteModel {
  final String id;
  final String category;
  final String arabic;
  final String urdu;
  final String hindi;
  final String english;
  final String reference;
  final String theme;
  final int likes;
  final int shares;
  final int saves;
  final bool isBookmarked;

  const QuoteModel({
    required this.id,
    required this.category,
    required this.arabic,
    required this.urdu,
    this.hindi = '',
    required this.english,
    required this.reference,
    this.theme = 'theme-emerald',
    this.likes = 0,
    this.shares = 0,
    this.saves = 0,
    this.isBookmarked = false,
  });

  QuoteModel copyWith({
    String? category,
    String? arabic,
    String? urdu,
    String? hindi,
    String? english,
    String? reference,
    String? theme,
    int? likes,
    int? shares,
    int? saves,
    bool? isBookmarked,
  }) {
    return QuoteModel(
      id: id,
      category: category ?? this.category,
      arabic: arabic ?? this.arabic,
      urdu: urdu ?? this.urdu,
      hindi: hindi ?? this.hindi,
      english: english ?? this.english,
      reference: reference ?? this.reference,
      theme: theme ?? this.theme,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      saves: saves ?? this.saves,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] ?? '',
      category: json['category'] ?? 'Daily Hadith',
      arabic: json['arabic'] ?? '',
      urdu: json['urdu'] ?? '',
      hindi: json['hindi'] ?? '',
      english: json['english'] ?? '',
      reference: json['reference'] ?? '',
      theme: json['theme'] ?? 'theme-emerald',
      likes: json['likes'] is int ? json['likes'] : int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      shares: json['shares'] is int ? json['shares'] : int.tryParse(json['shares']?.toString() ?? '0') ?? 0,
      saves: json['saves'] is int ? json['saves'] : int.tryParse(json['saves']?.toString() ?? '0') ?? 0,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'arabic': arabic,
      'urdu': urdu,
      'hindi': hindi,
      'english': english,
      'reference': reference,
      'theme': theme,
      'likes': likes,
      'shares': shares,
      'saves': saves,
      'isBookmarked': isBookmarked,
    };
  }
}
