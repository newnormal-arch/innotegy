import 'package:flutter/material.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/widgets/farmer_register.dart';

class RegisterScreen
    extends
        StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<
    RegisterScreen
  >
  createState() => _RegisterScreenState();
}

class _RegisterScreenState
    extends
        State<
          RegisterScreen
        > {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,

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
            vertical: 50,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 150,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Select your role to access your personalized dashboard.',
                ),
                SizedBox(
                  height: 20,
                ),
                DefaultTabController(
                  length: 1,
                  child: SizedBox(
                    height: 450,
                    child: Column(
                      children: [
                        TabBar(
                          indicatorColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          splashBorderRadius: BorderRadius.circular(
                            50,
                          ),
                          indicatorPadding: EdgeInsetsGeometry.all(
                            8,
                          ),
                          dividerHeight: 0.0,
                          unselectedLabelColor: Colors.black54,
                          labelColor: Colors.white,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              50,
                            ),
                            color: backgroundGreenColor,
                            shape: BoxShape.rectangle,
                          ),
                          tabs: [
                            Tab(
                              text: 'Farmer',
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              FarmerRegister(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
