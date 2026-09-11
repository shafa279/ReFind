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
      final data = await ApiService.login(
        _collegeIdController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (data['success'] == true) {
        final String userId =
            data['user_id']?.toString() ??
                _collegeIdController.text.trim();

        final String role =
            data['role']?.toString() ?? 'student';

        AuthService.setUser(
          id: userId,
          userRole: role,
        );

        _showMessage(
          'Login successful! Welcome $userId.',
        );

        await Future.delayed(
          const Duration(milliseconds: 400),
        );

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacementNamed(
            context,
            '/admin',
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/',
          );
        }
      } else {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1050,
              ),
              child: isMobile
                  ? _buildMobileLayout(context)
                  : _buildDesktopLayout(context),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // DESKTOP LAYOUT
  // =========================

  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 560,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // =========================
          // LEFT BLUE SECTION
          // =========================

          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(48),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF101936),
                    Color(0xFF193B86),
                    Color(0xFF2864C7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LOGO
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2463D4),
                          borderRadius:
                              BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.arrow_outward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Text(
                        'ReFind',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    child: const Text(
                      'SMART CAMPUS LOST & FOUND',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // MAIN HEADING
                  const Text(
                    'Lost things deserve\na way home.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      height: 1.12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // DESCRIPTION
                  const Text(
                    'Log in to manage your reports, '
                    'review potential matches, and '
                    'reclaim what belongs to you.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // PRIVATE DETAILS
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white70,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Private details help verify ownership.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // RIGHT LOGIN SECTION
          // =========================

          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 55,
                vertical: 55,
              ),
              color: Colors.white,
              child: _buildLoginForm(context),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // MOBILE LAYOUT
  // =========================

  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildLoginForm(context),
    );
  }

  // =========================
  // LOGIN FORM
  // =========================

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF171717),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Log in to continue to ReFind.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),

        const SizedBox(height: 32),

        // COLLEGE ID
        const Text(
          'College ID',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _collegeIdController,
          textInputAction: TextInputAction.next,
          textCapitalization:
              TextCapitalization.characters,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Enter your College ID',
            prefixIcon: const Icon(
              Icons.badge_outlined,
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFF2457B8),
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // PASSWORD
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
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
              size: 20,
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
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFF2457B8),
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // LOGIN BUTTON
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF2457B8),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF9DB7E5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(13),
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
                          AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 18),

        // SECURITY NOTE
        Center(
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: Color(0xFF9CA3AF),
              ),
              SizedBox(width: 6),
              Text(
                'Your account information is kept secure.',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // BACK TO HOME
        Center(
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/',
              );
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 15,
              color: Color(0xFF6B7280),
            ),
            label: const Text(
              'Back to Home',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}