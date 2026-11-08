import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/storage_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_drawer.dart';
import 'home/home_screen.dart';
import 'reels/reels_screen.dart';
import 'videos/videos_screen.dart';
import 'courses/courses_screen.dart';
import 'quotes/quotes_screen.dart';
import 'tools/tools_screen.dart';
import 'tools/ask_masala_screen.dart';
import 'profile/scholar_profile_screen.dart';
import 'dashboard/dashboard_screen.dart';
import '../widgets/video_player/shorts_player_stub.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Pre-warm WebView2 for instant Shorts playback
    ShortsWebviewPool.instance.prewarm();
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _openDashboard() {
    setState(() => _currentIndex = 5); // Tab 5: Admin / Dashboard
  }

  void _openAskMasala() {
    setState(() => _currentIndex = 8); // Tab 8: Dedicated Ask Mas'ala
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();

    final List<Widget> screens = [
      HomeScreen(
        onTabSelected: _onTabSelected,
        onOpenAskMasala: _openAskMasala,
      ),
      ReelsScreen(isActive: _currentIndex == 1), // Tab 1: Short Clips (Shorts)
      const VideosScreen(), // Tab 2: Islamic Lessons (Lessons)
      const CoursesScreen(), // Tab 3: Courses
      const QuotesScreen(), // Tab 4: Daily Quotes (Quotes)
      const DashboardScreen(), // Tab 5: Scholar Dashboard (Admin)
      const ToolsScreen(), // Tab 6: Islamic Tools (Digital Tasbeeh & Salah Times)
      ScholarProfileScreen(
        onOpenAskMasala: _openAskMasala,
      ), // Tab 7: Scholar Profile
      AskMasalaScreen(
        onBack: () => _onTabSelected(0),
      ), // Tab 8: Dedicated Ask Mas'ala Screen
    ];

    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        final bool isAdmin = appState.isAdmin;
        // If not admin and somehow on admin tab, redirect to Home
        final int effectiveIndex = (!isAdmin && _currentIndex == 5) ? 0 : _currentIndex;

        // Reels screen (tab 1) and Ask Masala (tab 8) have their own header/fullscreen layout
        final bool hideMainAppBar = effectiveIndex == 1 || effectiveIndex == 8;

        // Map effectiveIndex to bottom navigation bar index
        int navBarIndex = 0;
        if (effectiveIndex <= 4) {
          navBarIndex = effectiveIndex;
        } else if (effectiveIndex == 5 && isAdmin) {
          navBarIndex = 5;
        } else {
          navBarIndex = 0;
        }

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: hideMainAppBar
              ? null
              : CustomAppBar(
                  currentTabIndex: effectiveIndex,
                  onTabSelected: _onTabSelected,
                  onAdminTap: isAdmin ? _openDashboard : null,
                ),
          drawer: AppDrawer(
            onTabSelected: _onTabSelected,
            onOpenDashboard: _openDashboard,
            onOpenAskMasala: _openAskMasala,
          ),
          body: Column(
            children: [
              // Active Screen View
              Expanded(
                child: IndexedStack(
                  index: effectiveIndex,
                  children: screens,
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderEmerald, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: navBarIndex,
              onTap: _onTabSelected,
              backgroundColor: const Color(0xFF031E16),
              selectedItemColor: const Color(0xFFECC24E),
              unselectedItemColor: AppColors.darkTextMuted,
              selectedFontSize: 10,
              unselectedFontSize: 9,
              type: BottomNavigationBarType.fixed,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.bolt_outlined),
                  activeIcon: Icon(Icons.bolt),
                  label: 'Shorts',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.ondemand_video_outlined),
                  activeIcon: Icon(Icons.ondemand_video_rounded),
                  label: 'Videos',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.school_outlined),
                  activeIcon: Icon(Icons.school),
                  label: 'Courses',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.format_quote_outlined),
                  activeIcon: Icon(Icons.format_quote_rounded),
                  label: 'Quotes',
                ),
                if (isAdmin)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view_outlined),
                    activeIcon: Icon(Icons.grid_view_rounded),
                    label: 'Admin',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
