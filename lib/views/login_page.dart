import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isSignUp = false;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isSignUp) {
        final success = await _authService.register(username, password);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please log in.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _isSignUp = false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username already exists.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        final success = await _authService.login(username, password);
        if (success) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid username or password.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF39FF14);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: neonGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: neonGreen.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(
                    Icons.sports_cricket,
                    size: 64,
                    color: neonGreen,
                  ),
                ),
                const SizedBox(height: 24),
                // App Title
                const Text(
                  'CRICSCORER',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Your Professional Score Tracker',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 40),
                // Card UI
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E222B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'Create Account' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                            filled: true,
                            fillColor: const Color(0xFF13161C),
                            prefixIcon: Icon(Icons.person_outline, color: Colors.white.withOpacity(0.5)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: neonGreen, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                            filled: true,
                            fillColor: const Color(0xFF13161C),
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.5)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: neonGreen, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 4) {
                              return 'Password must be at least 4 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Submit Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neonGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : Text(
                                  _isSignUp ? 'REGISTER' : 'LOG IN',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Toggle Login/SignUp
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _formKey.currentState?.reset();
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: neonGreen,
                          ),
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign In'
                                : "Don't have an account? Sign Up",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
