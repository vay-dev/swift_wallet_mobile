import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


// 1. Define the keys for our tokens
const String _accessTokenKey = 'access_token';
const String _refreshTokenKey = 'refresh_token';

// creating an instance of the secure storage plugin
const FlutterSecureStorage _storage = FlutterSecureStorage();

// Provider fo rthe storage service
final tokenStorageServiceProvider = Provider((ref) => TokenStorageService());

// 4. The service class
class TokenStorageService {
  // Save both tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Retrieve the access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Retrieve the refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Clear all tokens (on logout)
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
  
  // Check if a user is logged in
  Future<bool> hasTokens() async {
    return await _storage.containsKey(key: _accessTokenKey);
  }
}