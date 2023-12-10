import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:threadtalk191521/utils/menu_overlay.dart';
import 'package:threadtalk191521/utils/threadtalk_bar.dart';


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
      appBar: ThreadTalkBar(toggleMenu: () {
        setState(() {
          isMenuOpen = !isMenuOpen;
        });
      }
      ),
      body: Stack(
        children: [
          // Your main content goes here

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
          if(isMenuOpen)
          MenuOverlay(
            toggleMenu: () {
              setState(() {
                isMenuOpen = !isMenuOpen;
              });
            },
          )
          
        ],
      ),
    );

  }
}
