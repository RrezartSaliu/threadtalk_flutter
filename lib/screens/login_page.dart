import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:threadtalk191521/screens/sign_up_page.dart';
import 'package:threadtalk191521/form_container_widget.dart';

import 'package:threadtalk191521/firebase_auth_services.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isSigning = false;



  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();


  @override
  void dispose() {
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
                  offset: const Offset(0, 3),
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
                "Login",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              const SizedBox(height: 10,),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              const SizedBox(height: 30,),
              GestureDetector(
                onTap: _signIn,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0DF099),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child:Text("Login",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
                ),
              ),
              const SizedBox(height: 20,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  const SizedBox(width: 5,),
                  GestureDetector(
                      onTap: (){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SignUpPage()), (route) => false);
                      },
                      child: const Text("Sign Up",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),))
                ],
              )


            ],
          ),
        ),
      ),
    );
  }

  void _signIn() async {

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user!= null){
      print("User is successfully signedIn");
      Navigator.pushNamed(context, "/profile");
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wrong credentials, Try again'),
        ),
      );
      print("Some error happend");
    }

  }
}