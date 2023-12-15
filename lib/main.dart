import 'package:flutter/material.dart';
import 'package:threadtalk191521/screens/categories_page.dart';
import 'package:threadtalk191521/screens/categories_post_page.dart';
import 'package:threadtalk191521/screens/my_posts_page.dart';
import 'package:threadtalk191521/screens/my_profile_page.dart';
import 'package:threadtalk191521/screens/posts_view.dart';
import 'package:threadtalk191521/screens/profile_view.dart';
import 'package:threadtalk191521/splash_screen.dart';
import 'package:threadtalk191521/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:threadtalk191521/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';




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
      title: 'ThreadTalk',
      routes: {
        '/': (context) => const SplashScreen(
          child: HomePage(),
        ),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const MyProfilePage(),
        '/my_posts': (context) => const MyPostsPage(),
        '/categories': (context) => const CategoriesPage(),
        '/post_view': (context) => const PostView()
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/categoriesposts/')) {
          final category = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => CategoriesPostPage(category: category),
          );
        }
        if (settings.name != null && settings.name!.startsWith('/profile_view/')) {
          final profile = settings.name!.split('/').last;
          if(profile.compareTo(FirebaseAuth.instance.currentUser!.uid) != 0) {
            return MaterialPageRoute(
            builder: (context) => ProfilePage(userId: profile,),
          );
          }
          else{
            return MaterialPageRoute(builder: (context) => MyProfilePage());
          }
        }
        return null;
      },
    );
  }
}