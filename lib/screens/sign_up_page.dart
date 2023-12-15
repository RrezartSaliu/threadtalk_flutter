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
        title: null,
        centerTitle: true,
        backgroundColor: const Color(0xFF0DF099),
        flexibleSpace: Center(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0.0),
            width: 140.0,
            height: 40.0,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFBE9),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 3)
                ),
              ],
            ),
            child: Center(
              child: Text(
                  'THREADTALK',
                  style: GoogleFonts.koulen(
                      fontSize: 26,
                      textStyle: const TextStyle(
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
                    color: const Color(0xFF0DF099),
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

      await addPostsToUser(userCredential.user!, [], displayName);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error: $e');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> addPostsToUser(User user, List<Post> posts, String displayName) async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    List<Map<String, dynamic>> postsData = posts.map((post) => post.toMap()).toList();

    await userDocRef.set({
      'displayName': displayName,
      'posts': postsData,
      'friends': [],
      'likedPosts': [],
      'comments': [],
      'bio': '',
      'birthDate': null,
      'profilePhoto': ''
    });
  }
}