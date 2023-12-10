import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:threadtalk191521/utils/menu_overlay.dart';
import 'package:threadtalk191521/utils/posts_listview.dart';
import '../models/Post.dart';
import '../utils/threadtalk_bar.dart';
import 'add_post_screen.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({Key? key}) : super(key: key);

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  bool isMenuOpen = false;
  late User currentUser;
  late Future<List<Post>>? userPostsFuture;
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser!;
      userPostsFuture = _getPostsData();
      _getUserData();
    });
  }

  Future<void> _getUserData() async {
    DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

    // Access data from the DocumentSnapshot
    Map<String, dynamic>? userDataInner = userDocSnapshot.data() as Map<String, dynamic>?;

    if (userDataInner != null) {
      // Print or use the data as needed
      setState(() {
        userData = userDataInner;
      });
    }
  }

  Future<List<Post>> _getPostsData() async {
    DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

    // Access data from the DocumentSnapshot
    Map<String, dynamic>? userDataInner = userDocSnapshot.data() as Map<String, dynamic>?;

    List<Post> posts = [];

    if (userDataInner != null) {
      // Extract the 'posts' field from the user data
      List<String>? userPostsIds = List<String>.from(userDataInner['posts'] ?? []);

      if (userPostsIds != null && userPostsIds.isNotEmpty) {
        // Use the post IDs to retrieve the actual post data from the 'posts' collection
        posts = await Future.wait(userPostsIds.map((postId) async {
          DocumentSnapshot postSnapshot = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
          print('id: '+'${postSnapshot.id}');
          Map<String, dynamic>? postMap = postSnapshot.data() as Map<String, dynamic>?;
          print('postid: '+'${postMap?['comments']}');
          if (postMap != null) {
            return Post.fromMap(postSnapshot.id, postMap);
          } else {
            // Handle the case where post data is missing or invalid
            return Post(null, title: 'Invalid Post', content: 'Invalid Post Data', user: currentUser, category: 'Invalid', comments: [], likes: 0);
          }
        }));
      }
    }

    // Use setState to initialize userPostsFuture
    setState(() {
      userPostsFuture = Future.value(posts);
    });

    return posts; // Return posts from the function
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: ThreadTalkBar(toggleMenu: () {
        setState(() {
          isMenuOpen = !isMenuOpen;
        });
      }
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
                  child: FutureBuilder<List<Post>>(
                    future: userPostsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return PostsView(posts: snapshot.data ?? [], userData: userData,);
                      }
                    },
                  ),
                ),

              ]),
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