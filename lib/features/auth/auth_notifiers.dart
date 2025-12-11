import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:swift_wallet_mobile/models/user_models.dart';
import 'package:swift_wallet_mobile/services/token_storage_service.dart';
import 'package:swift_wallet_mobile/services/api/auth_api_service.dart';
import 'package:dio/dio.dart';

part 'auth_notifiers.g.dart';

// define states for the authentication flow
class AuthState {
  final User? user;
  final bool isLoading;

  // using a status enum for clearer state tracking
  final AuthStatus status;

  AuthState({
    this.user,
    this.isLoading = false,
    this.status = AuthStatus.initial,
  });

  // helper method to copy/update the state
  AuthState copyWith({
    User? user,
    bool? isLoading,
    AuthStatus? status,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
    );
  }
}


//  AuthStatus Enum to drive the router logic
enum AuthStatus {
  initial, // Splash screen
  authenticated, // Logged in, show dashboard
  unauthenticated, // Logged out, show login
}

// The Notifier Class (The Brains of the Auth Flow)
@Riverpod(keepAlive: true) // keepAlive keeps the provider alive even if no longer watched
class AuthNotifier extends _$AuthNotifier {
  // Use a late initialization for the storage service
  late final TokenStorageService _tokenStorage;
  late final AuthApiService _authApi;

  @override
  AuthState build() {
    // Initialize the storage service and API service
    _tokenStorage = ref.read(tokenStorageServiceProvider);
    _authApi = ref.read(authApiServiceProvider);

    // Default initial state
    return AuthState();
  }

  // Called by the Splash Screen to determine initial route
  Future<void> initializeAuth() async {
    state = state.copyWith(isLoading: true);

    final hasToken = await _tokenStorage.hasTokens();

    // In a real app, we would use the refresh token here to get a new
    // access token and fetch the full user profile. For now, we'll
    // assume having tokens means the user is logged in.
    if (hasToken) {
      // Simulate fetching a user profile from the server
      final mockUser = User(
        id: 1,
        phoneNumber: '1234567890',
        accountNumber: 'SW0001',
        fullName: 'Demo User',
        isVerified: true,
      );

      state = state.copyWith(
        user: mockUser,
        status: AuthStatus.authenticated,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    }
  }

  // Method to handle login
  Future<String?> login({
    required String phoneNumber,
    required String password,
    required String deviceId,
    required String deviceName,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      // Call the API service
      final responseData = await _authApi.login(
        phoneNumber: phoneNumber,
        password: password,
        deviceId: deviceId,
        deviceName: deviceName,
      );

      // Extract tokens and user from response
      final tokens = AuthTokens.fromJson(responseData['tokens']);
      final user = User.fromJson(responseData['user']);

      // Save tokens
      await _tokenStorage.saveTokens(
        accessToken: tokens.access,
        refreshToken: tokens.refresh,
      );

      // Update state
      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
        isLoading: false,
      );

      return null; // Success, no error
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);

      // Handle different error types
      if (e.response?.statusCode == 403) {
        return e.response?.data['message'] ?? 'Device mismatch detected';
      } else if (e.response?.statusCode == 400) {
        return e.response?.data['message'] ?? 'Invalid credentials';
      } else {
        return 'Network error. Please try again.';
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'An unexpected error occurred: $e';
    }
  }

  // Method to handle user logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _tokenStorage.clearTokens();

    state = state.copyWith(
      user: null,
      status: AuthStatus.unauthenticated,
      isLoading: false,
    );
  }
}