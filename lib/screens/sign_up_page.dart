import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:threadtalk191521/firebase_auth_services.dart';
import 'package:threadtalk191521/screens/login_page.dart';
import 'package:threadtalk191521/form_container_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Post.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();


  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null, // Set title to null to make room for flexibleSpace
        centerTitle: true,
        backgroundColor: Color(0xFF0DF099),
        flexibleSpace: Center(
          child: Container(
            margin: EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0.0),
            width: 140.0, // Adjust the width as needed
            height: 40.0, // Adjust the height as needed
            padding: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: Color(0xFFFAFBE9), // Color for the rectangle
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Shadow color
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Offset in the x, y axis
                ),
              ],
            ),
            child: Center(
              child: Text(
                  'THREADTALK',
                  style: GoogleFonts.koulen(
                      fontSize: 26,
                      textStyle: TextStyle(
                          fontWeight: FontWeight.bold
                      )
                  )
              ),
            ),
          ),
        ),
        elevation: 7.0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Sign Up",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _usernameController,
                hintText: "Username",
                isPasswordField: false,
              ),
              const SizedBox(
                height: 10,
              ),
              FormContainerWidget(

                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              const SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _passwordController,

                hintText: "Password",
                isPasswordField: true,
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: _signUp,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Color(0xFF0DF099),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              const SizedBox(height: 20,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 5,),
                  GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
                      },
                      child: const Text("Login", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await signUpWithEmailAndPassword(email, password, username);


    if (user!= null){
      print("User is successfully created");
      Navigator.pushNamed(context, "/home");
    } else{
      print("Some error happend");
    }

  }

  Future<User?> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name

      // Optionally, you can also update other user profile information like photoURL
      // await userCredential.user!.updatePhotoURL('url_to_user_photo');

      await addPostsToUser(userCredential.user!, [], displayName);

      // Return the user
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error: $e');
      // Handle errors such as email already in use, weak password, etc.
      return null;
    } catch (e) {
      print('Error: $e');
      // Handle other errors
      return null;
    }
  }

  Future<void> addPostsToUser(User user, List<Post> posts, String displayName) async {
    // Reference to Firestore document for the user
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Convert posts to a list of maps
    List<Map<String, dynamic>> postsData = posts.map((post) => post.toMap()).toList();

    print(user.displayName);
    // Add the list of posts to the user's document
    await userDocRef.set({
      'displayName': displayName,
      'posts': postsData,
      'friends': [],
      'likedPosts': [],
      'comments': []
    });
  }
}