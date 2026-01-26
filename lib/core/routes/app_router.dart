import 'package:go_router/go_router.dart';
import 'package:smart_home_pro/presentation/screens/dashboard_screen.dart';
import 'package:smart_home_pro/presentation/screens/login_screen.dart';
import 'package:smart_home_pro/presentation/screens/onboarding_screen.dart';
import 'package:smart_home_pro/presentation/screens/register_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
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
    ],
  );
}