import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final String title;
  final String content;
  final User user;
  final String category;

  Post({required this.title, required this.content, required this.user, required this.category});

  // Convert Post object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'user': user.uid,
      'category': category
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post._internal(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      userId: map['user'] ?? '',
    );
  }

  Post._internal({
    required String title,
    required String content,
    required String category,
    required String userId,
  })  : title = title,
        content = content,
        category = category,
        user = FirebaseAuth.instance.currentUser!;

}