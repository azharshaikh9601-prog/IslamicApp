class CourseLesson {
  final String id;
  final String title;
  final String duration;
  final String youtubeId;
  final bool isFreePreview;
  final String summary;

  const CourseLesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.youtubeId,
    this.isFreePreview = false,
    required this.summary,
  });
}

class CourseModel {
  final String id;
  final String title;
  final String urduTitle;
  final String category;
  final int price;
  final int originalPrice;
  final int discountPercent;
  final String duration;
  final int lessonsCount;
  final String badge;
  final String instructor;
  final double rating;
  final int studentsEnrolled;
  final String thumbnail;
  final String description;
  final List<String> highlights;
  final List<CourseLesson> lessons;

  const CourseModel({
    required this.id,
    required this.title,
    required this.urduTitle,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.discountPercent,
    required this.duration,
    required this.lessonsCount,
    required this.badge,
    required this.instructor,
    required this.rating,
    required this.studentsEnrolled,
    required this.thumbnail,
    required this.description,
    required this.highlights,
    required this.lessons,
  });
}
