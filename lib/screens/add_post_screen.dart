import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/Post.dart';

class AddPostScreen extends StatefulWidget {
  final User myUser;
  const AddPostScreen({Key? key, required this.myUser}) : super(key: key);
  
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String selectedCategory = 'Science';

  Future<void> addPost(User user, Post newPost) async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

    Map<String, dynamic> newPostMap = newPost.toMap();

    DocumentReference newPostRef = await postsCollection.add(newPostMap);
    String postId = newPostRef.id;

    await userDocRef.update({
      'posts': FieldValue.arrayUnion([postId]),
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFF0DF099),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedCategory,
              items: [
                'Science',
                'Sport',
                'Technology',
                'Fashion',
                'Movies',
              ].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                }
              },
              hint: const Text('Select Category'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0DF099)),
              ),
              onPressed: () async {
                addPost(widget.myUser, Post(
                  null,
                  title: titleController.text,
                  content: contentController.text,
                  user: widget.myUser.uid,
                  category: selectedCategory,
                  comments: [],
                  likes: 0
                )).then((_) {
                  Navigator.pushNamed(context, "/my_posts");
                }).catchError((error) {
                  print('Error adding post: $error');
                });
              },
              child: const Text('Add Post', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
