import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_wallet_mobile/core/router.dart';
import 'package:swift_wallet_mobile/features/auth/auth_notifiers.dart';
import 'package:swift_wallet_mobile/models/user_models.dart';

// --- Reusable Component 1: Quick Action Button ---
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color primaryColor;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 5),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable Component 2: Payment Icon Item (Scrollable List) ---
class PaymentItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const PaymentItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label tapped!')),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Main Home Tab Widget ---
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = ref.watch(
      authProvider.select((state) => state.user),
    );
    final primaryColor = Theme.of(
      context,
    ).colorScheme.primary;

    // Data for the Payment List icons
    final paymentItems = [
      PaymentItem(
        icon: Icons.electric_bolt_rounded,
        label: 'Electricity',
        color: Colors.amber,
      ),
      PaymentItem(
        icon: Icons.wifi,
        label: 'Internet',
        color: Colors.redAccent,
      ),
      PaymentItem(
        icon: Icons.airplane_ticket_rounded,
        label: 'Voucher',
        color: Colors.green,
      ),
      PaymentItem(
        icon: Icons.local_hospital_rounded,
        label: 'Assurance',
        color: Colors.blue,
      ),
      PaymentItem(
        icon: Icons.shopping_cart_rounded,
        label: 'Merchant',
        color: Colors.purple,
      ),
      PaymentItem(
        icon: Icons.phone_android_rounded,
        label: 'Mobile Credit',
        color: Colors.lightBlue,
      ),
      PaymentItem(
        icon: Icons.receipt_long,
        label: 'Bill',
        color: Colors.deepOrange,
      ),
      PaymentItem(
        icon: Icons.more_horiz,
        label: 'More',
        color: Colors.grey,
      ),
    ];

    return CustomScrollView(
      slivers: [
        // 1. AppBar Area
        SliverAppBar(
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              // Logo Placeholder (using Icon as per design)
              Icon(
                Icons.account_balance_wallet_outlined,
                color: primaryColor,
                size: 30,
              ),
              const SizedBox(width: 8),
              Text(
                'WiPay', // Placeholder brand name from design
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
              ),
            ],
          ),
          actions: [
            // Settings Icon
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.black54,
              ),
              onPressed: () {},
            ),
          ],
        ),

        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // 2. Welcome & Balance
                  Text(
                    'Hello ${user?.fullName ?? 'Andre,'}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your available balance',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      // Hardcoded balance (Will be replaced with API data soon)
                      Text(
                        '\$15,901',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 3. Quick Action Buttons (Transfer, Top Up, History)
                  Row(
                    children: [
                      QuickActionButton(
                        icon: Icons.swap_horiz_rounded,
                        label: 'Transfer',
                        onTap: () =>
                            context.go(AppRoutes.sendMoney),
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(width: 10),
                      QuickActionButton(
                        icon: Icons.credit_card_rounded,
                        label: 'Top Up',
                        onTap: () => context.go(AppRoutes.topup),
                        primaryColor: primaryColor
                            .withOpacity(0.8),
                      ),
                      const SizedBox(width: 10),
                      QuickActionButton(
                        icon: Icons.history_rounded,
                        label: 'History',
                        onTap: () => context.go(
                          AppRoutes.transactionHistory,
                        ),
                        primaryColor: primaryColor
                            .withOpacity(0.6),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 4. Payment List Header
                  Text(
                    'Payment List',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 15),

                  // 5. Scrollable Payment Icon List (Horizontal Scroll)
                  SizedBox(
                    height:
                        90, // Defines the height for the horizontal list
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: paymentItems.length,
                      itemBuilder: (context, index) {
                        return paymentItems[index];
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 6. Promo & Discount Section Header
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Promo & Discount',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'See More',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  // 7. Promo Banner (Horizontal Scroll)
                  SizedBox(
                    height:
                        150, // Height of the promo banner
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPromoCard(
                          context,
                          primaryColor,
                          '30% OFF',
                          'Black Friday deal',
                          'assets/images/banner-1.jpg',
                        ),
                        _buildPromoCard(
                          context,
                          primaryColor.withOpacity(0.8),
                          '10% Cashback',
                          'Next Transfer',
                          'assets/images/banner-2.jpeg',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 100,
                  ), // Space for the FAB/Navbar padding
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildPromoCard(
    BuildContext context,
    Color color,
    String discount,
    String title,
    String imagePath,
  ) {
    return Container(
      width:
          MediaQuery.of(context).size.width *
          0.75, // Takes 75% of screen width
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color, // Fallback color if image fails to load
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            color.withOpacity(
              0.6,
            ), // Blend with app theme color (reduced to 0.6 for better visibility)
            BlendMode
                .multiply, // Multiply blend mode preserves theme color
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            discount,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: Colors.white),
          ),
          const Spacer(),
          Text(
            'Get discount for every transaction',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
