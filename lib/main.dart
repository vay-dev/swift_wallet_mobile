import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
import 'package:swift_wallet_mobile/core/router.dart';

const Color primaryGreen = Color(0xFF33B566);
const Color darkTextColor = Color(0xFF1C2A3A);

void main() {
  runApp(const ProviderScope(child: SwiftWalletApp()));
}

class SwiftWalletApp extends ConsumerWidget {
  const SwiftWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Swift Wallet',
      debugShowCheckedModeBanner: false,

      routerConfig: goRouter,

      theme: ThemeData(
        // Use our custom primary color for the seed
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          surface: Colors.white,
          onPrimary: Colors.white,
        ),
        textTheme:
            GoogleFonts.poppinsTextTheme(
              ThemeData.light().textTheme,
            ).apply(
              bodyColor: darkTextColor,
              displayColor: darkTextColor,
            ),
      ),
    );
  }
}
