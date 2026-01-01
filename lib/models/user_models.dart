class User {
  final int id;
  final String phoneNumber;
  final String accountNumber;
  final String fullName;
  final String? email;
  final bool isVerified; // Face verification status
  final bool isActive;
  final String? profilePictureUrl;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  final String walletBalance;

  User({
    required this.id,
    required this.phoneNumber,
    required this.accountNumber,
    required this.fullName,
    this.email,
    required this.isVerified,
    required this.isActive,
    this.profilePictureUrl,
    this.dateJoined,
    this.lastLogin,
    required this.walletBalance,
  });

  // Factory method to create a User from the API response JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      phoneNumber: json['phone_number'] as String,
      accountNumber: json['account_number'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      profilePictureUrl: json['profile_picture'] as String?,
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'] as String)
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      walletBalance: '',
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'account_number': accountNumber,
      'full_name': fullName,
      'email': email,
      'is_verified': isVerified,
      'is_active': isActive,
      'profile_picture': profilePictureUrl,
      'date_joined': dateJoined?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
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
