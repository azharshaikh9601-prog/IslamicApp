class UserModel {
  final String id;
  final String username;
  final String email;
  final bool isAdmin;
  final List<String> enrolledCourseIds;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.isAdmin = false,
    this.enrolledCourseIds = const [],
    required this.createdAt,
    this.lastLoginAt,
  });

  bool hasCourse(String courseId) => enrolledCourseIds.contains(courseId);

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    bool? isAdmin,
    List<String>? enrolledCourseIds,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      enrolledCourseIds: enrolledCourseIds ?? this.enrolledCourseIds,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['isAdmin'] == true,
      enrolledCourseIds: (json['enrolledCourseIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'isAdmin': isAdmin,
      'enrolledCourseIds': enrolledCourseIds,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}
