import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'services/in_app_player_server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start internal zero-latency player loopback server (bypasses Error 153 & ERR_CONNECTION_REFUSED)
  await InAppPlayerServer().ensureStarted();

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
