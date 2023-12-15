import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/Post.dart';
import '../utils/menu_overlay.dart';
import '../utils/posts_listview.dart';
import '../utils/threadtalk_bar.dart';

class CategoriesPostPage extends StatefulWidget{
  final String category;
  const CategoriesPostPage({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoriesPostPage> createState() => _CategoriesPostPageState();
}

class _CategoriesPostPageState extends State<CategoriesPostPage>{
  bool isMenuOpen = false;
  late User currentUser;
  late Future<List<Post>>? postsFuture;
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser!;
      postsFuture = _getPostsData();
      _getUserData();
    });
  }

  Future<void> _getUserData() async {
    DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

    Map<String, dynamic>? userDataInner = userDocSnapshot.data() as Map<String, dynamic>?;

    if (userDataInner != null) {
      setState(() {
        userData = userDataInner;
      });
    }
  }

  Future<List<Post>> _getPostsData() async {
    CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

    try {
      QuerySnapshot postsSnapshot = await postsCollection.get();

      List<Post> posts = postsSnapshot.docs.map((doc) {
        return Post.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      List<Post> filteredPosts = posts.where((post) => post.category == widget.category).toList();
      return filteredPosts;
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
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
                color: const Color(0xFFFFF1F1),
                borderRadius:
                BorderRadius.circular(10.0),
              ),
              child: Column(children: [
                const SizedBox(height: 10),
                Container(
                  width: 290,
                  height: 35,
                  decoration: BoxDecoration(
                      color: const Color(0xFF0DF099),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.0)),
                  child: Center(
                      child: Text(
                        widget.category,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: FutureBuilder<List<Post>>(
                    future: postsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
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