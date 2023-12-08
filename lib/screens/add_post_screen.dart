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
  String selectedCategory = 'Science'; // Default category

  Future<void> addPost(User user, Post newPost) async {
    // Create a reference to the user's document
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Create a reference to the 'posts' collection
    CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

    // Convert the new post to a map
    Map<String, dynamic> newPostMap = newPost.toMap();

    // Update the 'posts' field in the user's document by adding the new post
    await userDocRef.update({
      'posts': FieldValue.arrayUnion([newPostMap]),
    });

    // Add the new post to the 'posts' collection
    await postsCollection.add(newPostMap);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.myUser);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFF0DF099),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
            SizedBox(height: 10),
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
              hint: Text('Select Category'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0DF099)),
              ),
              onPressed: () async {
                addPost(widget.myUser, Post(
                  title: titleController.text,
                  content: contentController.text,
                  user: widget.myUser,
                  category: selectedCategory,
                )).then((_) {
                  // Navigation after the addPost operation is complete
                  Navigator.pushNamed(context, "/my_posts");
                }).catchError((error) {
                  // Handle errors, e.g., show a snackbar or display an error message
                  print('Error adding post: $error');
                });
              },
              child: Text('Add Post', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
