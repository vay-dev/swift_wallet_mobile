import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_wallet_mobile/features/auth/auth_notifiers.dart';
import 'package:swift_wallet_mobile/core/router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '');
  final _passwordController = TextEditingController(
    text: '',
  );

  // Country code selection
  String _selectedCountryCode = '+1';
  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'flag': '🇺🇸', 'country': 'USA'},
    {'code': '+234', 'flag': '🇳🇬', 'country': 'Nigeria'},
    {'code': '+44', 'flag': '🇬🇧', 'country': 'UK'},
    {'code': '+91', 'flag': '🇮🇳', 'country': 'India'},
    {'code': '+86', 'flag': '🇨🇳', 'country': 'China'},
  ];

  // Password visibility toggle
  bool _obscurePassword = true;

  // Device info
  final _deviceId = 'web-debug-12345';
  final _deviceName = 'Chrome Debug Browser';

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(authProvider.notifier);

    // Combine country code with phone number
    final fullPhoneNumber =
        _selectedCountryCode + _phoneController.text.trim();

    final error = await notifier.login(
      phoneNumber: fullPhoneNumber,
      password: _passwordController.text.trim(),
      deviceId: _deviceId,
      deviceName: _deviceName,
    );

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Login successful - navigate to dashboard
      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authProvider.select((state) => state.isLoading),
    );
    final primaryColor = Theme.of(
      context,
    ).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(
                              0.3,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons
                            .account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log in to your Swift Wallet account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),

                  // Phone Number Input with Country Code
                  Text(
                    'Phone Number',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Country Code Dropdown
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                          ),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCountryCode =
                                    newValue!;
                              });
                            },
                            items: _countryCodes.map((
                              country,
                            ) {
                              return DropdownMenuItem<
                                String
                              >(
                                value: country['code'],
                                child: Row(
                                  children: [
                                    Text(
                                      country['flag']!,
                                      style:
                                          const TextStyle(
                                            fontSize: 20,
                                          ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      country['code']!,
                                      style:
                                          const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Phone Number Field
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: '1234567890',
                            prefixIcon: const Icon(
                              Icons.phone,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            enabledBorder:
                                OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
                                  borderSide: BorderSide(
                                    color:
                                        Colors.grey[300]!,
                                  ),
                                ),
                            focusedBorder:
                                OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length < 7) {
                              return 'Phone number is too short';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Password Input (6-digit PIN)
                  Text(
                    'PIN',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Enter your 6-digit PIN',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your PIN';
                      }
                      if (value.length != 6) {
                        return 'PIN must be exactly 6 digits';
                      }
                      if (!RegExp(
                        r'^\d{6}$',
                      ).hasMatch(value)) {
                        return 'PIN must contain only numbers';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        56,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                          )
                        : const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.signup);
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
