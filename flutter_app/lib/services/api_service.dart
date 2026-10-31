import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../models/reel_model.dart';
import '../models/playlist_model.dart';
import '../models/course_model.dart';
import '../models/quote_model.dart';
import '../models/dhikr_model.dart';
import '../models/prayer_location_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/profile')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // ---------------------------------------------------------------------------
  // Videos
  // ---------------------------------------------------------------------------
  Future<List<VideoModel>?> fetchVideos({String? category, bool? featured}) async {
    try {
      String url = '$baseUrl/videos';
      List<String> params = [];
      if (category != null && category != 'all') params.add('category=$category');
      if (featured != null) params.add('featured=$featured');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((j) => VideoModel.fromJson(j)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<bool> createVideo(VideoModel video) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/videos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(video.toJson()),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Reels / Shorts
  // ---------------------------------------------------------------------------
  Future<List<ReelModel>?> fetchReels() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/reels')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((j) => ReelModel.fromJson(j)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<bool> createReel(ReelModel reel) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/reels'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reel.toJson()),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Playlists
  // ---------------------------------------------------------------------------
  Future<List<PlaylistModel>?> fetchPlaylists({String? topic}) async {
    try {
      String url = '$baseUrl/playlists';
      if (topic != null) url += '?topic=${Uri.encodeComponent(topic)}';

      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((j) {
          final List vList = j['videos'] ?? [];
          return PlaylistModel(
            id: j['id'] ?? '',
            title: j['title'] ?? '',
            urduTitle: j['urduTitle'] ?? '',
            category: j['category'] ?? 'namaz',
            topicKey: j['topicKey'] ?? '',
            thumbnail: j['thumbnail'] ?? '',
            description: j['description'] ?? '',
            videos: vList.map((v) => VideoModel.fromJson(v)).toList(),
          );
        }).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<bool> createPlaylist(PlaylistModel playlist) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/playlists'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': playlist.id,
          'title': playlist.title,
          'urduTitle': playlist.urduTitle,
          'category': playlist.category,
          'topicKey': playlist.topicKey,
          'thumbnail': playlist.thumbnail,
          'description': playlist.description,
          'videos': playlist.videos.map((v) => v.toJson()).toList(),
        }),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Courses
  // ---------------------------------------------------------------------------
  Future<List<CourseModel>?> fetchCourses({String? category}) async {
    try {
      String url = '$baseUrl/courses';
      if (category != null && category != 'all') url += '?category=$category';

      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((j) {
          final List lList = j['lessons'] ?? [];
          final List hList = j['highlights'] ?? [];
          return CourseModel(
            id: j['id'] ?? '',
            title: j['title'] ?? '',
            urduTitle: j['urduTitle'] ?? '',
            category: j['category'] ?? 'namaz',
            price: j['price'] ?? 0,
            originalPrice: j['originalPrice'] ?? 0,
            discountPercent: j['discountPercent'] ?? 0,
            duration: j['duration'] ?? '',
            lessonsCount: j['lessonsCount'] ?? 0,
            badge: j['badge'] ?? '',
            instructor: j['instructor'] ?? 'Hafiz Hasnain Jaani',
            rating: (j['rating'] is num) ? (j['rating'] as num).toDouble() : 4.9,
            studentsEnrolled: j['studentsEnrolled'] ?? 0,
            thumbnail: j['thumbnail'] ?? '',
            description: j['description'] ?? '',
            highlights: hList.map((h) => h.toString()).toList(),
            lessons: lList.map((l) => CourseLesson(
              id: l['id'] ?? '',
              title: l['title'] ?? '',
              duration: l['duration'] ?? '',
              youtubeId: l['youtubeId'] ?? '',
              isFreePreview: l['isFreePreview'] ?? false,
              summary: l['summary'] ?? '',
            )).toList(),
          );
        }).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<bool> createCourse(CourseModel course) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/courses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': course.id,
          'title': course.title,
          'urduTitle': course.urduTitle,
          'category': course.category,
          'price': course.price,
          'originalPrice': course.originalPrice,
          'discountPercent': course.discountPercent,
          'duration': course.duration,
          'lessonsCount': course.lessonsCount,
          'badge': course.badge,
          'instructor': course.instructor,
          'rating': course.rating,
          'studentsEnrolled': course.studentsEnrolled,
          'thumbnail': course.thumbnail,
          'description': course.description,
          'highlights': course.highlights,
          'lessons': course.lessons.map((l) => {
            'id': l.id,
            'title': l.title,
            'duration': l.duration,
            'youtubeId': l.youtubeId,
            'isFreePreview': l.isFreePreview,
            'summary': l.summary,
          }).toList(),
        }),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addLessonToCourse(String courseId, CourseLesson lesson) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/courses/$courseId/lessons'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': lesson.id,
          'title': lesson.title,
          'duration': lesson.duration,
          'youtubeId': lesson.youtubeId,
          'isFreePreview': lesson.isFreePreview,
          'summary': lesson.summary,
        }),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Quotes
  // ---------------------------------------------------------------------------
  Future<List<QuoteModel>?> fetchQuotes() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/quotes')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((j) => QuoteModel.fromJson(j)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<bool> createQuote(QuoteModel quote) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/quotes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(quote.toJson()),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Dhikr List
  // ---------------------------------------------------------------------------
  Future<List<DhikrModel>?> fetchDhikrList() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/dhikr')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((j) => DhikrModel.fromJson(j)).toList();
      }
    } catch (_) {}
    return null;
  }

  // ---------------------------------------------------------------------------
  // Prayer Locations
  // ---------------------------------------------------------------------------
  Future<List<PrayerLocation>?> fetchPrayerLocations() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/prayer-locations')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((j) => PrayerLocation(
          id: j['id'] ?? '',
          name: j['name'] ?? '',
          lat: (j['lat'] is num) ? (j['lat'] as num).toDouble() : 0.0,
          lng: (j['lng'] is num) ? (j['lng'] as num).toDouble() : 0.0,
          tz: (j['tz'] is num) ? (j['tz'] as num).toDouble() : 0.0,
          group: j['group'] ?? '',
        )).toList();
      }
    } catch (_) {}
    return null;
  }

  // ---------------------------------------------------------------------------
  // User State Sync
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> fetchUserState() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/user/state')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<void> syncWatchedVideo(String videoId, bool isWatched) async {
    try {
      if (isWatched) {
        await http.post(Uri.parse('$baseUrl/user/watched/$videoId')).timeout(const Duration(seconds: 3));
      } else {
        await http.delete(Uri.parse('$baseUrl/user/watched/$videoId')).timeout(const Duration(seconds: 3));
      }
    } catch (_) {}
  }

  Future<void> syncBookmark(String videoId) async {
    try {
      await http.post(Uri.parse('$baseUrl/user/bookmarks/$videoId')).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> syncSeenShort(String shortId) async {
    try {
      await http.post(Uri.parse('$baseUrl/user/seen-shorts/$shortId')).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> syncLikedShort(String shortId) async {
    try {
      await http.post(Uri.parse('$baseUrl/user/likes/shorts/$shortId')).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> syncTasbeehIncrement() async {
    try {
      await http.post(Uri.parse('$baseUrl/user/tasbeeh/increment')).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> syncTasbeehReset() async {
    try {
      await http.post(Uri.parse('$baseUrl/user/tasbeeh/reset')).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> syncSettings({String? locationId, int? asrFactor, String? dhikrId}) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/user/settings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'selectedLocationId': locationId,
          'asrFactor': asrFactor,
          'currentDhikrId': dhikrId,
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Ask Mas'ala
  // ---------------------------------------------------------------------------
  Future<bool> submitMasala({required String name, required String city, required String question}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/masala'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'city': city,
          'question': question,
        }),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

