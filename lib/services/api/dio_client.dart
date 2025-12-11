import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swift_wallet_mobile/services/token_storage_service.dart';
import 'package:swift_wallet_mobile/models/user_models.dart';

const String baseUrl = 'http://localhost:8000/api';

final dioProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));

  // Attach the interceptor for JWT handling
  dio.interceptors.add(AuthInterceptor(ref));

  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  AuthInterceptor(this._ref);

  // Called BEFORE the request is sent
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // ❗️ 1. Automatically add the JWT Access Token
    final tokenStorage = _ref.read(
      tokenStorageServiceProvider,
    );
    final accessToken = await tokenStorage.getAccessToken();

    // Skip adding header for login, signup, and refresh endpoints
    if (accessToken != null &&
        !options.path.contains('auth')) {
      options.headers['Authorization'] =
          'Bearer $accessToken';
    }

    // Proceed with the request
    return handler.next(options);
  }

  // Called WHEN a request fails (e.g., gets a 401 response)
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if the error is a 401 Unauthorized error (token expired)
    if (err.response?.statusCode == 401) {
      final tokenStorage = _ref.read(
        tokenStorageServiceProvider,
      );
      final refreshToken = await tokenStorage
          .getRefreshToken();

      // If we don't have a refresh token, we can't refresh, so force logout.
      if (refreshToken == null) {
        // Force logout via the AuthNotifier (we'll connect this soon)
        // _ref.read(authNotifierProvider.notifier).logout();
        return handler.next(err);
      }

      // ❗️ 2. Attempt to refresh the token
      try {
        final newTokens = await _getNewTokens(refreshToken);
        await tokenStorage.saveTokens(
          accessToken: newTokens.access,
          refreshToken: newTokens.refresh,
        );

        // 3. Update the original request with the new access token
        final RequestOptions requestOptions =
            err.requestOptions;
        requestOptions.headers['Authorization'] =
            'Bearer ${newTokens.access}';

        // 4. Retry the original request
        final response = await _ref
            .read(dioProvider)
            .fetch(requestOptions);
        return handler.resolve(
          response,
        ); // Resolve the original request
      } catch (e) {
        // Refresh failed (e.g., refresh token expired), so force logout
        // _ref.read(authNotifierProvider.notifier).logout();
        return handler.next(err);
      }
    }

    // For all other errors (404, 500, etc.), just pass them on
    return handler.next(err);
  }

  // Helper to call the refresh endpoint
  Future<AuthTokens> _getNewTokens(
    String refreshToken,
  ) async {
    final dio = Dio(
      BaseOptions(baseUrl: baseUrl),
    ); // Use a new Dio instance to prevent interceptor loop
    final response = await dio.post(
      '/auth/refresh/',
      data: {'refresh': refreshToken},
    );

    if (response.statusCode == 200) {
      return AuthTokens.fromJson(
        response.data['data']['tokens'],
      );
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }
}
