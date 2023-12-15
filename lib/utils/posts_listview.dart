import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/Post.dart';
import '../screens/add_comment_screen.dart';

class PostsView extends StatefulWidget {
  final List<Post> posts;
  final Map<String, dynamic> userData;
  const PostsView({Key? key, required this.posts, required this.userData}) : super(key: key);

  @override
  State<PostsView> createState() => _PostsViewState();
}

class _PostsViewState extends State<PostsView> {
  late String currentUserId;
  late Map<String,String> displayNameByUserId;

  Future<void> likeUnlikeFunction(User currentUser, String? postId) async {
    DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    DocumentSnapshot postSnapshot = await postRef.get();
    Map<String, dynamic>? postData = postSnapshot.data() as Map<String, dynamic>?;

    if (postData != null) {
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      if (widget.userData['likedPosts'].contains(postId)) {
        await postRef.update({'likes': FieldValue.increment(-1)});
        await usersCollection.doc(currentUser.uid).update({
          'likedPosts': FieldValue.arrayRemove([postId]),
        });
      } else {
        await postRef.update({'likes': FieldValue.increment(1)});
        await usersCollection.doc(currentUser.uid).update({
          'likedPosts': FieldValue.arrayUnion([postId]),
        });
      }

      setState(() {
        widget.userData['likedPosts'].contains(postId)
            ? widget.userData['likedPosts'].remove(postId)
            : widget.userData['likedPosts'].add(postId);

        int postIndex = widget.posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          widget.posts[postIndex].likes = postData['likes'] + (widget.userData['likedPosts'].contains(postId) ? 1 : -1);
        }
      });
    }
  }


  @override
  void initState() {
    super.initState();
    displayNameByUserId = {};
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    fetchData(users);
  }

  Future<void> fetchData(CollectionReference users) async {
    for (var post in widget.posts) {
      DocumentSnapshot userSnapshot = await users.doc(post.user).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('displayName')) {
        String displayName = userData['displayName'];
        displayNameByUserId.putIfAbsent(post.user, () => displayName);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget ContentText(String content, Post post) {
    if (content.length > 176) {
      return RichText(
        text: TextSpan(
          text: content.substring(0, 175),
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: '...read more',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Map<String,dynamic> nameAndPost = {};
                  nameAndPost.putIfAbsent('displayName', () => displayNameByUserId[post.user]);
                  nameAndPost.putIfAbsent('post', () => post);
                  Navigator.pushNamed(context, "/post_view", arguments: nameAndPost);
                },
              style: const TextStyle(
                color: Colors.green,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(content);
    }
  }




  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.posts.length,
      itemBuilder: (BuildContext context, int index) {
        Post post = widget.posts[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 290,
              height: 165,
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              ),
              child: Padding (
                padding: const EdgeInsets.only(left: 12, top: 12, bottom: 5, right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: GestureDetector(
                        onTap: (){
                          Map<String,dynamic> nameAndPost = {};
                          nameAndPost.putIfAbsent('displayName', () => displayNameByUserId[post.user]);
                          nameAndPost.putIfAbsent('post', () => post);
                          Navigator.pushNamed(context, "/post_view", arguments: nameAndPost);
                        },
                        child: Text(
                          post.title,
                          style: GoogleFonts.lexend(
                            fontSize: 17,
                          ),
                        ),
                      )
                    ),
                    SizedBox(height: 10,),
                    ContentText(post.content, post),
                    SizedBox(height: 5,),
                    Spacer(),
                    Row(
                      children: [
                        Text('posted by: '),
                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context, '/profile_view/${post.user}');
                          },
                          child: Text(
                            displayNameByUserId[post.user]??'',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              textStyle: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color(0xFF0DF099)
                              )
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
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
                      alignment: Alignment.center,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.black, width: 2.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await likeUnlikeFunction(FirebaseAuth.instance.currentUser!, post.id);
                            },
                            icon: Icon(
                              widget.userData['likedPosts'].contains(post.id) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                          Text(post.likes.toString()),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.black, width: 2.0)),
                      ),
                      child: Row(
                        children: [
                          IconButton(onPressed: () {
                            User? currentUser = FirebaseAuth.instance.currentUser;
                            if (currentUser != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddCommentScreen(myUser: currentUser, postId: post.id ?? 'no post')),
                              );
                            } else {
                              print('Current user is null');
                            }
                          }, icon: const Icon(Icons.insert_comment_outlined, color: Colors.black, size: 32,)),
                          Text(post.comments.length.toString())
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      child: IconButton(
                        onPressed: (){

                        },
                        icon: const Icon(
                          Icons.send
                        ),
                      )
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
          ],
        );
      },
    );
  }
}
