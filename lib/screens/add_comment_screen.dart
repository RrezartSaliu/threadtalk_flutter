import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/Comment.dart';

class AddCommentScreen extends StatefulWidget {
  final User myUser;
  final String postId;
  const AddCommentScreen({Key? key, required this.myUser, required this.postId}) : super(key: key);

  @override
  _AddCommentScreenState createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  final TextEditingController bodyController = TextEditingController();

  Future<void> addComment(Comment newComment) async{
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.myUser.uid);
    DocumentReference postDocRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

    CollectionReference commentsCollection = FirebaseFirestore.instance.collection('comments');

    Map<String, dynamic> newCommentMap = newComment.toMap();

    DocumentReference newCommentRef = await commentsCollection.add(newCommentMap);
    String commentId = newCommentRef.id;

    await userDocRef.update({
      'comments': FieldValue.arrayUnion([commentId]),
    });
    await postDocRef.update({
      'comments': FieldValue.arrayUnion([commentId])
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.myUser);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Comment', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFF0DF099),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: bodyController,
              decoration: InputDecoration(labelText: 'comment'),
            ),
            SizedBox(height: 10),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0DF099)),
              ),
              onPressed: () async {
                addComment(Comment(
                    body: bodyController.text,
                    user: widget.myUser,
                )).then((_) {
                  // Navigation after the addPost operation is complete
                  Navigator.pushNamed(context, "/my_posts");
                }).catchError((error) {
                  // Handle errors, e.g., show a snackbar or display an error message
                  print('Error adding comment: $error');
                });
              },
              child: Text('Add Comment', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
