import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swift_wallet_mobile/services/api/dio_client.dart';
import 'package:swift_wallet_mobile/models/notification_models.dart';

// Provider to access the NotificationApiService instance
final notificationApiServiceProvider = Provider((ref) {
  return NotificationApiService(ref.read(dioProvider));
});

class NotificationApiService {
  final Dio _dio;

  NotificationApiService(this._dio);

  /// Get all active promotions (public endpoint)
  Future<List<Promotion>> getActivePromotions() async {
    try {
      final response = await _dio.get('/promotions/active/');

      if (response.data['success'] == true) {
        final promotions = (response.data['data'] as List)
            .map((json) => Promotion.fromJson(json))
            .toList();
        return promotions;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch promotions');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Get user notifications (requires authentication)
  Future<List<NotificationModel>> getUserNotifications({
    String? type,
    bool? readStatus,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (readStatus != null) queryParams['read'] = readStatus.toString();

      final response = await _dio.get(
        '/notifications/',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final notifications = (response.data['data'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        return notifications;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch notifications');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count/');

      if (response.data['success'] == true) {
        return response.data['data']['unread_count'] as int;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch unread count');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Mark notifications as read
  Future<void> markAsRead({List<int>? notificationIds}) async {
    try {
      final response = await _dio.post(
        '/notifications/mark-read/',
        data: {
          'notification_ids': notificationIds ?? [],
        },
      );

      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Failed to mark as read');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Track notification interaction
  Future<void> trackInteraction({
    int? notificationId,
    int? promotionId,
    required String interactionType,
  }) async {
    try {
      final data = <String, dynamic>{
        'interaction_type': interactionType,
      };

      if (notificationId != null) {
        data['notification'] = notificationId;
      }
      if (promotionId != null) {
        data['promotion'] = promotionId;
      }

      final response = await _dio.post(
        '/interactions/',
        data: data,
      );

      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Failed to track interaction');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}
