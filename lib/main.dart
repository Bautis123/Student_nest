import 'screens/admin_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/theme.dart';
import 'screens/main_screen.dart';
import 'screens/landlord_main_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const StudentNestApp());
}

class StudentNestApp extends StatefulWidget {
  const StudentNestApp({super.key});

  @override
  State<StudentNestApp> createState() => _StudentNestAppState();
}

class _StudentNestAppState extends State<StudentNestApp> {
  final AppThemeController _themeController = AppThemeController();

  @override
  void initState() {
    super.initState();
    _themeController.loadThemeMode();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'Student Nest',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _themeController.themeMode,
            home: const SplashRouter(),
          );
        },
      ),
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = await ApiService().getUser();
    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (user.role == 'landlord') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LandlordMainScreen()),
      );
    } else if (user.role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminMainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
                child: Icon(
                  Icons.home_work_rounded,
                  size: 34,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Student Nest',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
