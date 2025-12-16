import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swift_wallet_mobile/features/notifications/notification_notifiers.dart';
import 'package:swift_wallet_mobile/models/notification_models.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen loads
    Future.microtask(
      () => ref.read(notificationProvider.notifier).fetchNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              // Handle settings tap
            },
          ),
        ],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/appbar_bg.jpeg'),
              fit: BoxFit.cover,
            ),
            gradient: LinearGradient(
              colors: [
                Colors.black.withAlpha(150),
                Colors.black.withAlpha(120),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: notificationState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : notificationState.notifications.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      // Mark all as read button
                      if (notificationState.unreadCount > 0)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ref
                                  .read(notificationProvider.notifier)
                                  .markAsRead();
                            },
                            child: Text(
                              'Mark as read',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(notificationProvider.notifier)
                                .fetchNotifications();
                          },
                          child: ListView(
                            children: _buildGroupedNotifications(
                              notificationState.notifications,
                              primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something arrives',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedNotifications(
    List<NotificationModel> notifications,
    Color primaryColor,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sevenDaysAgo = today.subtract(const Duration(days: 7));

    final todayNotifs = <NotificationModel>[];
    final yesterdayNotifs = <NotificationModel>[];
    final last7DaysNotifs = <NotificationModel>[];

    for (final notif in notifications) {
      final notifDate = DateTime(
        notif.createdAt.year,
        notif.createdAt.month,
        notif.createdAt.day,
      );

      if (notifDate.isAtSameMomentAs(today)) {
        todayNotifs.add(notif);
      } else if (notifDate.isAtSameMomentAs(yesterday)) {
        yesterdayNotifs.add(notif);
      } else if (notifDate.isAfter(sevenDaysAgo)) {
        last7DaysNotifs.add(notif);
      }
    }

    final widgets = <Widget>[];

    if (todayNotifs.isNotEmpty) {
      widgets.add(_buildSectionHeader('TODAY'));
      widgets.addAll(
        todayNotifs.map((n) => _buildNotificationItem(n, primaryColor)),
      );
    }

    if (yesterdayNotifs.isNotEmpty) {
      widgets.add(_buildSectionHeader('YESTERDAY'));
      widgets.addAll(
        yesterdayNotifs.map((n) => _buildNotificationItem(n, primaryColor)),
      );
    }

    if (last7DaysNotifs.isNotEmpty) {
      widgets.add(_buildSectionHeader('LAST 7 DAY'));
      widgets.addAll(
        last7DaysNotifs.map((n) => _buildNotificationItem(n, primaryColor)),
      );
    }

    return widgets;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[400],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
    Color primaryColor,
  ) {
    return GestureDetector(
      onTap: () {
        // Mark as read when tapped
        if (!notification.read) {
          ref
              .read(notificationProvider.notifier)
              .markAsRead(notificationIds: [notification.id]);
        }

        // Track interaction
        ref.read(notificationProvider.notifier).trackInteraction(
              notificationId: notification.id,
              interactionType: 'CLICK',
            );

        // Handle navigation if promo
        if (notification.type == 'PROMO' && notification.promotion != null) {
          // TODO: Handle deep link navigation
          // context.go(notification.promotion!.actionLink);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: notification.read ? Colors.grey[200]! : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(notification, primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (notification.type == 'PROMO')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Promo',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (notification.type == 'INFO')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Info',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.content,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                  if (notification.type == 'PROMO' &&
                      notification.promotion != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Top up now →',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(
    NotificationModel notification,
    Color primaryColor,
  ) {
    if (notification.type == 'PROMO' && notification.promotion != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: notification.promotion!.thumbnailUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 40,
            height: 40,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.card_giftcard, color: primaryColor, size: 20),
          ),
        ),
      );
    }

    Color bgColor;
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'SUCCESS':
        bgColor = const Color(0xFFE8F5E9);
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'FAILED':
        bgColor = const Color(0xFFFFEBEE);
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      case 'INFO':
        bgColor = const Color(0xFFE3F2FD);
        icon = Icons.info;
        iconColor = Colors.blue;
        break;
      default:
        bgColor = Colors.grey[200]!;
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}
