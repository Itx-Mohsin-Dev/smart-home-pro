import 'package:go_router/go_router.dart';
import 'package:smart_home_pro/presentation/screens/splash_screen.dart';
import 'package:smart_home_pro/presentation/screens/onboarding_screen.dart';
import 'package:smart_home_pro/presentation/screens/dashboard_screen.dart';
import 'package:smart_home_pro/presentation/screens/login_screen.dart';
import 'package:smart_home_pro/presentation/screens/register_screen.dart';
import 'package:smart_home_pro/presentation/screens/statistics_screen.dart';
import 'package:smart_home_pro/presentation/screens/automation_screen.dart';
import 'package:smart_home_pro/presentation/screens/profile_screen.dart';
import 'package:smart_home_pro/presentation/screens/notification_screen.dart';
import 'package:smart_home_pro/presentation/screens/premium_screen.dart';
import 'package:smart_home_pro/presentation/screens/unauthorized_screen.dart';
import 'package:smart_home_pro/services/auth_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/automation',
        name: 'automation',
        builder: (context, state) => const AutomationScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/unauthorized',
        name: 'unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
    ],
  );
}