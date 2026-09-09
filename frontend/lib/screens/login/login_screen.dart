import 'package:flutter/material.dart';

import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login will be connected to the backend later.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 48,
              vertical: isMobile ? 24 : 48,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: isMobile
                  ? _buildMobileLayout(context)
                  : _buildDesktopLayout(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SizedBox(
      height: 620,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFE8E9F0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: _buildBrandPanel()),
            SizedBox(
              width: 470,
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: _buildLoginForm(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogo(light: false),
        const SizedBox(height: 32),
        const Text(
          'Welcome back.',
          style: TextStyle(
            color: Color(0xFF171A2B),
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Log in to manage your lost and found reports.',
          style: TextStyle(
            color: Color(0xFF686B78),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE8E9F0),
            ),
          ),
          child: _buildLoginForm(context),
        ),
      ],
    );
  }

  Widget _buildBrandPanel() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: const BoxDecoration(
        color: Color(0xFF171A2B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(27),
          bottomLeft: Radius.circular(27),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(light: true),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF6C4EFF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'SMART CAMPUS LOST & FOUND',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Lost things deserve a way home.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Log in to manage reports, review potential matches, and verify ownership safely.',
            style: TextStyle(
              color: Color(0xFFD0D2DE),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const Spacer(),
          const Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFA997FF),
                size: 18,
              ),
              SizedBox(width: 9),
              Text(
                'Private details stay protected.',
                style: TextStyle(
                  color: Color(0xFFD0D2DE),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo({required bool light}) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: light
                ? const Color(0xFF6C4EFF)
                : const Color(0xFF171A2B),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.arrow_outward_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'ReFind',
          style: TextStyle(
            color: light ? Colors.white : const Color(0xFF171A2B),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Log in to your account',
            style: TextStyle(
              color: Color(0xFF171A2B),
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use your college email to continue.',
            style: TextStyle(
              color: Color(0xFF686B78),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          const _InputLabel(label: 'College Email'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (value) {
              final email = value?.trim() ?? '';

              if (email.isEmpty) return 'Enter your college email.';
              if (!email.contains('@')) return 'Enter a valid email address.';

              return null;
            },
            decoration: _inputDecoration(
              hintText: 'you@college.edu',
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 22),
          const _InputLabel(label: 'Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.password],
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Enter your password.';
              }

              return null;
            },
            decoration: _inputDecoration(
              hintText: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              ),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Log In',
            icon: Icons.login_rounded,
            fullWidth: true,
            onPressed: _login,
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Authentication will be connected to the backend.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8A8D99),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF686B78),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF9FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE1E3EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE1E3EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFF6C4EFF),
          width: 1.5,
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;

  const _InputLabel({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF171A2B),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}