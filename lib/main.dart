import 'package:flutter/material.dart';
import 'repositories/hive_database.dart';
import 'theme/samurai_theme.dart';
import 'screens/dojo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.initialize();
  runApp(const GZCLUHFApp());
}

class GZCLUHFApp extends StatelessWidget {
  const GZCLUHFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GZCL UHF - The Way of Iron',
      theme: SamuraiTheme.darkTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DojoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamuraiColors.midnightBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              SamuraiColors.sanguineRed,
              SamuraiColors.midnightBlack,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SamuraiColors.goldenKoi,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: SamuraiColors.goldenKoi.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_martial_arts,
                  size: 80,
                  color: SamuraiColors.goldenKoi,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '鉄の道',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 24,
                  color: SamuraiColors.goldenKoi,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'THE WAY OF IRON',
                style: SamuraiTextStyles.katanaSharp(
                  fontSize: 32,
                  color: SamuraiColors.ashWhite,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'GZCL Ultra High Frequency',
                style: SamuraiTextStyles.brushStroke(
                  fontSize: 16,
                  color: SamuraiColors.sakuraPink,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                '"Discipline is the soul of an army"',
                style: SamuraiTextStyles.ancientWisdom(
                  fontSize: 14,
                  color: SamuraiColors.ashWhite.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(SamuraiColors.goldenKoi),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

