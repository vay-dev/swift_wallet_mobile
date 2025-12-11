class User {
  final int id;
  final String phoneNumber;
  final String accountNumber;
  final String fullName;
  final bool isVerified;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.phoneNumber,
    required this.accountNumber,
    required this.fullName,
    required this.isVerified,
    this.profilePictureUrl,
  });

  // Factory method to create a User from the API response JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      phoneNumber: json['phone_number'] as String,
      accountNumber: json['account_number'] as String,
      fullName: json['full_name'] as String,
      isVerified: json['is_verified'] as bool,
      // Handle the profile picture URL if it exists
      profilePictureUrl: json['profile_picture'] as String?,
    );
  }

  // Method to check if the user is complete for the app
  bool get isAuthenticated => true;
}

// Model for the token response structure
class AuthTokens {
  final String refresh;
  final String access;

  AuthTokens({required this.refresh, required this.access});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      refresh: json['refresh'] as String,
      access: json['access'] as String,
    );
  }
}
