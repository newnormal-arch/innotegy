import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:innotegy/screens/authentication_screen/sign_in_screen.dart';
import 'package:innotegy/screens/consultant/manager_dashboard_screen.dart';
import 'package:innotegy/screens/farmer/farmer_dashboard_screen.dart';

void
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyBrwR47HoKHFTfSAmZbKCQ2UCfXG1nreY0',
      appId: '1:929404519467:web:df528bb2334d4dd31e566e',
      messagingSenderId: '929404519467',
      projectId: 'innotegy-saas',
    ),
  );

  runApp(
    const MyApp(),
  );
}

class MyApp
    extends
        StatelessWidget {
  const MyApp({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Innotegy SaaS',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.openSans().fontFamily,
      ),
      home: AuthGate(),
      builder: EasyLoading.init(),
    );
  }
}

class AuthGate
    extends
        StatelessWidget {
  const AuthGate({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return StreamBuilder<
      User?
    >(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder:
          (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const _LoadingScreen();
            }
            final user = snapshot.data;
            if (user ==
                null)
              return const SignInScreen();

            // Key by uid so a different user always gets a fresh role lookup
            return RoleRouter(
              key: ValueKey(
                user.uid,
              ),
              user: user,
            );
          },
    );
  }
}

class RoleRouter
    extends
        StatefulWidget {
  const RoleRouter({
    super.key,
    required this.user,
  });
  final User user;

  @override
  State<
    RoleRouter
  >
  createState() => _RoleRouterState();
}

class _RoleRouterState
    extends
        State<
          RoleRouter
        > {
  // Created once, so rebuilds don't re-hit Firestore
  late final Future<
    DocumentSnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  _userDoc = FirebaseFirestore.instance
      .collection(
        'users',
      )
      .doc(
        widget.user.uid,
      )
      .get();

  @override
  Widget build(
    BuildContext context,
  ) {
    return FutureBuilder<
      DocumentSnapshot<
        Map<
          String,
          dynamic
        >
      >
    >(
      future: _userDoc,
      builder:
          (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState !=
                ConnectionState.done) {
              return const _LoadingScreen();
            }
            if (snapshot.hasError) {
              return const _BlockedScreen(
                message: 'Something went wrong loading your account. Please try again.',
              );
            }

            final doc = snapshot.data!;
            if (!doc.exists) {
              return const _BlockedScreen(
                message: 'User document not found.',
              );
            }

            final data = doc.data();
            final isActive =
                data?['isActive'] ??
                false;
            final userRole =
                data?['userRole'] ??
                '';

            if (!isActive) {
              return const _BlockedScreen(
                message: 'Your account is currently inactive. Please contact an admin for access.',
              );
            }

            switch (userRole) {
              case 'Field Worker':
                return const FarmerDashboardScreen();
              case 'Owner':
                return const ManagerDashboardScreen();
              default:
                return const _BlockedScreen(
                  message: 'You have not been assigned a role. Please contact an admin for access.',
                );
            }
          },
    );
  }
}

class _LoadingScreen
    extends
        StatelessWidget {
  const _LoadingScreen();

  @override
  Widget
  build(
    BuildContext context,
  ) => const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

class _BlockedScreen
    extends
        StatelessWidget {
  const _BlockedScreen({
    required this.message,
  });
  final String message;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                // Signing out flips the gate back to LoginScreen
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text(
                  'Back to login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
