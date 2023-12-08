import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/collapible_menu_item.dart';
import 'my_posts_page.dart';


class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);


  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage>{
  bool isMenuOpen = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user;
  late DocumentSnapshot userDoc;
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    user = _auth.currentUser;
    DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();

    // Access data from the DocumentSnapshot
    Map<String, dynamic>? userDataInner = userDocSnapshot.data() as Map<String, dynamic>?;

    if (userDataInner != null) {
      // Print or use the data as needed
      setState(() {
        userData = userDataInner;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: null,
        centerTitle: true,
        backgroundColor: Color(0xFF0DF099),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, size: 30.0),
            color: Colors.black,
            onPressed: () {
              setState(() {
                isMenuOpen = !isMenuOpen;
              });
            },
          ),
        ],
        flexibleSpace: Center(
          child: Container(
            margin: EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0.0),
            width: 140.0,
            height: 40.0,
            padding: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: Color(0xFFFAFBE9),
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
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        elevation: 7.0,
      ),
      body: Stack(
        children: [
          // Your main content goes here
          if (userData != null) // Check if userData is not null
            Positioned(
              left: 20.0,
              right: 20.0,
              top: 15.0,
              bottom: 15.0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2.0, color: Colors.black),
                  color: Color(0xFFFFF1F1), // Adjust the color as needed
                  borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                ),
                // ... rest of the container
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.person, size: 60), // Larger size for profile icon
                          onPressed: () {
                            // Add functionality for the profile icon here
                          },
                        ),
                        SizedBox(width: 10,),
                        IconButton(
                          icon: Icon(Icons.add, size: 30), // Smaller size for plus icon
                          onPressed: () {
                            // Add functionality for the plus icon here
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      userData?['displayName'] ?? 'No display name',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'BIO: '+(userData?['bio'] ?? 'No bio yet'),
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Birthdate: '+ (userData?['birthDate'] ?? 'No birthdate yet'),
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20), // Adjust the height as needed
                    ElevatedButton(
                      onPressed: () {
                        // Add functionality for the button here
                        //TODO
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFAFBE9)),
                      ),
                      child: Text('Friends (${userData?['friends']?.length.toString() ?? '0'})', style: TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
              ),
            ),

          // Black overlay
          if (isMenuOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  isMenuOpen = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.95),
              ),
            ),
          if (isMenuOpen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView(
                  children: [
                    SizedBox(height: 30),
                    SearchBar(),
                    SizedBox(height: 20),
                    MenuItem(text: 'Trending now'),
                    SizedBox(height: 20),
                    MenuItem(text: 'Profile'),
                    SizedBox(height: 20),
                    MenuItem(text: 'My Posts', onPressed: () {setState(() {
                      isMenuOpen = false;
                    }); Navigator.pushNamed(context, "/my_posts");},),
                    SizedBox(height: 20),
                    CollapsibleMenuItem(text: 'Categories', subItems: ['Item 1', 'Item 2', 'Item 3']),
                    SizedBox(height: 20),
                    MenuItem(text: 'Logout', onPressed: () {
                      // Handle logout button press
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  MenuItem({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

