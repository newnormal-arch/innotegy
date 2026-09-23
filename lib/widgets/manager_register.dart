import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/screens/auth_screen.dart';
import 'package:innotegy/services/auth_service.dart';

class ManagerRegister
    extends
        StatefulWidget {
  const ManagerRegister({
    super.key,
  });

  @override
  State<
    ManagerRegister
  >
  createState() => _ManagerRegisterState();
}

class _ManagerRegisterState
    extends
        State<
          ManagerRegister
        > {
  final TextEditingController managerFullNameController = TextEditingController();
  final TextEditingController managerEmailController = TextEditingController();
  final TextEditingController managerPhoneNumberController = TextEditingController();
  final TextEditingController managerPasswordController = TextEditingController();
  final TextEditingController managerConfirmPasswordController = TextEditingController();
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
                'Manage your fields, sensors, and labor from the Manager portal.',
              ),
              SizedBox(
                height: 30,
              ),
              TextField(
                controller: managerFullNameController,
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
                controller: managerPhoneNumberController,
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
                controller: managerEmailController,
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
                controller: managerPasswordController,
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
                controller: managerConfirmPasswordController,
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
                      if (managerPasswordController.text.trim() ==
                          managerConfirmPasswordController.text.trim()) {
                        await authService.value
                            .signUp(
                              email: managerEmailController.text.trim(),
                              password: managerPasswordController.text.trim(),
                            )
                            .then(
                              (
                                value,
                              ) {
                                print(
                                  'User signed up successfully as Manager: ${value.user?.uid}',
                                );
                                authService.value.saveConsultantData(
                                  fullName: managerFullNameController.text,
                                  email: managerEmailController.text,
                                  phone: managerPhoneNumberController.text,
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
                                  'Manager created successfully, Please login!',
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
