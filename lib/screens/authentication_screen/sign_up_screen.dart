import 'package:flutter/material.dart';
import 'package:innotegy/screens/authentication_screen/sign_in_screen.dart';
import 'package:innotegy/services/authentication_service.dart';
import 'shared_auth_layout.dart';

class SignUpScreen
    extends
        StatefulWidget {
  const SignUpScreen({
    super.key,
  });

  @override
  State<
    SignUpScreen
  >
  createState() => _SignUpScreenState();
}

class _SignUpScreenState
    extends
        State<
          SignUpScreen
        > {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;
  // Controllers for form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _handleSignUp() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Client-side Form Validations
    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all fields.',
          ),
        ),
      );
      return;
    }

    if (password !=
        confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match.',
          ),
        ),
      );
      return;
    }

    if (!_agreeTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'You must agree to the Terms of Service & Privacy Policy.',
          ),
        ),
      );
      return;
    }

    setState(
      () => _isLoading = true,
    );

    try {
      final authService = AuthenticationService();

      // 2. Call Auth Service (Creates Auth User + Firestore Doc with isActive: false)
      await authService.signUpWithEmailAndPassword(
        fullName: fullName,
        email: email,
        phoneNumber: phone,
        password: password,
      );

      if (!mounted) return;

      // 3. Show Success Dialog notifying the user their account is pending approval
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (
              context,
            ) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              title: const Text(
                'Account Created',
              ),
              content: const Text(
                'Your account has been successfully registered. An administrator needs to activate your account before you can log in.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(
                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) => const SignInScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Go to Sign In',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
      );
    } catch (
      e
    ) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString().replaceAll(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () => _isLoading = false,
        );
      }
    }
  }

  static const Color primaryColor = Color(
    0xFF1CB026,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return SharedAuthLayout(
      formSection: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(
                0xFF1A1A1A,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Join MyInnotegy today to manage your farm enterprise.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(
            height: 24,
          ),

          // Full Name
          _buildFieldLabel(
            'Full Name',
          ),
          const SizedBox(
            height: 8,
          ),
          _buildTextField(
            hint: 'John Doe',
            controller: _fullNameController,
          ),
          const SizedBox(
            height: 16,
          ),

          // Email Address
          _buildFieldLabel(
            'Email Address',
          ),
          const SizedBox(
            height: 8,
          ),
          _buildTextField(
            hint: 'name@innotegy.co.za',
            controller: _emailController,
          ),
          const SizedBox(
            height: 16,
          ),

          // Phone Number
          _buildFieldLabel(
            'Phone Number',
          ),
          const SizedBox(
            height: 8,
          ),
          _buildTextField(
            hint: '+27 00 000-0000',
            keyboardType: TextInputType.phone,
            controller: _phoneController,
          ),
          const SizedBox(
            height: 16,
          ),

          // Password
          _buildFieldLabel(
            'Password',
          ),
          const SizedBox(
            height: 8,
          ),
          _buildTextField(
            hint: '••••••••',
            obscureText: _obscurePassword,
            controller: _passwordController,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: Colors.grey[500],
              ),
              onPressed: () => setState(
                () => _obscurePassword = !_obscurePassword,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),

          // Confirm Password
          _buildFieldLabel(
            'Confirm Password',
          ),
          const SizedBox(
            height: 8,
          ),
          _buildTextField(
            hint: '••••••••',
            obscureText: _obscureConfirmPassword,
            controller: _confirmPasswordController,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: Colors.grey[500],
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),

          // Terms Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _agreeTerms,
                  activeColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      4,
                    ),
                  ),
                  side: BorderSide(
                    color: Colors.grey[400]!,
                  ),
                  onChanged:
                      (
                        val,
                      ) => setState(
                        () => _agreeTerms =
                            val ??
                            false,
                      ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Wrap(
                  children: [
                    Text(
                      'I agree to the ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Text(
                      'Terms of Service',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      ' and ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),

          // Footer Link back to Sign In
          Center(
            child: Wrap(
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(
                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) => const SignInScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(
    String label,
  ) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(
          0xFF333333,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: const Color(
          0xFFFAFAFA,
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8,
          ),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            8,
          ),
          borderSide: const BorderSide(
            color: primaryColor,
          ),
        ),
      ),
    );
  }
}
