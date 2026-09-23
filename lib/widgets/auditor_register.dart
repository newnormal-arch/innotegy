import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/screens/auth_screen.dart';
import 'package:innotegy/services/auth_service.dart';

class AuditorRegister
    extends
        StatefulWidget {
  const AuditorRegister({
    super.key,
  });

  @override
  State<
    AuditorRegister
  >
  createState() => _AuditorRegisterState();
}

class _AuditorRegisterState
    extends
        State<
          AuditorRegister
        > {
  final TextEditingController auditorFullNameController = TextEditingController();
  final TextEditingController auditorEmailController = TextEditingController();
  final TextEditingController auditorPhoneNumberController = TextEditingController();
  final TextEditingController auditorPasswordController = TextEditingController();
  final TextEditingController auditorConfirmPasswordController = TextEditingController();
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),

              Text(
                'Welcome Auditor',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 10,
              ),

              Text(
                'Manage your fields, sensors, and labor from the Manager portal.',
              ),
              SizedBox(
                height: 30,
              ),
              TextField(
                controller: auditorFullNameController,
                keyboardType: TextInputType.name,
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
                                'Full Name',
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
                controller: auditorPhoneNumberController,
                keyboardType: TextInputType.phone,
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
                                'Phone Number',
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
                controller: auditorEmailController,
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
                controller: auditorPasswordController,
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

              TextField(
                controller: auditorConfirmPasswordController,
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
                                'Confirm Password',
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
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    EasyLoading.show(
                      status: 'Signing Up...',
                    );
                    try {
                      if (auditorPasswordController.text.trim() ==
                          auditorConfirmPasswordController.text.trim()) {
                        await authService.value
                            .signUp(
                              email: auditorEmailController.text.trim(),
                              password: auditorPasswordController.text.trim(),
                            )
                            .then(
                              (
                                value,
                              ) {
                                print(
                                  'User signed up successfully as Auditor: ${value.user?.uid}',
                                );
                                authService.value.saveAuditorData(
                                  fullName: auditorFullNameController.text,
                                  email: auditorEmailController.text,
                                  phone: auditorPhoneNumberController.text,
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
                                  'Auditor created successfully, Please login!',
                                );
                              },
                            );
                      } else {
                        EasyLoading.showError(
                          'Passwords don\'t match',
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
                    'Create Account',
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
    );
  }
}
