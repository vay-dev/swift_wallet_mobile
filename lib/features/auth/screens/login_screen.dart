import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swift_wallet_mobile/features/auth/auth_notifiers.dart'; // Ensure authProvider is available

class LoginScreen extends ConsumerStatefulWidget {
  // <-- Change to Stateful
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(
    text: '+1234567890',
  ); // Pre-fill for testing
  final _passwordController = TextEditingController(
    text: '123456',
  ); // Pre-fill for testing

  // Note: Your backend requires device info
  final _deviceId = 'web-debug-12345';
  final _deviceName = 'Chrome Debug Browser';

  String? _errorMessage;

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

    setState(() {
      _errorMessage = null; // Clear previous errors
    });

    final notifier = ref.read(
      authProvider.notifier,
    ); // Use the correct provider name

    final error = await notifier.login(
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      deviceId: _deviceId,
      deviceName: _deviceName,
    );

    if (error != null) {
      // Login failed, show the error message
      setState(() {
        _errorMessage = error;
      });
      // Optionally show a SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // If successful, the AuthNotifier updates the state, and the GoRouter
    // automatically navigates to /dashboard. We do NOT need to call context.go.
  }

  @override
  Widget build(BuildContext context) {
    // Watch the loading state to disable the button
    final isLoading = ref.watch(
      authProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            // Wrap the inputs in a Form
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // ... (Title/Logo Area - keep as is) ...

                // 1. Phone Number Input
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.startsWith('+')) {
                      return 'Please enter a valid international phone number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 2. Password Input
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password (6 digits)',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility_off),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.length != 6) {
                      return 'Password must be exactly 6 digits.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // 3. Login Button
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : _handleLogin, // Disable if loading
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      55,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        15.0,
                      ),
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // ... (Signup Link - keep as is) ...
              ],
            ),
          ),
        ),
      ),
    );
  }
}
