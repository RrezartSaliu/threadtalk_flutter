import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:threadtalk191521/screens/my_posts_page.dart';
import 'package:threadtalk191521/screens/my_profile_page.dart';
import 'package:threadtalk191521/splash_screen.dart';
import 'package:threadtalk191521/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:threadtalk191521/firebase_options.dart';




import 'screens/login_page.dart';



Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      routes: {
        '/': (context) => const SplashScreen(
          // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
          child: HomePage(),
        ),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const MyProfilePage(),
        '/my_posts': (context) => const MyPostsPage()
      },
    );
  }
}