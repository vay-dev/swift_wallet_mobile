import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swift_wallet_mobile/features/auth/screens/login_screen.dart';
import 'package:swift_wallet_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:swift_wallet_mobile/features/auth/screens/splash_screen.dart';
import 'package:swift_wallet_mobile/features/topup/screens/topup_screen.dart';
import 'package:swift_wallet_mobile/features/auth/screens/signup_screen.dart';
import 'package:swift_wallet_mobile/features/auth/screens/otp_verification_screen.dart';
import 'package:swift_wallet_mobile/features/auth/screens/account_setup_screen.dart';
import 'package:swift_wallet_mobile/features/pages/notificaitons_activity_screen.dart';

// definition of app routes
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const otpVerification = '/otp';
  static const accountSetup = '/account-setup';
  static const dashboard = '/dashboard';
  static const transactionHistory = '/history';
  static const sendMoney = '/send';
  static const topup = '/topup';
}

// Custom page transition builder
CustomTransitionPage _buildPageWithFadeTransition(
  Widget child,
) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder:
        (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(
              curve: Curves.easeInOut,
            ).animate(animation),
            child: child,
          );
        },
  );
}

CustomTransitionPage _buildPageWithSlideTransition(
  Widget child,
) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder:
        (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
  );
}

// 2. The Global GoRouter Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash Screen (Initial Route)
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(
              const SplashScreen(),
            ),
      ),

      // Authentication Routes (Public Access)
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(
              const LoginScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) =>
            _buildPageWithSlideTransition(
              const SignupScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        pageBuilder: (context, state) {
          final signupData =
              state.extra as Map<String, dynamic>;
          return _buildPageWithSlideTransition(
            OtpVerificationScreen(signupData: signupData),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.accountSetup,
        pageBuilder: (context, state) {
          final signupData =
              state.extra as Map<String, dynamic>;
          return _buildPageWithSlideTransition(
            AccountSetupScreen(signupData: signupData),
          );
        },
      ),

      // Main App Routes (Private Access)
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboard,
        pageBuilder: (context, state) =>
            _buildPageWithFadeTransition(DashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.transactionHistory,
        builder: (context, state) =>
            NotificaitonsActivityScreen(), // Placeholder
      ),
      GoRoute(
        path: AppRoutes.sendMoney,
        builder: (context, state) =>
            Placeholder(), // Placeholder
      ),
      GoRoute(
        path: AppRoutes.topup,
        builder: (context, state) => TopUpScreen(),
      ),
    ],
    // 404 Error Page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('Cannot find route for: ${state.uri}'),
      ),
    ),
  );
});
