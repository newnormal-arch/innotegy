import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/screens/authentication_screen/forgot_password_screen.dart';
import 'package:innotegy/screens/authentication_screen/sign_up_screen.dart';
import 'package:innotegy/screens/consultant/manager_dashboard_screen.dart';
import 'package:innotegy/screens/farmer/farmer_dashboard_screen.dart';
import 'package:innotegy/services/authentication_service.dart';

class SignInScreen
    extends
        StatefulWidget {
  const SignInScreen({
    super.key,
  });

  @override
  State<
    SignInScreen
  >
  createState() => _SignInScreenState();
}

class _SignInScreenState
    extends
        State<
          SignInScreen
        > {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: LayoutBuilder(
        builder:
            (
              context,
              constraints,
            ) {
              // Responsive Breakpoint: Stack vertically if screen width < 900px
              final bool isMobile =
                  constraints.maxWidth <
                  900;

              if (isMobile) {
                return const SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 450,
                        child: HeroImageSection(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(
                          24.0,
                        ),
                        child: SignInFormSection(),
                      ),
                    ],
                  ),
                );
              }

              // Desktop/Tablet Split View
              return Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: HeroImageSection(),
                  ),
                  Expanded(
                    flex: 9,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 48.0,
                          vertical: 32.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 440,
                            ),
                            child: SignInFormSection(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
      ),
    );
  }
}

/// Left Hero Panel with Overlay Content & Stats
class HeroImageSection
    extends
        StatelessWidget {
  const HeroImageSection({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        Image.network(
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1600&q=80',
          fit: BoxFit.cover,
        ),
        // Gradient Overlay for Readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(
                  alpha: 0.3,
                ),
                Colors.black.withValues(
                  alpha: 0.7,
                ),
              ],
            ),
          ),
        ),
        // Content Layer
        Padding(
          padding: const EdgeInsets.all(
            40.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Header
              Image.asset(
                'assets/logo.png',
                width: 300,
              ),
              const Spacer(),
              // Main Tagline
              const Text(
                'Empowering the next\ngeneration of\nagriculture.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              // Subtitle Text
              Text(
                'Join thousands of farms worldwide using AgriManage to optimize yields, track sustainability, and collaborate with experts in real-time.',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.85,
                  ),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              const Divider(
                color: Colors.white24,
                height: 1,
              ),
              const SizedBox(
                height: 32,
              ),
              // Metrics / Stats
              const Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      value: '10+',
                      label: 'ACTIVE FARMS',
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      value: '98%',
                      label: 'COMPLIANCE RATE',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Footer / Copyright
              Text(
                '© 2026 Innotegy Solutions Inc.  •  Privacy  •  Global Operations',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.6,
                  ),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile
    extends
        StatelessWidget {
  final String value;
  final String label;

  const _StatTile({
    required this.value,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(
              alpha: 0.7,
            ),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

/// Right Side Sign-In Form (Tabs excluded)
class SignInFormSection
    extends
        StatefulWidget {
  const SignInFormSection({
    super.key,
  });

  @override
  State<
    SignInFormSection
  >
  createState() => _SignInFormSectionState();
}

class _SignInFormSectionState
    extends
        State<
          SignInFormSection
        > {
  // bool _rememberDevice = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<
    void
  >
  _handleSignIn() async {
    // Validate input fields first
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter both email and password.',
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

      // 1. Authenticate with Firebase Auth
      final UserCredential credential = await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user !=
          null) {
        // 2. Fetch the user's document from Firestore to check 'isActive' status
        final userDoc = await FirebaseFirestore.instance
            .collection(
              'users',
            )
            .doc(
              user.uid,
            )
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          final bool isActive =
              data?['isActive'] ??
              false;
          final String userRole =
              data?['userRole'] ??
              '';

          if (!isActive) {
            // Immediately sign out if the user is inactive
            await authService.signOut();

            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  'Your account is currently inactive. Please contact an admin for access.',
                ),
              ),
            );
            return;
          } else if (userRole ==
              'Field Worker') {
            // Navigate to the appropriate dashboard based on user role

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (
                      context,
                    ) => const FarmerDashboardScreen(),
              ),
            );
          } else if (userRole ==
              'Owner') {
            // Navigate to the appropriate dashboard based on user role
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (
                      context,
                    ) => const ManagerDashboardScreen(),
              ),
            );
          } else {
            // Default routing for other roles
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                backgroundColor: primaryGreenColor,
                content: Text(
                  'You have not been assigned a role. Please contact an admin for access.',
                ),
              ),
            );
          }

          // 3. Navigate to Dashboard if active
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              backgroundColor: primaryGreenColor,
              content: Text(
                'Logged In successfully. Redirecting to dashboard...',
              ),
            ),
          );
        } else {
          throw Exception(
            'User document not found.',
          );
        }
      }
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

  @override
  Widget build(
    BuildContext context,
  ) {
    const primaryColor = Color(
      0xFF1CB026,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sign In',
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
          'Select your role to access your personalized dashboard.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(
          height: 28,
        ),

        // Email Field
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
          height: 20,
        ),

        // Password Field Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(
                  0xFF333333,
                ),
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
                        ) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        // Password Field
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••',
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
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: Colors.grey[500],
              ),
              onPressed: () {
                setState(
                  () {
                    _obscurePassword = !_obscurePassword;
                  },
                );
              },
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
          height: 16,
        ),

        // Checkbox: Remember device
        // Row(
        //   children: [
        //     SizedBox(
        //       width: 20,
        //       height: 20,
        //       child: Checkbox(
        //         value: _rememberDevice,
        //         activeColor: primaryColor,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(
        //             4,
        //           ),
        //         ),
        //         side: BorderSide(
        //           color: Colors.grey[400]!,
        //         ),
        //         onChanged:
        //             (
        //               val,
        //             ) {
        //               setState(
        //                 () {
        //                   _rememberDevice =
        //                       val ??
        //                       false;
        //                 },
        //               );
        //             },
        //       ),
        //     ),
        //     const SizedBox(
        //       width: 10,
        //     ),
        //     Text(
        //       'Remember this device for 30 days',
        //       style: TextStyle(
        //         fontSize: 13,
        //         color: Colors.grey[700],
        //       ),
        //     ),
        //   ],
        // ),
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
                : _handleSignIn,
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In to MyInnotegy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(
          height: 36,
        ),

        // Footer Contact Link
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushReplacement(
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => SignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Create Account',
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
    );
  }
}
