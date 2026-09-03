import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:innotegy/screens/auth_screen.dart';

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
      home: AuthScreen(),
      builder: EasyLoading.init(),
    );
  }
}
