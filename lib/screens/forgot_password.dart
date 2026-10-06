import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/screens/auth_screen.dart';
import 'package:innotegy/services/auth_service.dart';

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
  final TextEditingController forgotEmailController = TextEditingController();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/auth-bg.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Card(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          color: Colors.white.withValues(
            alpha: 0.8,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 500,
            vertical: 250,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              16.0,
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 150,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Enter Your Email to Reset Password',
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: forgotEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        8.0,
                      ),
                    ),
                    label: Text.rich(
                      TextSpan(
                        children:
                            <
                              InlineSpan
                            >[
                              WidgetSpan(
                                child: Text(
                                  'Email Address',
                                ),
                              ),
                              WidgetSpan(
                                child: Text(
                                  ' *',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      EasyLoading.show(
                        status: 'Sending password reset email...',
                      );
                      try {
                        if (forgotEmailController.text.trim() !=
                            '') {
                          await authService.value
                              .resetPassword(
                                email: forgotEmailController.text.trim(),
                              )
                              .then(
                                (
                                  value,
                                ) {
                                  print(
                                    'Password reset email sent, Please check your inbox!',
                                  );
                                  Navigator.of(
                                    context,
                                  ).pushReplacement(
                                    MaterialPageRoute(
                                      builder:
                                          (
                                            context,
                                          ) => AuthScreen(),
                                    ),
                                  );

                                  EasyLoading.showSuccess(
                                    'Password reset email sent, Please check your inbox!',
                                  );
                                },
                              );
                        } else {
                          EasyLoading.showError(
                            'Enter valid email address',
                          );
                        }
                      } on FirebaseAuthException catch (
                        e
                      ) {
                        print(
                          'Error: ${e.message}',
                        );
                        EasyLoading.showError(
                          e.message ??
                              'An error occurred',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreenColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
