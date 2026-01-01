import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swift_wallet_mobile/features/notifications/notification_notifiers.dart';
import 'package:swift_wallet_mobile/models/notification_models.dart';

class PromoCarousel extends ConsumerStatefulWidget {
  const PromoCarousel({super.key});

  @override
  ConsumerState<PromoCarousel> createState() =>
      _PromoCarouselState();
}

class _PromoCarouselState
    extends ConsumerState<PromoCarousel> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch promotions when widget loads
    Future.microtask(
      () => ref
          .read(notificationProvider.notifier)
          .fetchPromotions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(
      notificationProvider,
    );
    final promotions = notificationState.promotions;

    if (promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Promo & Discount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to see all promos
                },
                child: Text(
                  'See More',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CarouselSlider.builder(
          itemCount: promotions.length,
          options: CarouselOptions(
            height: 160,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 10),
            autoPlayAnimationDuration: const Duration(
              milliseconds: 800,
            ),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: true,
            aspectRatio: 16 / 9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final promo = promotions[index];
            return _buildPromoCard(promo);
          },
        ),
        const SizedBox(height: 12),
        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: promotions.asMap().entries.map((entry) {
            return Container(
              width: _currentIndex == entry.key ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentIndex == entry.key
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPromoCard(Promotion promo) {
    return GestureDetector(
      onTap: () {
        // Track interaction
        ref
            .read(notificationProvider.notifier)
            .trackInteraction(
              promotionId: promo.id,
              interactionType: 'CLICK',
            );

        // Handle action based on type
        if (promo.actionType == 'DEEP_LINK') {
          // TODO: Navigate to deep link
          // context.go(promo.actionLink);
        } else if (promo.actionType == 'WEB_URL') {
          // TODO: Open web URL
          // launchUrl(Uri.parse(promo.actionLink));
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Promo image
              CachedNetworkImage(
                imageUrl: promo.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary,
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.card_giftcard,
                              size: 40,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                              child: Text(
                                promo.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                              child: Text(
                                promo.description,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
              // Gradient overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
              // Promo details overlay
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      promo.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
