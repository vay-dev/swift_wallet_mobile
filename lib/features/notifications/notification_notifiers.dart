import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:swift_wallet_mobile/models/notification_models.dart';
import 'package:swift_wallet_mobile/services/api/notification_api_service.dart';
import 'package:dio/dio.dart';

part 'notification_notifiers.g.dart';

// State for notifications
class NotificationState {
  final List<NotificationModel> notifications;
  final List<Promotion> promotions;
  final int unreadCount;
  final bool isLoading;
  final String? errorMessage;

  NotificationState({
    this.notifications = const [],
    this.promotions = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    List<Promotion>? promotions,
    int? unreadCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      promotions: promotions ?? this.promotions,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class NotificationNotifier extends _$NotificationNotifier {
  late final NotificationApiService _notificationApi;

  @override
  NotificationState build() {
    _notificationApi = ref.read(notificationApiServiceProvider);
    return NotificationState();
  }

  // Fetch active promotions
  Future<void> fetchPromotions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final promotions = await _notificationApi.getActivePromotions();
      state = state.copyWith(
        promotions: promotions,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.response?.data['message'] ?? 'Failed to fetch promotions',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred: $e',
      );
    }
  }

  // Fetch user notifications
  Future<void> fetchNotifications({String? type, bool? readStatus}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final notifications = await _notificationApi.getUserNotifications(
        type: type,
        readStatus: readStatus,
      );
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
      );

      // Also fetch unread count
      await fetchUnreadCount();
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.response?.data['message'] ?? 'Failed to fetch notifications',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred: $e',
      );
    }
  }

  // Fetch unread count
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _notificationApi.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      // Silently fail for unread count
    }
  }

  // Mark notification as read
  Future<void> markAsRead({List<int>? notificationIds}) async {
    try {
      await _notificationApi.markAsRead(notificationIds: notificationIds);

      // Update local state
      if (notificationIds != null && notificationIds.isNotEmpty) {
        final updatedNotifications = state.notifications.map((notif) {
          if (notificationIds.contains(notif.id)) {
            return NotificationModel(
              id: notif.id,
              type: notif.type,
              title: notif.title,
              content: notif.content,
              read: true,
              promotion: notif.promotion,
              createdAt: notif.createdAt,
              readAt: DateTime.now(),
              timeAgo: notif.timeAgo,
            );
          }
          return notif;
        }).toList();

        state = state.copyWith(notifications: updatedNotifications);
      } else {
        // Mark all as read
        final updatedNotifications = state.notifications.map((notif) {
          return NotificationModel(
            id: notif.id,
            type: notif.type,
            title: notif.title,
            content: notif.content,
            read: true,
            promotion: notif.promotion,
            createdAt: notif.createdAt,
            readAt: DateTime.now(),
            timeAgo: notif.timeAgo,
          );
        }).toList();

        state = state.copyWith(notifications: updatedNotifications);
      }

      // Refresh unread count
      await fetchUnreadCount();
    } catch (e) {
      // Handle error silently or show message
    }
  }

  // Track interaction
  Future<void> trackInteraction({
    int? notificationId,
    int? promotionId,
    required String interactionType,
  }) async {
    try {
      await _notificationApi.trackInteraction(
        notificationId: notificationId,
        promotionId: promotionId,
        interactionType: interactionType,
      );
    } catch (e) {
      // Handle error silently
    }
  }
}
