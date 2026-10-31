class DhikrModel {
  final String id;
  final String name;
  final String arabic;
  final String meaning;
  final int target;

  const DhikrModel({
    required this.id,
    required this.name,
    required this.arabic,
    required this.meaning,
    required this.target,
  });

  factory DhikrModel.fromJson(Map<String, dynamic> json) {
    return DhikrModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      arabic: json['arabic'] ?? '',
      meaning: json['meaning'] ?? '',
      target: json['target'] ?? 33,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic': arabic,
      'meaning': meaning,
      'target': target,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
