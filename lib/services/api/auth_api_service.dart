import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:swift_wallet_mobile/models/user_models.dart';
import 'package:swift_wallet_mobile/services/api/dio_client.dart';

// provider to access the AuthApiService instance
final authApiServiceProvider = Provider((ref) {
  return AuthApiService(ref.read(dioProvider));
});

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  /// Handles the POST request to the /auth/login/ endpoint.
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login/', // Relative path is handled by Dio's BaseUrl
        data: {
          'phone_number': phoneNumber,
          'password': password,
          'device_id': deviceId,
          'device_name': deviceName,
        },
      );

      // Check the backend's "status" field for success/error
      if (response.data['status'] == 'success') {
        // Return the full data payload for the AuthNotifier to process
        return response.data['data']
            as Map<String, dynamic>;
      } else {
        // Handle backend-specific errors like device mismatch
        throw Exception(
          response.data['message'] ??
              'Login failed due to API error.',
        );
      }
    } on DioException catch (e) {
      // Re-throw a custom exception or DioError for the Notifier to handle
      throw e;
    } catch (e) {
      throw Exception(
        'An unknown error occurred during login: $e',
      );
    }
  }
}
