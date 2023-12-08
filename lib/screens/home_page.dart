import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Connecting minds, sparking conversations',
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  fontSize: 24,
                ),
              )
            ),
            SizedBox(height: 20), // Spacer
            ElevatedButton(
              onPressed: () {
                // Handle login button press
                Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0DF099)),
              ),
              child: Text(
                'LOGIN',
                style: GoogleFonts.lexend(
                    fontSize: 32,
                    color: Colors.black
                ),
              ),
            ),
            SizedBox(height: 20), // Spacer
            ElevatedButton(
              onPressed: () {
                // Handle login button press
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0DF099)),
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

