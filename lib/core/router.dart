import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swift_wallet_mobile/features/auth/screens/login_screen.dart';
import 'package:swift_wallet_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:swift_wallet_mobile/features/auth/screens/splash_screen.dart';

// definition of app routes
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const otpVerification = '/otp';
  static const dashboard = '/dashboard';
  static const transactionHistory = '/history';
  static const sendMoney = '/send';
}


// 2. The Global GoRouter Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash Screen (Initial Route)
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication Routes (Public Access)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const Placeholder(), // Placeholder
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) => const Placeholder(), // Placeholder
      ),

      // Main App Routes (Private Access)
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactionHistory,
        builder: (context, state) => const Placeholder(), // Placeholder
      ),
      GoRoute(
        path: AppRoutes.sendMoney,
        builder: (context, state) => const Placeholder(), // Placeholder
      ),
    ],
    // 404 Error Page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Cannot find route for: ${state.uri}')),
    ),
  );
});