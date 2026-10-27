import 'package:flutter/material.dart';
import 'package:innotegy/screens/authentication_screen/sign_in_screen.dart';
import 'package:innotegy/services/authentication_service.dart';
import 'shared_auth_layout.dart';

class ForgotPasswordScreen
    extends
        StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<
    ForgotPasswordScreen
  >
  createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends
        State<
          ForgotPasswordScreen
        > {
  bool _submitted = false;
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email address.',
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

      // Send reset email via Firebase Auth
      await authService.sendPasswordResetEmail(
        email,
      );

      if (!mounted) return;

      // Transition screen view to success state
      setState(
        () {
          _submitted = true;
        },
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
      formSection: _submitted
          ? _buildConfirmationState()
          : _buildRequestForm(),
    );
  }

  Widget _buildRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Forgot Password?',
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
          'Enter your registered email address below and we will send you instructions to reset your password.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(
          height: 28,
        ),

        const Text(
          'Email Address',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(
              0xFF333333,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'name@innotegy.co.za',
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
        ),
        const SizedBox(
          height: 24,
        ),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              _isLoading
                  ? null
                  : _handleForgotPassword;
              setState(
                () => _submitted = true,
              );
            },
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
                    'Send Reset Link',
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

        Center(
          child: GestureDetector(
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: primaryColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Back to Sign In',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: primaryColor.withValues(
              alpha: 0.1,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 32,
            color: primaryColor,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(
              0xFF1A1A1A,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'We have sent password reset instructions to your email address.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(
          height: 28,
        ),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => setState(
              () => _submitted = false,
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: Colors.grey[300]!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
            ),
            child: const Text(
              'Resend Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(
                  0xFF333333,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),

        GestureDetector(
          onTap: () {
            // Navigator.pop(context) or navigate to Sign In
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
            'Back to Sign In',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
