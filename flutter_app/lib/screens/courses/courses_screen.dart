import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../models/video_model.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';
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

    int selectedPaymentMethod = 0; // 0: UPI & QR, 1: Card / NetBanking, 2: 1-Tap Test Checkout
    final utrCtrl = TextEditingController();
    bool isProcessing = false;
    String verificationStatus = 'Connecting to Verification Gateway...';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Color(0xFF041E16),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_user, color: AppColors.primaryGold, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Secure Course Enrollment',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Official Hafiz Hasnain Jaani Islamic Academy',
                              style: TextStyle(color: AppColors.lightGold, fontSize: 11),
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

                const Divider(color: AppColors.borderEmerald, height: 1),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      // Course Summary Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF072B20),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderEmerald),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 80,
                                height: 55,
                                child: Image.network(
                                  course.thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.black26),
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
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${course.lessons.length} Exclusive Lessons • Lifetime Access',
                                    style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 10.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Payable Fee: ₹${course.price}',
                                    style: const TextStyle(color: AppColors.brightGold, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Select Payment Method:',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Payment Method Selector Tabs
                      Row(
                        children: [
                          Expanded(
                            child: _buildPayMethodTab(
                              title: 'UPI / QR',
                              icon: Icons.qr_code_scanner,
                              isSelected: selectedPaymentMethod == 0,
                              onTap: () => setSheetState(() => selectedPaymentMethod = 0),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPayMethodTab(
                              title: 'Cards & NetBanking',
                              icon: Icons.credit_card,
                              isSelected: selectedPaymentMethod == 1,
                              onTap: () => setSheetState(() => selectedPaymentMethod = 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPayMethodTab(
                              title: 'Test / Instant',
                              icon: Icons.flash_on,
                              isSelected: selectedPaymentMethod == 2,
                              onTap: () => setSheetState(() => selectedPaymentMethod = 2),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Method 0: UPI & QR
                      if (selectedPaymentMethod == 0) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF031610),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Simulated QR Code Icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.qr_code_2, color: Colors.black, size: 48),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Scan & Pay via any UPI App', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        const Text('GPay, PhonePe, Paytm, BHIM, Cred', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 10)),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Expanded(
                                              child: Text(
                                                'UPI ID: hafizhasnainjaani@okaxis',
                                                style: TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () {
                                                Clipboard.setData(const ClipboardData(text: 'hafizhasnainjaani@okaxis'));
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UPI ID copied to clipboard!')));
                                              },
                                              child: const Icon(Icons.copy, size: 12, color: AppColors.primaryGold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: AppColors.borderEmerald, height: 1),
                              const SizedBox(height: 12),
                              // UTR Verification Input
                              TextField(
                                controller: utrCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  labelText: 'Enter 12-Digit UPI Reference / UTR No.*',
                                  hintText: 'e.g. 430987654321',
                                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                                  labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 11),
                                  helperText: 'System verifies transaction with banking gateway to unlock immediately',
                                  helperStyle: const TextStyle(color: AppColors.lightGold, fontSize: 9.5),
                                  prefixIcon: const Icon(Icons.receipt_long, color: AppColors.primaryGold, size: 18),
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFF07241A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderEmerald)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderEmerald)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryGold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Method 1: Cards & NetBanking
                      if (selectedPaymentMethod == 1) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF031610),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderEmerald),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              TextField(
                                style: TextStyle(color: Colors.white, fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: 'Card Number',
                                  hintText: '4111 •••• •••• 1111',
                                  hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                                  labelStyle: TextStyle(color: AppColors.lightGold, fontSize: 11),
                                  prefixIcon: Icon(Icons.credit_card, color: AppColors.primaryGold, size: 16),
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'Expiry (MM/YY)',
                                        hintText: '12/28',
                                        hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                                        labelStyle: TextStyle(color: AppColors.lightGold, fontSize: 11),
                                        isDense: true,
                                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      obscureText: true,
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'CVV',
                                        hintText: '•••',
                                        hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                                        labelStyle: TextStyle(color: AppColors.lightGold, fontSize: 11),
                                        isDense: true,
                                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Method 2: Test / Instant Checkout
                      if (selectedPaymentMethod == 2) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF031610),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Row(
                                children: [
                                  Icon(Icons.bolt, color: Colors.tealAccent, size: 18),
                                  SizedBox(width: 6),
                                  Text('Instant Auto-Verification Mode', style: TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Enables instant one-tap simulated payment verification. Immediately updates database records and automatically opens the full course.',
                                style: TextStyle(color: AppColors.darkTextMuted, fontSize: 11, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (isProcessing) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF082B1E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryGold),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primaryGold),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  verificationStatus,
                                  style: const TextStyle(color: AppColors.lightGold, fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Verify & Unlock Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  if (selectedPaymentMethod == 0 && utrCtrl.text.trim().length < 8) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter your 12-digit UPI Reference / UTR number from your payment app.'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  setSheetState(() {
                                    isProcessing = true;
                                    verificationStatus = 'Step 1: Connecting to UPI Banking Gateway...';
                                  });
                                  await Future.delayed(const Duration(milliseconds: 700));

                                  setSheetState(() {
                                    verificationStatus = 'Step 2: Checking transaction receipt for ₹${course.price}...';
                                  });
                                  await Future.delayed(const Duration(milliseconds: 800));

                                  setSheetState(() {
                                    verificationStatus = 'Step 3: Payment verified! Unlocking all lessons...';
                                  });
                                  await Future.delayed(const Duration(milliseconds: 600));

                                  final res = await appState.enrollInCourse(course.id);
                                  if (!context.mounted) return;
                                  Navigator.pop(ctx); // Close checkout sheet

                                  if (res['success'] == true) {
                                    // AUTOMATICALLY OPEN THE COURSE!
                                    _showPaymentSuccessAndOpenCourse(context, course, appState);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(res['message'] ?? 'Enrollment failed.'), backgroundColor: Colors.redAccent),
                                    );
                                  }
                                },
                          icon: isProcessing
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkEmerald))
                              : const Icon(Icons.verified, size: 18),
                          label: Text(
                            isProcessing ? 'Verifying...' : 'Verify Payment & Unlock Course (₹${course.price})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.darkEmerald,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Automatic Course Opening on Successful Payment
  void _showPaymentSuccessAndOpenCourse(BuildContext context, CourseModel course, AppStateService appState) {
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
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 10),
            Text('Payment Successful!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alhamdulillah! Course "${course.title}" has been permanently unlocked for your account.',
              style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.3),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF082218),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderEmerald),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transaction Ref:', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 11)),
                  Text('TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                      style: const TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showCourseLessonsModal(context, course, appState);
            },
            child: const Text('Browse Lessons', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              if (course.lessons.isNotEmpty) {
                _playLessonInApp(context, course.lessons.first, course, appState);
              } else {
                _showCourseLessonsModal(context, course, appState);
              }
            },
            icon: const Icon(Icons.play_circle_fill, size: 16),
            label: const Text('Start Watching Now', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkEmerald,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayMethodTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : const Color(0xFF031610),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.brightGold : AppColors.borderEmerald),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF032B1F) : AppColors.lightGold),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF032B1F) : Colors.white70,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Dialog: Create New Course with custom Fee and Device Video Upload
  void _showCreateCourseDialog(BuildContext context, AppStateService appState) {
    final titleCtrl = TextEditingController();
    final urduCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '0');
    final descCtrl = TextEditingController();
    final thumbCtrl = TextEditingController();
    String category = 'namaz';
    String? selectedVideoPath;
    bool isUploading = false;
    String uploadStatus = '';

    showDialog(
      context: context,
      barrierDismissible: !isUploading,
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
                'Create New Course',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    labelText: 'Thumbnail Image URL (Optional)',
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
                const SizedBox(height: 16),

                // Upload Video Option for the Course (Select from Device)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C241C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.video_library, color: AppColors.primaryGold, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Course Video (Upload from Device)',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Select a private video from your device (In-App only, not on YouTube).',
                        style: TextStyle(color: AppColors.darkTextMuted, fontSize: 10.5),
                      ),
                      const SizedBox(height: 10),
                      if (selectedVideoPath == null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final picked = await _pickVideoFile();
                              if (picked != null) {
                                setDialogState(() {
                                  selectedVideoPath = picked;
                                });
                              }
                            },
                            icon: const Icon(Icons.drive_folder_upload, size: 16),
                            label: const Text('Select Video from Device'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF133629),
                              foregroundColor: AppColors.primaryGold,
                              side: const BorderSide(color: AppColors.borderEmerald),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF133629),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryGold),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedVideoPath!.split(Platform.pathSeparator).last,
                                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'File ready (${(File(selectedVideoPath!).lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB)',
                                      style: const TextStyle(color: AppColors.lightGold, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                                onPressed: () => setDialogState(() => selectedVideoPath = null),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                if (isUploading) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGold),
                      ),
                      const SizedBox(width: 10),
                      Text(uploadStatus, style: const TextStyle(color: AppColors.lightGold, fontSize: 11)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (titleCtrl.text.trim().isEmpty) return;

                      final fee = int.tryParse(priceCtrl.text.trim()) ?? 0;
                      final thumb = thumbCtrl.text.trim().isEmpty
                          ? 'https://img.youtube.com/vi/gMTvoRUgeXA/hqdefault.jpg'
                          : (thumbCtrl.text.trim().startsWith('http')
                              ? thumbCtrl.text.trim()
                              : 'https://img.youtube.com/vi/${thumbCtrl.text.trim()}/hqdefault.jpg');

                      List<CourseLesson> initialLessons = [];

                      // If admin selected a video from device, upload it now
                      if (selectedVideoPath != null) {
                        setDialogState(() {
                          isUploading = true;
                          uploadStatus = 'Uploading device video to app storage...';
                        });

                        final uploadedPath = await ApiService().uploadCourseVideo(selectedVideoPath!);
                        final videoReference = uploadedPath ?? selectedVideoPath!;

                        initialLessons.add(
                          CourseLesson(
                            id: 'les-1',
                            title: 'Lesson 1: ${titleCtrl.text.trim()} (In-App Video)',
                            duration: 'Full Lesson',
                            youtubeId: videoReference,
                            isFreePreview: fee == 0,
                            summary: 'Private course lesson video uploaded from device.',
                          ),
                        );
                      }

                      final newCourse = CourseModel(
                        id: 'course-${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        urduTitle: urduCtrl.text.trim().isEmpty ? titleCtrl.text.trim() : urduCtrl.text.trim(),
                        category: category,
                        price: fee,
                        originalPrice: fee,
                        discountPercent: 0,
                        duration: 'Self-paced',
                        lessonsCount: initialLessons.length,
                        badge: fee == 0 ? 'FREE' : 'COURSE',
                        instructor: 'Hafiz Hasnain Jaani',
                        rating: 5.0,
                        studentsEnrolled: 0,
                        thumbnail: thumb,
                        description: descCtrl.text.trim().isEmpty
                            ? 'Authentic step-by-step Islamic course.'
                            : descCtrl.text.trim(),
                        highlights: ['Authentic Fiqh-e-Hanafi', 'Practical step-by-step classes'],
                        lessons: initialLessons,
                      );

                      await appState.addCourse(newCourse);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Course successfully created with uploaded video!'),
                            backgroundColor: AppColors.darkEmerald,
                          ),
                        );
                      }
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

  // Native Windows Video File Picker for In-App Course Videos (Not on YouTube)
  Future<String?> _pickVideoFile() async {
    if (Platform.isWindows) {
      try {
        final res = await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          '[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null; '
          '\$f = New-Object System.Windows.Forms.OpenFileDialog; '
          '\$f.Filter = "Video Files (*.mp4;*.webm;*.mov)|*.mp4;*.webm;*.mov|All Files (*.*)|*.*"; '
          'if (\$f.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { \$f.FileName }'
        ]);
        final out = res.stdout.toString().trim();
        return out.isNotEmpty ? out : null;
      } catch (_) {}
    }
    return null;
  }

  // Admin Dialog: Add Video Lesson to existing Course (In-App Only or URL)
  void _showAddLessonDialog(BuildContext context, CourseModel course, AppStateService appState) {
    final titleCtrl = TextEditingController();
    final videoPathCtrl = TextEditingController();
    final durCtrl = TextEditingController(text: '15:00');
    bool isAppOnly = true; // Default true: In-app private video, NOT on YouTube
    bool isFreePreview = false;
    bool isUploading = false;
    String? localFilePath;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF041E16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
            ),
            title: Row(
              children: const [
                Icon(Icons.video_call, color: AppColors.primaryGold),
                SizedBox(width: 8),
                Text(
                  'Add Course Lesson',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course: ${course.title}',
                      style: const TextStyle(color: AppColors.lightGold, fontSize: 12),
                    ),
                    const SizedBox(height: 12),

                    // Video Type Selector: In-App Video vs YouTube
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('In-App Only (Private)', style: TextStyle(fontSize: 11)),
                            selected: isAppOnly,
                            selectedColor: AppColors.primaryGold,
                            labelStyle: TextStyle(
                              color: isAppOnly ? const Color(0xFF032B1F) : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: const Color(0xFF082218),
                            onSelected: (val) => setDialogState(() => isAppOnly = true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('YouTube ID (Public)', style: TextStyle(fontSize: 11)),
                            selected: !isAppOnly,
                            selectedColor: AppColors.primaryGold,
                            labelStyle: TextStyle(
                              color: !isAppOnly ? const Color(0xFF032B1F) : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: const Color(0xFF082218),
                            onSelected: (val) => setDialogState(() => isAppOnly = false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Lesson Title',
                        labelStyle: TextStyle(color: AppColors.lightGold),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (isAppOnly) ...[
                      // File Picker & Upload for In-App Video
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF082218),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderEmerald),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'In-App Video File (.mp4):',
                                  style: TextStyle(color: AppColors.lightGold, fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton.icon(
                                  onPressed: isUploading
                                      ? null
                                      : () async {
                                          final picked = await _pickVideoFile();
                                          if (picked != null) {
                                            setDialogState(() {
                                              localFilePath = picked;
                                              videoPathCtrl.text = picked;
                                            });
                                          }
                                        },
                                  icon: const Icon(Icons.file_upload, size: 14),
                                  label: const Text('Browse File', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGold,
                                    foregroundColor: AppColors.darkEmerald,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                            if (localFilePath != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Selected: ${localFilePath!.split(Platform.pathSeparator).last}',
                                style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: videoPathCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: const InputDecoration(
                          labelText: 'Direct In-App Video URL or Local Path',
                          hintText: 'e.g. /uploads/course_videos/lesson1.mp4',
                          hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                          labelStyle: TextStyle(color: AppColors.lightGold, fontSize: 11),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: videoPathCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'YouTube Video ID or URL',
                          hintText: 'e.g. gMTvoRUgeXA',
                          hintStyle: TextStyle(color: Colors.white38),
                          labelStyle: TextStyle(color: AppColors.lightGold),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    TextField(
                      controller: durCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Duration (e.g. 20:15)',
                        labelStyle: TextStyle(color: AppColors.lightGold),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Free Preview Toggle
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primaryGold,
                      title: const Text('Allow Free Preview without Payment?', style: TextStyle(color: Colors.white, fontSize: 12)),
                      value: isFreePreview,
                      onChanged: (val) => setDialogState(() => isFreePreview = val),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: isUploading
                    ? null
                    : () async {
                        if (titleCtrl.text.trim().isEmpty || videoPathCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a lesson title and video.'), backgroundColor: Colors.redAccent),
                          );
                          return;
                        }

                        String videoTarget = videoPathCtrl.text.trim();

                        // If user selected a local file on disk, upload it to the backend server!
                        if (localFilePath != null && File(localFilePath!).existsSync()) {
                          setDialogState(() => isUploading = true);
                          final uploadedUrl = await ApiService().uploadCourseVideo(localFilePath!);
                          if (uploadedUrl != null) {
                            videoTarget = uploadedUrl;
                          }
                          setDialogState(() => isUploading = false);
                        } else if (!isAppOnly) {
                          // Extract YouTube ID if URL passed
                          if (videoTarget.contains('v=')) {
                            videoTarget = videoTarget.split('v=')[1].split('&')[0];
                          } else if (videoTarget.contains('youtu.be/')) {
                            videoTarget = videoTarget.split('youtu.be/')[1].split('?')[0];
                          }
                        }

                        final newLesson = CourseLesson(
                          id: 'les-${DateTime.now().millisecondsSinceEpoch}',
                          title: titleCtrl.text.trim(),
                          duration: durCtrl.text.trim().isEmpty ? '15:00' : durCtrl.text.trim(),
                          youtubeId: videoTarget, // In-app video file URL or YouTube ID
                          isFreePreview: isFreePreview,
                          summary: titleCtrl.text.trim(),
                        );

                        await appState.addLessonToCourse(course.id, newLesson);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ In-App Course Lesson successfully published!'),
                              backgroundColor: AppColors.darkEmerald,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.darkEmerald,
                ),
                child: isUploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkEmerald))
                    : const Text('Add Lesson', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
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

                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateCourseDialog(context, appState),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Create New Course (Course Banayein)'),
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
                childAspectRatio: 0.74,
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
              onTap: () {
                if (!isUnlocked && !isFree) {
                  _showEnrollDialog(context, course, appState);
                } else {
                  _showCourseLessonsModal(context, course, appState);
                }
              },
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!isUnlocked && !isFree) {
                        _showEnrollDialog(context, course, appState);
                      } else {
                        _showCourseLessonsModal(context, course, appState);
                      }
                    },
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
                  const SizedBox(height: 4),
                  // Price Row with Admin edit fee link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFree ? 'Free Course' : 'Fee: ₹${course.price}',
                        style: TextStyle(
                          color: isFree ? const Color(0xFF34D399) : AppColors.brightGold,
                          fontSize: 10.5,
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
                              fontSize: 9.5,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Action Button (View Lessons or Enroll)
                  SizedBox(
                    width: double.infinity,
                    height: 28,
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
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isUnlocked && !isFree
                            ? AppColors.primaryGold
                            : const Color(0xFF0F4C3A),
                        foregroundColor: !isUnlocked && !isFree
                            ? AppColors.darkEmerald
                            : AppColors.brightGold,
                        padding: EdgeInsets.zero,
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
