import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../models/video_model.dart';
import '../../services/storage_service.dart';
import '../../widgets/video_player/in_app_player_modal.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _selectedCategory = 'all';

  void _playLessonInApp(BuildContext context, CourseLesson lesson, CourseModel course) {
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
                    labelText: 'Urdu Title (اردو عنوان)',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Course Fee (in ₹, enter 0 for Free)',
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
                    content: Text('✓ Course successfully created!'),
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
                  content: Text('✓ Lesson successfully added to course!'),
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
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('+ Admin: Create New Course'),
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

            // Course Cards List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final course = filtered[index];
                return _buildCourseCard(context, course, appState);
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

  Widget _buildCourseCard(BuildContext context, CourseModel course, AppStateService appState) {
    final isFree = course.price == 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderEmerald),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with duration
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    course.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceEmerald,
                      child: const Icon(Icons.school, color: AppColors.primaryGold, size: 40),
                    ),
                  ),
                ),
              ),
              // Fee Badge (FREE or Custom Fee)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFree ? const Color(0xFF10B981) : AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isFree ? 'FREE ACCESS' : '₹${course.price}',
                    style: const TextStyle(
                      color: Color(0xFF032B1F),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              // Lesson Count
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${course.lessons.length} Video Lessons',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  course.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                // Urdu Title
                Text(
                  course.urduTitle,
                  style: AppTheme.urduStyle.copyWith(
                    fontSize: 13,
                    color: AppColors.lightGold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Pricing Row (Real, no fake discounts or fake prices)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isFree ? 'Free for Ummah' : 'Fee: ₹${course.price}',
                      style: TextStyle(
                        color: isFree ? const Color(0xFF34D399) : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Admin add lesson button
                    if (appState.isAdmin)
                      TextButton.icon(
                        onPressed: () => _showAddLessonDialog(context, course, appState),
                        icon: const Icon(Icons.add, size: 14, color: AppColors.primaryGold),
                        label: const Text(
                          '+ Add Lesson',
                          style: TextStyle(color: AppColors.primaryGold, fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),

                // Lessons list with In-App Playback
                if (course.lessons.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(color: AppColors.borderEmerald, height: 1),
                  const SizedBox(height: 8),
                  ...course.lessons.map(
                    (lesson) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        onTap: () => _playLessonInApp(context, lesson, course),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF082218),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderEmerald.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.play_circle_fill, color: AppColors.brightGold, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  lesson.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lesson.duration,
                                style: const TextStyle(color: AppColors.lightGold, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
