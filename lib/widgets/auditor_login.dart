import 'package:flutter/material.dart';
import 'package:innotegy/constants.dart';

class AuditorLogin
    extends
        StatelessWidget {
  const AuditorLogin({
    super.key,
  });

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
              'Manage your fields, sensors, and labor from the Auditor portal.',
            ),
            SizedBox(
              height: 30,
            ),

            TextField(
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
                                color: primaryOliveColor,
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
              keyboardType: TextInputType.visiblePassword,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
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
