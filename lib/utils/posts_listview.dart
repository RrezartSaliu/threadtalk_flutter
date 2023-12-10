import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  Future<void> likeUnlikeFunction(User currentUser, String? postId) async {
    DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    DocumentSnapshot postSnapshot = await postRef.get();
    Map<String, dynamic>? postData = postSnapshot.data() as Map<String, dynamic>?;

    if (postData != null) {
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      if (widget.userData['likedPosts'].contains(postId)) {
        // Unlike the post
        await postRef.update({'likes': FieldValue.increment(-1)});
        await usersCollection.doc(currentUser.uid).update({
          'likedPosts': FieldValue.arrayRemove([postId]),
        });
      } else {
        // Like the post
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
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
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
                      child: Row(
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
                          }, icon: Icon(Icons.insert_comment_outlined, color: Colors.black, size: 32,)),
                          Text(post.comments.length.toString())
                        ],
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
    );
  }
}
