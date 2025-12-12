import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_wallet_mobile/features/auth/auth_notifiers.dart';
import 'package:swift_wallet_mobile/core/router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends ConsumerState<SplashScreen> {
  bool _isCheckingAuth = true;
  bool _showWelcome = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Show loading for 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    // Check authentication
    await ref.read(authProvider.notifier).initializeAuth();

    if (!mounted) return;

    final authState = ref.read(authProvider);

    // Handle navigation based on auth status and onboarding
    if (authState.status == AuthStatus.authenticated) {
      // User is authenticated, go to dashboard
      context.go(AppRoutes.dashboard);
      return;
    }

    // Check if user has seen onboarding
    if (authState.hasSeenOnboarding) {
      // User has seen onboarding before, go to login
      context.go(AppRoutes.login);
      return;
    }

    // First time user - show welcome screen
    setState(() {
      _isCheckingAuth = false;
      _showWelcome = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(
      context,
    ).colorScheme.primary;

    // Show loading while checking auth
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 30.0),
              Text(
                'Swift Wallet',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  color: primaryColor,
                  backgroundColor: primaryColor.withOpacity(
                    0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show welcome/onboarding screen for unauthenticated users
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              // App Name
              Text(
                'Swift Wallet',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your Money, Simplified',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 50),
              // Features
              Expanded(
                child: ListView(
                  children: [
                    _buildFeature(
                      context,
                      Icons.flash_on,
                      'Instant Transfers',
                      'Send money to anyone in seconds',
                      primaryColor,
                    ),
                    const SizedBox(height: 24),
                    _buildFeature(
                      context,
                      Icons.security,
                      'Secure & Safe',
                      'Bank-level security for your transactions',
                      primaryColor,
                    ),
                    const SizedBox(height: 24),
                    _buildFeature(
                      context,
                      Icons.receipt_long,
                      'Bill Payments',
                      'Pay airtime, data, electricity & more',
                      primaryColor,
                    ),
                    const SizedBox(height: 24),
                    _buildFeature(
                      context,
                      Icons.analytics,
                      'Track Spending',
                      'Smart analytics for your finances',
                      primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Get Started Button
              ElevatedButton(
                onPressed: () async {
                  // Mark onboarding as seen
                  await ref
                      .read(authProvider.notifier)
                      .completeOnboarding();
                  // Navigate to login
                  if (mounted) {
                    context.go(AppRoutes.login);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    55,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15.0,
                    ),
                  ),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
