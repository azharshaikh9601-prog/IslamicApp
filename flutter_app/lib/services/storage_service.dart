import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/video_model.dart';
import '../models/reel_model.dart';
import '../models/quote_model.dart';
import '../models/dhikr_model.dart';
import '../models/playlist_model.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';
import '../data/initial_data.dart';
import 'api_service.dart';

class AppStateService extends ChangeNotifier {
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal() {
    _restoreUserSession();
    loadFromBackend();
  }

  final ApiService _api = ApiService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ---------------------------------------------------------------------------
  // User Authentication & Profile
  // ---------------------------------------------------------------------------
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Admin Mode (Strictly false by default for guests; true only when logged in as Admin)
  bool _isAdmin = false;
  bool get isAdmin => _currentUser != null ? _currentUser!.isAdmin : _isAdmin;

  void setAdminMode(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  File _getSessionFile() {
    return File('user_session.json');
  }

  Future<void> _restoreUserSession() async {
    try {
      final file = _getSessionFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        _currentUser = UserModel.fromJson(json);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveUserSession() async {
    try {
      final file = _getSessionFile();
      if (_currentUser != null) {
        await file.writeAsString(jsonEncode(_currentUser!.toJson()));
      } else {
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await _api.register(
      username: username,
      email: email,
      password: password,
    );
    if (res['success'] == true && res['user'] != null) {
      _currentUser = UserModel.fromJson(res['user']);
      await _saveUserSession();
      notifyListeners();
    }
    return res;
  }

  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final res = await _api.login(
      emailOrUsername: emailOrUsername,
      password: password,
    );
    if (res['success'] == true && res['user'] != null) {
      _currentUser = UserModel.fromJson(res['user']);
      await _saveUserSession();
      notifyListeners();
    }
    return res;
  }

  void signOut() async {
    _currentUser = null;
    _isAdmin = false;
    await _saveUserSession();
    notifyListeners();
  }

  // Admin user list for dashboard
  List<UserModel> _adminUsers = [];
  List<UserModel> get adminUsers => _adminUsers;

  Future<void> loadAdminUsers() async {
    final users = await _api.fetchAdminUsers();
    if (users.isNotEmpty) {
      _adminUsers = users;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Course Unlocking & Pricing
  // ---------------------------------------------------------------------------
  bool isCourseUnlocked(CourseModel course) {
    if (course.price == 0) return true; // Free course
    if (isAdmin) return true; // Admin has full access
    if (_currentUser != null && _currentUser!.enrolledCourseIds.contains(course.id)) {
      return true; // Enrolled / Paid
    }
    return false;
  }

  Future<bool> updateCoursePrice(String courseId, int newPrice) async {
    final idx = _courses.indexWhere((c) => c.id == courseId);
    if (idx >= 0) {
      final old = _courses[idx];
      _courses[idx] = CourseModel(
        id: old.id,
        title: old.title,
        urduTitle: old.urduTitle,
        category: old.category,
        price: newPrice,
        originalPrice: old.originalPrice,
        discountPercent: old.discountPercent,
        duration: old.duration,
        lessonsCount: old.lessonsCount,
        badge: newPrice == 0 ? 'FREE' : 'COURSE',
        instructor: old.instructor,
        rating: old.rating,
        studentsEnrolled: old.studentsEnrolled,
        thumbnail: old.thumbnail,
        description: old.description,
        highlights: old.highlights,
        lessons: old.lessons,
      );
      notifyListeners();
      return await _api.updateCoursePrice(courseId, price: newPrice);
    }
    return false;
  }

  Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'Please sign in or create an account to enroll.'};
    }

    final res = await _api.enrollInCourse(courseId, _currentUser!.id);
    if (res != null && res['success'] == true) {
      final updatedEnrolled = List<String>.from(_currentUser!.enrolledCourseIds);
      if (!updatedEnrolled.contains(courseId)) {
        updatedEnrolled.add(courseId);
      }
      _currentUser = _currentUser!.copyWith(enrolledCourseIds: updatedEnrolled);
      await _saveUserSession();
      notifyListeners();
      return {'success': true, 'message': 'Course unlocked successfully!'};
    }
    return {'success': false, 'message': res?['message'] ?? 'Enrollment failed.'};
  }

  // Playlists (Initialized with InitialData fallback so UI never shows empty while loading)
  List<PlaylistModel> _playlists = List.from(InitialData.playlists);
  List<PlaylistModel> get playlists => _playlists;

  Future<void> addPlaylist(PlaylistModel playlist) async {
    _playlists.insert(0, playlist);
    notifyListeners();
    await _api.createPlaylist(playlist);
  }

  Future<void> updatePlaylist(PlaylistModel playlist) async {
    final idx = _playlists.indexWhere((p) => p.id == playlist.id);
    if (idx >= 0) {
      _playlists[idx] = playlist;
      notifyListeners();
      await _api.updatePlaylist(playlist);
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  // Courses (Initialized with InitialData fallback)
  List<CourseModel> _courses = List.from(InitialData.courses);
  List<CourseModel> get courses => _courses;

  Future<void> addCourse(CourseModel course) async {
    _courses.insert(0, course);
    notifyListeners();
    await _api.createCourse(course);
  }

  Future<void> addLessonToCourse(String courseId, CourseLesson lesson) async {
    final idx = _courses.indexWhere((c) => c.id == courseId);
    if (idx >= 0) {
      final updatedLessons = List<CourseLesson>.from(_courses[idx].lessons)..add(lesson);
      _courses[idx] = CourseModel(
        id: _courses[idx].id,
        title: _courses[idx].title,
        urduTitle: _courses[idx].urduTitle,
        category: _courses[idx].category,
        price: _courses[idx].price,
        originalPrice: _courses[idx].originalPrice,
        discountPercent: _courses[idx].discountPercent,
        duration: _courses[idx].duration,
        lessonsCount: updatedLessons.length,
        badge: _courses[idx].badge,
        instructor: _courses[idx].instructor,
        rating: _courses[idx].rating,
        studentsEnrolled: _courses[idx].studentsEnrolled,
        thumbnail: _courses[idx].thumbnail,
        description: _courses[idx].description,
        highlights: _courses[idx].highlights,
        lessons: updatedLessons,
      );
      notifyListeners();
      await _api.addLessonToCourse(courseId, lesson);
    }
  }

  // Topic Navigation Filters
  String? _selectedTopicFilter;
  String? _selectedPlaylistId;

  String? get selectedTopicFilter => _selectedTopicFilter;
  String? get selectedPlaylistId => _selectedPlaylistId;

  void selectTopic(String? topic, {String? playlistId}) {
    _selectedTopicFilter = topic;
    _selectedPlaylistId = playlistId;
    notifyListeners();
  }

  void selectPlaylist(String? playlistId) {
    _selectedPlaylistId = playlistId;
    notifyListeners();
  }

  void clearTopicSelection() {
    _selectedTopicFilter = null;
    _selectedPlaylistId = null;
    notifyListeners();
  }

  // Videos (Initialized with InitialData fallback)
  List<VideoModel> _videos = List.from(InitialData.videos);
  List<VideoModel> get videos => _videos;

  Future<void> addVideo(VideoModel video) async {
    _videos.insert(0, video);
    notifyListeners();
    await _api.createVideo(video);
  }

  // Watched Videos
  final Set<String> _watchedVideoIds = {'vid-IaJcljFpgBc'};
  Set<String> get watchedVideoIds => _watchedVideoIds;

  bool isVideoWatched(String id) => _watchedVideoIds.contains(id);

  void markVideoWatched(String id) {
    if (!_watchedVideoIds.contains(id)) {
      _watchedVideoIds.add(id);
      notifyListeners();
      _api.syncWatchedVideo(id, true);
    }
  }

  void toggleVideoWatched(String id) {
    if (_watchedVideoIds.contains(id)) {
      _watchedVideoIds.remove(id);
      _api.syncWatchedVideo(id, false);
    } else {
      _watchedVideoIds.add(id);
      _api.syncWatchedVideo(id, true);
    }
    notifyListeners();
  }

  // Reels / Shorts (Initialized with InitialData fallback so shorts are NEVER missing)
  List<ReelModel> _reels = List.from(InitialData.reels);
  List<ReelModel> get reels => _reels;

  String? _activeReelId;
  String? get activeReelId => _activeReelId;

  void setActiveReel(String? id) {
    _activeReelId = id;
    notifyListeners();
  }

  Future<void> addReel(ReelModel reel) async {
    _reels.insert(0, reel);
    notifyListeners();
    await _api.createReel(reel);
  }

  // Seen Shorts
  final Set<String> _seenShortIds = {};
  Set<String> get seenShortIds => _seenShortIds;

  bool isShortSeen(String id) => _seenShortIds.contains(id);

  void markShortSeen(String id) {
    if (!_seenShortIds.contains(id)) {
      _seenShortIds.add(id);
      notifyListeners();
      _api.syncSeenShort(id);
    }
  }

  List<ReelModel> get freshReels {
    if (_reels.isEmpty) return [];
    final unseen = _reels.where((r) => !_seenShortIds.contains(r.id)).toList();
    final seen = _reels.where((r) => _seenShortIds.contains(r.id)).toList();
    return [...unseen, ...seen];
  }

  // Quotes (Initialized with InitialData fallback)
  List<QuoteModel> _quotes = List.from(InitialData.quotes);
  List<QuoteModel> get quotes => _quotes;

  Future<void> addQuote(QuoteModel quote) async {
    _quotes.insert(0, quote);
    notifyListeners();
    await _api.createQuote(quote);
  }

  // Bookmarks
  final Set<String> _bookmarkedVideoIds = {};
  Set<String> get bookmarkedVideoIds => _bookmarkedVideoIds;

  void toggleBookmark(String videoId) {
    if (_bookmarkedVideoIds.contains(videoId)) {
      _bookmarkedVideoIds.remove(videoId);
    } else {
      _bookmarkedVideoIds.add(videoId);
    }
    notifyListeners();
    _api.syncBookmark(videoId);
  }

  bool isBookmarked(String videoId) => _bookmarkedVideoIds.contains(videoId);

  // Likes on Shorts
  final Set<String> _likedShortsIds = {};
  Set<String> get likedShortsIds => _likedShortsIds;

  void toggleLikeShort(String shortId) {
    if (_likedShortsIds.contains(shortId)) {
      _likedShortsIds.remove(shortId);
    } else {
      _likedShortsIds.add(shortId);
    }
    notifyListeners();
    _api.syncLikedShort(shortId);
  }

  bool isShortLiked(String shortId) => _likedShortsIds.contains(shortId);

  // Dhikr List
  List<DhikrModel> _dhikrList = List.from(InitialData.dhikrList);
  List<DhikrModel> get dhikrList => _dhikrList;

  // Tasbeeh State
  int _tasbeehCount = 0;
  int _tasbeehTotal = 1420;
  DhikrModel get currentDhikr => _dhikrList.isNotEmpty ? _dhikrList[0] : InitialData.dhikrList[0];

  int get tasbeehCount => _tasbeehCount;
  int get tasbeehTotal => _tasbeehTotal;

  void incrementTasbeeh() {
    _tasbeehCount++;
    _tasbeehTotal++;
    if (_tasbeehCount >= currentDhikr.target) {
      _tasbeehCount = 0;
    }
    notifyListeners();
    _api.syncTasbeehIncrement();
  }

  void resetTasbeeh() {
    _tasbeehCount = 0;
    notifyListeners();
    _api.syncTasbeehReset();
  }

  void selectDhikr(DhikrModel dhikr) {
    final idx = _dhikrList.indexWhere((d) => d.id == dhikr.id);
    if (idx > 0) {
      _dhikrList.removeAt(idx);
      _dhikrList.insert(0, dhikr);
    }
    _tasbeehCount = 0;
    notifyListeners();
    _api.syncSettings(dhikrId: dhikr.id);
  }

  // Location & Fiqh
  String _selectedLocationId = 'in_mh_ratnagiri';
  int _asrFactor = 2; // 2 = Hanafi, 1 = Shafi'i

  String get selectedLocationId => _selectedLocationId;
  int get asrFactor => _asrFactor;

  void setLocation(String locationId) {
    _selectedLocationId = locationId;
    notifyListeners();
    _api.syncSettings(locationId: locationId);
  }

  void setAsrFactor(int factor) {
    _asrFactor = factor;
    notifyListeners();
    _api.syncSettings(asrFactor: factor);
  }

  // ---------------------------------------------------------------------------
  // Load All Data from .NET 10 Backend
  // ---------------------------------------------------------------------------
  Future<void> loadFromBackend() async {
    _isLoading = true;
    notifyListeners();

    try {
      final v = await _api.fetchVideos();
      if (v != null && v.isNotEmpty) _videos = v;

      final p = await _api.fetchPlaylists();
      if (p != null && p.isNotEmpty) _playlists = p;

      final r = await _api.fetchReels();
      if (r != null && r.isNotEmpty) _reels = r;

      final c = await _api.fetchCourses();
      if (c != null && c.isNotEmpty) _courses = c;

      final q = await _api.fetchQuotes();
      if (q != null && q.isNotEmpty) _quotes = q;

      final d = await _api.fetchDhikrList();
      if (d != null && d.isNotEmpty) _dhikrList = d;

      final state = await _api.fetchUserState();
      if (state != null) {
        if (state['watchedVideoIds'] is List) {
          _watchedVideoIds.addAll(List<String>.from(state['watchedVideoIds']));
        }
        if (state['bookmarkedVideoIds'] is List) {
          _bookmarkedVideoIds.addAll(List<String>.from(state['bookmarkedVideoIds']));
        }
        if (state['likedShortIds'] is List) {
          _likedShortsIds.addAll(List<String>.from(state['likedShortIds']));
        }
        if (state['seenShortIds'] is List) {
          _seenShortIds.addAll(List<String>.from(state['seenShortIds']));
        }
        if (state['tasbeehCount'] is int) _tasbeehCount = state['tasbeehCount'];
        if (state['tasbeehTotal'] is int) _tasbeehTotal = state['tasbeehTotal'];
        if (state['selectedLocationId'] is String) _selectedLocationId = state['selectedLocationId'];
        if (state['asrFactor'] is int) _asrFactor = state['asrFactor'];
      }

      await loadAdminUsers();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
