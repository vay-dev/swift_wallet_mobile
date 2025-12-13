import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swift_wallet_mobile/services/api/dio_client.dart';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';

// provider to access the AuthApiService instance
final authApiServiceProvider = Provider((ref) {
  return AuthApiService(ref.read(dioProvider));
});

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  // Helper: Get device ID
  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      }
    } catch (e) {
      return 'unknown_device';
    }
    return 'unknown_device';
  }

  // Helper: Get device name
  Future<String> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} ${iosInfo.model}';
      }
    } catch (e) {
      return 'Unknown Device';
    }
    return 'Unknown Device';
  }

  /// Request OTP for signup
  Future<Map<String, dynamic>> requestSignupOtp({
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/signup/request-otp/',
        data: {'phone_number': phoneNumber},
      );

      if (response.data['status'] == 'success') {
        return response.data;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to send OTP',
        );
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Verify OTP and create account
  Future<Map<String, dynamic>> verifySignupOtp({
    required String phoneNumber,
    required String otpCode,
    required String fullName,
    required String password,
    String? email,
  }) async {
    try {
      final deviceId = await _getDeviceId();
      final deviceName = await _getDeviceName();

      final response = await _dio.post(
        '/auth/signup/verify-otp/',
        data: {
          'phone_number': phoneNumber,
          'otp_code': otpCode,
          'full_name': fullName,
          'password': password,
          'email': email ?? '',
          'device_id': deviceId,
          'device_name': deviceName,
        },
      );

      if (response.data['status'] == 'success') {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          response.data['message'] ?? 'Verification failed',
        );
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Login
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login/',
        data: {
          'phone_number': phoneNumber,
          'password': password,
          'device_id': deviceId,
          'device_name': deviceName,
        },
      );

      if (response.data['status'] == 'success') {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          response.data['message'] ?? 'Login failed due to API error.',
        );
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('An unknown error occurred during login: $e');
    }
  }

  /// Upload profile picture
  Future<String?> uploadProfilePicture(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'display_picture': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '/user/profile/picture/',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['data']['display_picture'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
