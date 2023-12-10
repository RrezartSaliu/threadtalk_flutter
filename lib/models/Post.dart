import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Comment.dart';

class Post {
  final String? id;
  final String title;
  final String content;
  final User user;
  final String category;
  final List<dynamic> comments;
  int likes;

  Post(this.id, {required this.title, required this.content, required this.user, required this.category, required this.comments, required this.likes});

  // Convert Post object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'user': user.uid,
      'category': category,
      'comments': comments,
      'likes': likes,
      'id': id
    };
  }

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    return Post._internal(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      user: FirebaseAuth.instance.currentUser!,
      comments: List<dynamic>.from(map['comments'] ?? []),
      likes: map['likes'] ?? 0,
    );
  }

  Post._internal({this.id, required this.title, required this.content, required this.user, required this.category, required this.comments, required this.likes});
}

