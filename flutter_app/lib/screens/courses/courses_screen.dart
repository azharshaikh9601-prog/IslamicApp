import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../models/video_model.dart';
import '../../services/storage_service.dart';
import '../../widgets/video_player/in_app_player_modal.dart';
import '../../widgets/auth/auth_modal.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _selectedCategory = 'all';

  void _playLessonInApp(BuildContext context, CourseLesson lesson, CourseModel course, AppStateService appState) {
    if (!appState.isCourseUnlocked(course)) {
      _showEnrollDialog(context, course, appState);
      return;
    }

    final video = VideoModel(
      id: 'course-${lesson.id}',
      youtubeId: lesson.youtubeId,
      title: '${course.title}: ${lesson.title}',
      category: course.category,
      duration: lesson.duration,
      views: 'Course Lesson',
      date: 'Authentic Class',
      description: 'Official course lesson from "${course.title}" by Hafiz Hasnain Jaani.',
      isMasterclass: true,
    );

    InAppPlayerModal.show(
      context,
      video: video,
    );
  }

  void _showEditPriceDialog(BuildContext context, CourseModel course, AppStateService appState) {
    final priceCtrl = TextEditingController(text: course.price.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkEmerald,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.edit_note, color: AppColors.primaryGold),
            SizedBox(width: 8),
            Text(
              'Admin: Set Course Amount',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course: ${course.title}',
              style: const TextStyle(color: AppColors.lightGold, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Course Amount (in â‚¹, 0 for Free)',
                hintText: 'e.g. 499 or 0',
                labelStyle: TextStyle(color: AppColors.lightGold),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newFee = int.tryParse(priceCtrl.text.trim()) ?? course.price;
              await appState.updateCoursePrice(course.id, newFee);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('âœ“ Course amount updated to â‚¹$newFee!'),
                    backgroundColor: AppColors.darkEmerald,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkEmerald,
            ),
            child: const Text('Save Amount', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEnrollDialog(BuildContext context, CourseModel course, AppStateService appState) {
    if (!appState.isLoggedIn) {
      AuthModal.show(context, onSuccess: () {
        _showEnrollDialog(context, course, appState);
      });
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF041E16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.lock_open, color: AppColors.primaryGold),
            SizedBox(width: 8),
            Text(
              'Unlock Full Course',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Instructor: ${course.instructor}',
              style: const TextStyle(color: AppColors.lightGold, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF072B20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderEmerald),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Access Fee:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    'â‚¹${course.price}',
                    style: const TextStyle(color: AppColors.brightGold, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enrolling will unlock all ${course.lessons.length} video classes permanently for account "${appState.currentUser?.username}".',
              style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 11.5, height: 1.3),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final res = await appState.enrollInCourse(course.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message'] ?? 'Course successfully unlocked!'),
                    backgroundColor: res['success'] == true ? AppColors.darkEmerald : Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkEmerald,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Enroll & Pay â‚¹${course.price}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Admin Dialog: Create New Course with custom Fee
  void _showCreateCourseDialog(BuildContext context, AppStateService appState) {
    final titleCtrl = TextEditingController();
    final urduCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '0');
    final descCtrl = TextEditingController();
    final thumbCtrl = TextEditingController();
    String category = 'namaz';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkEmerald,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
          ),
          title: Row(
            children: const [
              Icon(Icons.add_business, color: AppColors.primaryGold),
              SizedBox(width: 8),
              Text(
                'Admin: Create Course',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Course Name (e.g. Fiqh-e-Namaz Course)',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: urduCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Urdu Title (Ø§Ø±Ø¯Ùˆ Ø¹Ù†ÙˆØ§Ù†)',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Course Fee (in â‚¹, enter 0 for Free)',
                    hintText: '0 for Free, or enter custom fee',
                    hintStyle: TextStyle(color: Colors.white38),
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: thumbCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Thumbnail Image URL or YouTube ID',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Course Overview / Description',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: AppColors.darkEmerald,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'namaz', child: Text('Namaz & Prayer')),
                    DropdownMenuItem(value: 'qaida', child: Text('Baghdadi Tajweed & Quran')),
                    DropdownMenuItem(value: 'wudu', child: Text('Taharat, Wuzu & Ghusal')),
                    DropdownMenuItem(value: 'masail', child: Text('Shariat Masail')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;

                final fee = int.tryParse(priceCtrl.text.trim()) ?? 0;
                final thumb = thumbCtrl.text.trim().isEmpty
                    ? 'https://img.youtube.com/vi/gMTvoRUgeXA/hqdefault.jpg'
                    : (thumbCtrl.text.trim().startsWith('http')
                        ? thumbCtrl.text.trim()
                        : 'https://img.youtube.com/vi/${thumbCtrl.text.trim()}/hqdefault.jpg');

                final newCourse = CourseModel(
                  id: 'course-${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  urduTitle: urduCtrl.text.trim().isEmpty ? titleCtrl.text.trim() : urduCtrl.text.trim(),
                  category: category,
                  price: fee,
                  originalPrice: fee,
                  discountPercent: 0,
                  duration: 'Self-paced',
                  lessonsCount: 0,
                  badge: fee == 0 ? 'FREE' : 'COURSE',
                  instructor: 'Hafiz Hasnain Jaani',
                  rating: 5.0,
                  studentsEnrolled: 0,
                  thumbnail: thumb,
                  description: descCtrl.text.trim().isEmpty
                      ? 'Authentic step-by-step Islamic course.'
                      : descCtrl.text.trim(),
                  highlights: ['Authentic Fiqh-e-Hanafi', 'Practical step-by-step classes'],
                  lessons: [],
                );

                appState.addCourse(newCourse);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('âœ“ Course successfully created!'),
                    backgroundColor: AppColors.darkEmerald,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.darkEmerald,
              ),
              child: const Text('Create Course', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Admin Dialog: Add Video Lesson to existing Course
  void _showAddLessonDialog(BuildContext context, CourseModel course, AppStateService appState) {
    final titleCtrl = TextEditingController();
    final ytIdCtrl = TextEditingController();
    final durCtrl = TextEditingController(text: '15:00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkEmerald,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.video_call, color: AppColors.primaryGold),
            SizedBox(width: 8),
            Text(
              'Add Video Lesson',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Course: ${course.title}',
              style: const TextStyle(color: AppColors.lightGold, fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Lesson Title',
                labelStyle: TextStyle(color: AppColors.lightGold),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
              ),
            ),
            TextField(
              controller: ytIdCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'YouTube Video ID or Link',
                hintText: 'e.g. gMTvoRUgeXA',
                hintStyle: TextStyle(color: Colors.white38),
                labelStyle: TextStyle(color: AppColors.lightGold),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
              ),
            ),
            TextField(
              controller: durCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Duration (e.g. 20:15)',
                labelStyle: TextStyle(color: AppColors.lightGold),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty || ytIdCtrl.text.trim().isEmpty) return;

              String ytId = ytIdCtrl.text.trim();
              if (ytId.contains('v=')) {
                ytId = ytId.split('v=')[1].split('&')[0];
              } else if (ytId.contains('youtu.be/')) {
                ytId = ytId.split('youtu.be/')[1].split('?')[0];
              }

              final newLesson = CourseLesson(
                id: 'les-${DateTime.now().millisecondsSinceEpoch}',
                title: titleCtrl.text.trim(),
                duration: durCtrl.text.trim().isEmpty ? '15:00' : durCtrl.text.trim(),
                youtubeId: ytId,
                isFreePreview: true,
                summary: titleCtrl.text.trim(),
              );

              appState.addLessonToCourse(course.id, newLesson);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('âœ“ Lesson successfully added to course!'),
                  backgroundColor: AppColors.darkEmerald,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkEmerald,
            ),
            child: const Text('Add Lesson', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        final courses = appState.courses;
        final filtered = courses.where((c) {
          return _selectedCategory == 'all' || c.category == _selectedCategory;
        }).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // Academy Header Card (Real, without fake certificate badges)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0A2219),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.4),
                  width: 1,
                ),
                gradient: const LinearGradient(
                  colors: [Color(0xFF072A1F), Color(0xFF031610)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACADEMY',
                          style: TextStyle(
                            color: Color(0xFF032B1F),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Authentic Islamic Learning',
                        style: TextStyle(
                          color: AppColors.lightGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Hafiz Hasnain Jaani Masterclasses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Step-by-step practical guides, Namaz classes, and Islamic teachings from Quran and Sunnah.',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildHeaderBadge('${courses.length} Courses Available'),
                      const SizedBox(width: 8),
                      _buildHeaderBadge('Fiqh-e-Hanafi'),
                    ],
                  ),

                  // Admin-Only Course Creation Button (Visible ONLY when isAdmin is true)
                  if (appState.isAdmin) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showCreateCourseDialog(context, appState),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Admin: Create New Course'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.darkEmerald,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Category Filter Chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('all', 'All Courses'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('namaz', 'Namaz Course'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('qaida', 'Baghdadi Tajweed'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('wudu', 'Wudu & Ghusl'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Course Cards in 2-Column Grid (matching Lesson tab)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final course = filtered[index];
                return _build2ColCourseCard(context, course, appState);
              },
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildHeaderBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF133629),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderEmerald),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.lightGold,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String id, String label) {
    final isSelected = _selectedCategory == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : const Color(0xFF0C241C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brightGold : AppColors.borderEmerald,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF032B1F) : AppColors.darkTextSecondary,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _build2ColCourseCard(BuildContext context, CourseModel course, AppStateService appState) {
    final isFree = course.price == 0;
    final isUnlocked = appState.isCourseUnlocked(course);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C241C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderEmerald, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Price & Lesson Badges
            GestureDetector(
              onTap: () => _showCourseLessonsModal(context, course, appState),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      course.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceEmerald,
                        child: const Icon(Icons.school, color: AppColors.primaryGold, size: 36),
                      ),
                    ),
                  ),
                  // Price Badge (Decided by Admin) on top-left
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isFree
                            ? const Color(0xFF10B981)
                            : (isUnlocked ? const Color(0xFF047857) : AppColors.primaryGold),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isFree && !isUnlocked)
                            const Padding(
                              padding: EdgeInsets.only(right: 3),
                              child: Icon(Icons.lock, size: 9, color: Color(0xFF032B1F)),
                            ),
                          Text(
                            isFree
                                ? 'FREE'
                                : (isUnlocked ? '✓ UNLOCKED' : '₹${course.price}'),
                            style: TextStyle(
                              color: isUnlocked && !isFree ? Colors.white : const Color(0xFF032B1F),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Lesson Count on bottom-right
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primaryGold.withOpacity(0.6), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school, color: AppColors.primaryGold, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            '${course.lessons.length} LESSONS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Admin Quick Edit Price Button on top-right
                  if (appState.isAdmin)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () => _showEditPriceDialog(context, course, appState),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.primaryGold, width: 1),
                          ),
                          child: const Icon(Icons.edit, color: AppColors.primaryGold, size: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card Body (Title, Price Info & Action Button)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _showCourseLessonsModal(context, course, appState),
                      child: Text(
                        course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Price Row with Admin edit fee link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isFree ? 'Free Course' : 'Fee: ₹${course.price}',
                          style: TextStyle(
                            color: isFree ? const Color(0xFF34D399) : AppColors.brightGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (appState.isAdmin)
                          InkWell(
                            onTap: () => _showEditPriceDialog(context, course, appState),
                            child: const Text(
                              'Edit Fee',
                              style: TextStyle(
                                color: AppColors.lightGold,
                                fontSize: 10,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Action Button (View Lessons or Enroll)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!isUnlocked && !isFree) {
                            _showEnrollDialog(context, course, appState);
                          } else {
                            _showCourseLessonsModal(context, course, appState);
                          }
                        },
                        icon: Icon(
                          !isUnlocked && !isFree ? Icons.lock_open : Icons.play_circle_fill,
                          size: 13,
                        ),
                        label: Text(
                          !isUnlocked && !isFree ? 'Enroll (₹${course.price})' : 'View Lessons',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !isUnlocked && !isFree
                              ? AppColors.primaryGold
                              : const Color(0xFF0F4C3A),
                          foregroundColor: !isUnlocked && !isFree
                              ? AppColors.darkEmerald
                              : AppColors.brightGold,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: !isUnlocked && !isFree
                                  ? AppColors.primaryGold
                                  : AppColors.borderEmerald,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseLessonsModal(BuildContext context, CourseModel course, AppStateService appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isFree = course.price == 0;
            final isUnlocked = appState.isCourseUnlocked(course);

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF041E16),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                border: Border(
                  top: BorderSide(color: AppColors.primaryGold, width: 1.5),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header with Course Title & Price Badge
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: Image.network(
                              course.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceEmerald,
                                child: const Icon(Icons.school, color: AppColors.primaryGold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                course.urduTitle,
                                style: AppTheme.urduStyle.copyWith(
                                  fontSize: 12.5,
                                  color: AppColors.lightGold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isFree
                                          ? const Color(0xFF10B981)
                                          : (isUnlocked ? const Color(0xFF047857) : AppColors.primaryGold),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isFree
                                          ? 'FREE COURSE'
                                          : (isUnlocked ? '✓ UNLOCKED' : 'FEE: ₹${course.price}'),
                                      style: TextStyle(
                                        color: isUnlocked && !isFree ? Colors.white : const Color(0xFF032B1F),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${course.lessons.length} Lessons',
                                    style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Admin Action Buttons (Set Price & Add Lesson)
                  if (appState.isAdmin)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showEditPriceDialog(context, course, appState);
                              },
                              icon: const Icon(Icons.currency_rupee, size: 14, color: AppColors.primaryGold),
                              label: Text('Set Fee (Current: ₹${course.price})', style: const TextStyle(color: AppColors.lightGold, fontSize: 11)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primaryGold),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showAddLessonDialog(context, course, appState);
                              },
                              icon: const Icon(Icons.add, size: 14),
                              label: const Text('Add Lesson', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: AppColors.darkEmerald,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Divider(color: AppColors.borderEmerald, height: 1),

                  // Lessons List
                  Expanded(
                    child: course.lessons.isEmpty
                        ? const Center(
                            child: Text(
                              'No lessons published yet.',
                              style: TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: course.lessons.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (ctx, idx) {
                              final lesson = course.lessons[idx];
                              return InkWell(
                                onTap: () => _playLessonInApp(context, lesson, course, appState),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF082218),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.borderEmerald.withOpacity(0.6)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isUnlocked ? AppColors.primaryGold.withOpacity(0.15) : Colors.white10,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isUnlocked ? Icons.play_arrow_rounded : Icons.lock_outline,
                                          color: isUnlocked ? AppColors.brightGold : Colors.white38,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lesson.title,
                                              style: TextStyle(
                                                color: isUnlocked ? Colors.white : Colors.white70,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Duration: ${lesson.duration}',
                                              style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 10.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isUnlocked)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                                          ),
                                          child: const Text(
                                            'LOCKED',
                                            style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      else
                                        const Icon(Icons.arrow_forward_ios, color: AppColors.lightGold, size: 12),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom Enroll Banner if locked
                  if (!isUnlocked && !isFree)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF031610),
                        border: Border(top: BorderSide(color: AppColors.borderEmerald)),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showEnrollDialog(context, course, appState);
                          },
                          icon: const Icon(Icons.lock_open, size: 16),
                          label: Text('Enroll & Unlock All Lessons (₹${course.price})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.darkEmerald,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
