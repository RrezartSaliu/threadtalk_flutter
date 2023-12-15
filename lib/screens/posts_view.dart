import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/Comment.dart';
import '../models/Post.dart';
import '../utils/menu_overlay.dart';
import '../utils/threadtalk_bar.dart';
import 'add_comment_screen.dart';

class PostView extends StatefulWidget{
  const PostView({Key? key}) : super(key: key);

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  bool isMenuOpen = false;
  late String displayName;
  late Post post;
  late Map<String, dynamic> userData = {};
  bool isExpanded = false;
  late Future<List<Comment>>? postCommentsFuture;
  late Map<String, String> displayNameByUserId = {};
  bool commentsFetched = false;

  Future<void> likeUnlikeFunction(User currentUser) async {
    DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(post.id);

    DocumentSnapshot postSnapshot = await postRef.get();
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    if (userData['likedPosts'].contains(post.id)) {

      await postRef.update({'likes': FieldValue.increment(-1)});
      await usersCollection.doc(currentUser.uid).update({
        'likedPosts': FieldValue.arrayRemove([post.id]),
      });
    } else {
      await postRef.update({'likes': FieldValue.increment(1)});
      await usersCollection.doc(currentUser.uid).update({
        'likedPosts': FieldValue.arrayUnion([post.id]),
      });
    }

    setState(() {
      userData['likedPosts'].contains(post.id)
          ? userData['likedPosts'].remove(post.id)
          : userData['likedPosts'].add(post.id);

      post.likes = post.likes + (userData['likedPosts'].contains(post.id) ? 1 : -1);
    });
    }

  Future<void> fetchData(CollectionReference users) async {
    List<Comment> comments = [];

    if (postCommentsFuture != null) {
      List<Comment>? commentsData = await postCommentsFuture;

      if (commentsData != null) {
        comments = commentsData;
      }
    }

    for (Comment comment in comments) {
      DocumentSnapshot userSnapshot = await users.doc(comment.user).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('displayName')) {
        String displayName = userData['displayName'];
        displayNameByUserId.putIfAbsent(comment.user, () => displayName);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }



  Future<List<Comment>> _getCommentsData() async {
    List<Comment> comments = [];

    for (String commentId in post.comments) {
      DocumentReference commentRef =
      FirebaseFirestore.instance.collection('comments').doc(commentId);

      DocumentSnapshot commentSnapshot = await commentRef.get();

      if (commentSnapshot.exists) {
        Comment comment = Comment.fromMap(commentSnapshot.data() as Map<String, dynamic>);
        comments.add(comment);
      }
    }

    return comments;
  }


  Future<void> _getUserData() async {
    DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(post.user).get();

    Map<String, dynamic>? userDataInner = userDocSnapshot.data() as Map<String, dynamic>?;

    if (userDataInner != null) {
      setState(() {
        userData = userDataInner;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Map<String, dynamic> arguments =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    displayName = arguments['displayName'];
    post = arguments['post'];

    if (!commentsFetched && post.comments.isNotEmpty) {
      postCommentsFuture = _getCommentsData();
      commentsFetched = true;
    }

    _getUserData();
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    fetchData(users);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThreadTalkBar(
        toggleMenu: () {
          setState(() {
            isMenuOpen = !isMenuOpen;
          });
        },
      ),
      body: Stack(
        children: [
          Positioned(
            left: 20.0,
            right: 20.0,
            top: 15.0,
            bottom: 15.0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 3.0),
              decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: Colors.black),
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10,),
                    Container(
                      width: 290,
                      height: 470,
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
                            Text(
                              post.title,
                              style: GoogleFonts.lexend(
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Text(
                              post.content,
                              style: GoogleFonts.lexend(
                                fontSize: 15.0
                              ),
                            ),
                            const SizedBox(height: 5,),
                            const Spacer(),
                            Row(
                              children: [
                                const Text('posted by: '),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pushNamed(context, '/profile_view/${post.user}');
                                  },
                                  child: Text(
                                    displayName ?? '',
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
                              height: double.infinity,
                              decoration: const BoxDecoration(
                                border: Border(right: BorderSide(color: Colors.black, width: 2.0)),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await likeUnlikeFunction(FirebaseAuth.instance.currentUser!);
                                    },
                                    icon: Icon(
                                      (userData['likedPosts'] ?? []).contains(post.id) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
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
                              child: IconButton(onPressed: () {
                                User? currentUser = FirebaseAuth.instance.currentUser;
                                if (currentUser != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddCommentScreen(myUser: currentUser, postId: post.id ?? 'no post')),
                                  );
                                } else {

                                }
                              }, icon: const Icon(Icons.insert_comment_outlined, color: Colors.black, size: 32,)),
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
                    const SizedBox(height: 5,),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Container (
                        width: 290,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2.0),
                            borderRadius: const BorderRadius.all(Radius.circular(12.0))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Comments (${post.comments.length})'),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 18,
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5,),
                    if (isExpanded)
                      FutureBuilder<List<Comment>>(
                        future: postCommentsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<Comment> comments = snapshot.data!;

                            return Container(
                              width: 290,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 2.0),
                                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: comments.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Comment comment = comments[index];
                                  return Container(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
                                            child: Text('${comment.body}'),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                            child: Row(
                                              children: [
                                                Text('commented: '),
                                                GestureDetector(
                                                  onTap: (){
                                                    Navigator.pushNamed(context, '/profile_view/${comment.user}');
                                                  },
                                                  child: Text(
                                                      '${displayNameByUserId[comment.user]}',
                                                    style: GoogleFonts.lexend(
                                                      color: const Color(0xFF0DF099),
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.underline
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ),
                                          if (index < comments.length - 1)
                                            const Divider(
                                              color: Colors.black,
                                              height: 16.0,
                                              thickness: 2.0,
                                            ),
                                        ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              )
            ),
          ),
          if (isMenuOpen)
            MenuOverlay(
              toggleMenu: () {
                setState(() {
                  isMenuOpen = !isMenuOpen;
                });
              },
            ),
        ],
      ),
    );
  }
}
