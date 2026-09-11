import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _collegeIdController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _collegeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================
  // LOGIN
  // =========================

  Future<void> _login() async {
    // Check if fields are empty
    if (_collegeIdController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showMessage(
        'Please enter your College ID and password.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send login request through ApiService
      final data = await ApiService.login(
        _collegeIdController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // =========================
      // LOGIN SUCCESS
      // =========================

      if (data['success'] == true) {
        final String userId =
            data['user_id']?.toString() ??
            _collegeIdController.text.trim();

        final String role =
            data['role']?.toString() ?? 'student';

        // Save logged-in user
        AuthService.setUser(
          id: userId,
          userRole: role,
        );

        _showMessage(
          'Login successful! Welcome $userId.',
        );

        // Give the SnackBar a moment to appear
        await Future.delayed(
          const Duration(milliseconds: 400),
        );

        if (!mounted) return;

        // =========================
        // ADMIN
        // =========================

        if (role == 'admin') {
          Navigator.pushReplacementNamed(
            context,
            '/admin',
          );
        }

        // =========================
        // STUDENT
        // =========================

        else {
          Navigator.pushReplacementNamed(
            context,
            '/',
          );
        }
      }

      // =========================
      // LOGIN FAILED
      // =========================

      else {
        _showMessage(
          data['message'] ??
              'Invalid College ID or password.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Could not connect to the ReFind backend.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =========================
  // SHOW MESSAGE
  // =========================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Column(
                children: [
                  // =========================
                  // LOGO
                  // =========================

                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // TITLE
                  // =========================

                  const Text(
                    'Welcome to ReFind',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF171717),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Find it. Verify it. Reclaim it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // =========================
                  // LOGIN CARD
                  // =========================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // =========================
                        // LOGIN TITLE
                        // =========================

                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF171717),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Use your College ID to continue.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // =========================
                        // COLLEGE ID
                        // =========================

                        const Text(
                          'College ID',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: _collegeIdController,
                          textInputAction:
                              TextInputAction.next,
                          textCapitalization:
                              TextCapitalization.characters,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: 'Enter your College ID',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                            ),
                            filled: true,
                            fillColor:
                                const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(
                                color: Color(0xFF4F46E5),
                                width: 1.5,
                              ),
                            ),
                            disabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =========================
                        // PASSWORD
                        // =========================

                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction:
                              TextInputAction.done,
                          enabled: !_isLoading,
                          onSubmitted: (_) {
                            if (!_isLoading) {
                              _login();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your password',

                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                            ),

                            suffixIcon: IconButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _obscurePassword =
                                            !_obscurePassword;
                                      });
                                    },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),

                            filled: true,
                            fillColor:
                                const Color(0xFFF9FAFB),

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),

                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),

                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(
                                color: Color(0xFF4F46E5),
                                width: 1.5,
                              ),
                            ),

                            disabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // =========================
                        // LOGIN BUTTON
                        // =========================

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _login(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF4F46E5),
                              foregroundColor:
                                  Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFFA5B4FC),
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: size.height < 700
                        ? 16
                        : 32,
                  ),

                  // =========================
                  // FOOTER
                  // =========================

                  const Text(
                    'ReFind • College Lost & Found',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
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