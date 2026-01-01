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
  final String? error;

  // using a status enum for clearer state tracking
  final AuthStatus status;

  // Track if user has seen onboarding
  final bool hasSeenOnboarding;

  AuthState({
    this.user,
    this.isLoading = false,
    this.status = AuthStatus.initial,
    this.hasSeenOnboarding = false,
    this.error,
  });

  // helper method to copy/update the state
  AuthState copyWith({
    User? user,
    bool? isLoading,
    AuthStatus? status,
    bool? hasSeenOnboarding,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      // For bool, we need explicit null check since false is a valid value
      hasSeenOnboarding:
          hasSeenOnboarding ?? this.hasSeenOnboarding,
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
@Riverpod(
  keepAlive: true,
) // keepAlive keeps the provider alive even if no longer watched
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
    final hasSeenOnboarding = await _tokenStorage
        .hasSeenOnboarding();

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
        isActive: true,
        walletBalance: '1000.00',
      );

      state = state.copyWith(
        user: mockUser,
        status: AuthStatus.authenticated,
        isLoading: false,
        hasSeenOnboarding:
            true, // If they have token, they've seen onboarding
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        hasSeenOnboarding: hasSeenOnboarding,
      );
    }
  }

  // Method to mark onboarding as completed
  Future<void> completeOnboarding() async {
    await _tokenStorage.markOnboardingAsSeen();
    state = state.copyWith(hasSeenOnboarding: true);
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
      final tokens = AuthTokens.fromJson(
        responseData['tokens'],
      );
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
      final errorMessage =
          'An error occurred: ${e.message}';
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );

      // Handle different error types
      if (e.response?.statusCode == 403) {
        return e.response?.data['message'] ??
            'Device mismatch detected';
      } else if (e.response?.statusCode == 400) {
        return e.response?.data['message'] ??
            'Invalid credentials';
      } else {
        return 'Network error. Please try again.';
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'An unexpected error occurred: $e';
    }
  }

  // Method to request signup OTP
  Future<String?> requestSignupOtp({
    required String phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _authApi.requestSignupOtp(
        phoneNumber: phoneNumber,
      );
      state = state.copyWith(isLoading: false);
      return null; // Success
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      if (e.response?.statusCode == 400) {
        return e.response?.data['message'] ??
            'Invalid phone number';
      }
      return 'Network error. Please try again.';
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'An unexpected error occurred: $e';
    }
  }

  // Method to verify OTP and create account
  Future<String?> verifySignupOtp({
    required String phoneNumber,
    required String otpCode,
    required String fullName,
    required String password,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final responseData = await _authApi.verifySignupOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
        fullName: fullName,
        password: password,
        email: email,
      );

      // Extract tokens and user from response
      final tokens = AuthTokens.fromJson(
        responseData['tokens'],
      );
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

      return null; // Success
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      if (e.response?.statusCode == 400) {
        return e.response?.data['message'] ??
            'Invalid OTP code';
      }
      return 'Network error. Please try again.';
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'An unexpected error occurred: $e';
    }
  }

  // Method to upload profile picture
  Future<String?> uploadProfilePicture(
    String imagePath,
  ) async {
    try {
      final imageUrl = await _authApi.uploadProfilePicture(
        imagePath,
      );
      if (imageUrl != null && state.user != null) {
        // Update user with new profile picture
        // Note: You may need to add a copyWith method to User model
        state = state.copyWith(user: state.user);
      }
      return imageUrl;
    } catch (e) {
      return null;
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
