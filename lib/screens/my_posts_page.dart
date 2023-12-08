import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/Post.dart';
import '../utils/collapible_menu_item.dart';
import 'add_post_screen.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({Key? key}) : super(key: key);

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  bool isMenuOpen = false;
  late User currentUser;
  late List<Post> userPosts= [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser!;
      _getPostsData();
    });
  }

  Future<void> _getPostsData() async {
    DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

    // Access data from the DocumentSnapshot
    Map<String, dynamic>? userDataInner = userDocSnapshot.data() as Map<String, dynamic>?;


    if (userDataInner != null) {
      // Extract the 'posts' field from the user data
      List<dynamic>? userPostsData = userDataInner['posts'];

      if (userPostsData != null) {
        // Convert the list of map data to a list of Post objects
        List<Post> posts = userPostsData.map((postData) => Post.fromMap(postData)).toList();
        print('posts-------->${posts}');
        // Set the state with the list of Post objects
        setState(() {
          userPosts = posts;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: null,
        centerTitle: true,
        backgroundColor: const Color(0xFF0DF099),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 30.0),
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
          Positioned(
            left: 20.0,
            right: 20.0,
            top: 15.0,
            bottom: 15.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: Colors.black),
                color: const Color(0xFFFFF1F1), // Adjust the color as needed
                borderRadius:
                    BorderRadius.circular(10.0), // Adjust the radius as needed
              ),
              // ... rest of the container
              child: Column(children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    User? currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddPostScreen(myUser: currentUser)),
                      );
                    } else {
                      print('Current user is null');
                    }
                  },
                  child: Container(
                    width: 290,
                    height: 35,
                    decoration: BoxDecoration(
                        color: const Color(0xFF0DF099),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 1.0)),
                    child: const Center(
                        child: Text(
                      "Add Post",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: userPosts.length, // You might want to set itemCount to userPosts.length
                  itemBuilder: (BuildContext context, int index) {
                    Post post = userPosts[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 290,
                          height: 165,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2.0),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                          ),
                          child: Text(post.title),
                        ),
                        Container(
                          width: 290,
                          height: 45,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.black, width: 0.1),
                              right: BorderSide(color: Colors.black, width: 2.0),
                              bottom: BorderSide(color: Colors.black, width: 2.0),
                              left: BorderSide(color: Colors.black, width: 2.0),
                            ),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(0), bottom: Radius.circular(12.0)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                    border: Border(right: BorderSide(color: Colors.black, width: 2.0)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                    border: Border(right: BorderSide(color: Colors.black, width: 2.0)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: double.infinity,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10,)
                      ],
                    );
                  },
                ))

              ]),
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
                    const SizedBox(height: 30),
                    SearchBar(),
                    const SizedBox(height: 20),
                    MenuItem(text: 'Trending now'),
                    const SizedBox(height: 20),
                    MenuItem(
                        text: 'Profile',
                        onPressed: () {
                          Navigator.pushNamed(context, "/profile");
                        }),
                    const SizedBox(height: 20),
                    MenuItem(text: 'My Posts'),
                    const SizedBox(height: 20),
                    CollapsibleMenuItem(
                        text: 'Categories',
                        subItems: ['Item 1', 'Item 2', 'Item 3']),
                    const SizedBox(height: 20),
                    MenuItem(
                        text: 'Logout',
                        onPressed: () {
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
      child: const TextField(
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
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
