import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/screens/consultant/consultant_dashboard.dart';
import 'package:innotegy/services/auth_service.dart';

class ConsultantLogin
    extends
        StatefulWidget {
  const ConsultantLogin({
    super.key,
  });

  @override
  State<
    ConsultantLogin
  >
  createState() => _ConsultantLoginState();
}

class _ConsultantLoginState
    extends
        State<
          ConsultantLogin
        > {
  final TextEditingController consultantEmailController = TextEditingController();

  final TextEditingController consultantPasswordController = TextEditingController();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),

            Text(
              'Welcome Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 10,
            ),

            Text(
              'Manage your fields, sensors, and labor from the Consultant portal.',
            ),
            SizedBox(
              height: 30,
            ),

            TextField(
              controller: consultantEmailController,
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

            TextField(
              controller: consultantPasswordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
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
                              'Password',
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

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: primaryOliveColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),

            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       EasyLoading.show(
            //         status: 'Signing In...',
            //       );
            //       try {
            //         await authService.value
            //             .signIn(
            //               email: consultantEmailController.text.trim(),
            //               password: consultantPasswordController.text.trim(),
            //             )
            //             .then(
            //               (
            //                 value,
            //               ) {
            //                 print(
            //                   'User signed in successfully as Manager: ${value.user?.uid}',
            //                 );
            //                 Navigator.of(
            //                   context,
            //                 ).pushReplacement(
            //                   MaterialPageRoute(
            //                     builder:
            //                         (
            //                           context,
            //                         ) => ConsultantDashboard(),
            //                   ),
            //                 );
            //                 EasyLoading.dismiss();
            //               },
            //             );
            //       } on FirebaseAuthException catch (
            //         e
            //       ) {
            //         print(
            //           'Error: ${e.message}',
            //         );
            //         EasyLoading.showError(
            //           e.message ??
            //               'An error occurred',
            //         );
            //       }
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: primaryGreenColor,
            //       padding: EdgeInsets.symmetric(
            //         horizontal: 40,
            //         vertical: 12,
            //       ),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(
            //           8,
            //         ),
            //       ),
            //     ),
            //     child: Text(
            //       'Sign In',
            //       style: TextStyle(
            //         fontWeight: FontWeight.w600,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  EasyLoading.show(
                    status: 'Signing In...',
                  );

                  try {
                    // Pass the target collection name to check
                    UserCredential userCredential = await authService.value.signIn(
                      email: consultantEmailController.text.trim(),
                      password: consultantPasswordController.text.trim(),
                      requiredCollection: 'consultant',
                    );

                    print(
                      'User signed in successfully as Consultant: ${userCredential.user?.uid}',
                    );
                    EasyLoading.dismiss();

                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushReplacement(
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) => const ConsultantDashboard(),
                        ),
                      );
                    }
                  } on FirebaseAuthException catch (
                    e
                  ) {
                    EasyLoading.showError(
                      e.message ??
                          'An error occurred during sign in',
                    );
                  } catch (
                    e
                  ) {
                    EasyLoading.showError(
                      'An unexpected error occurred.',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreenColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
