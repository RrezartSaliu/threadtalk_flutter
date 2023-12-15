import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:threadtalk191521/screens/sign_up_page.dart';

import 'login_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Connecting minds, sparking conversations',
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                textStyle: const TextStyle(
                  fontSize: 24,
                ),
              )
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0DF099)),
              ),
              child: Text(
                'LOGIN',
                style: GoogleFonts.lexend(
                    fontSize: 32,
                    color: Colors.black
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(builder: (context) => const SignUpPage()), (route) => false);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0DF099)),
              ),
              child: Text(
                'REGISTER',
                style: GoogleFonts.lexend(
                    fontSize: 32,
                    color: Colors.black
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

