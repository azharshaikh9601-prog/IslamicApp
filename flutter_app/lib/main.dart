import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable seamless automatic autoplay for Shorts on Windows desktop
  if (Platform.isWindows) {
    try {
      await WebviewController.initializeEnvironment(
        additionalArguments:
            '--autoplay-policy=no-user-gesture-required --enable-features=AutoplayIgnoreWebAudio',
      );
    } catch (e) {
      debugPrint('[WebView2] initializeEnvironment notice: $e');
    }
  }

  // Set immersive system status bar and navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.darkEmerald,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const HafizHasnainApp());
}

class HafizHasnainApp extends StatelessWidget {
  const HafizHasnainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hafiz Hasnain Jaani - Official Islamic App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
