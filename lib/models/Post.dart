import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class Post {
  final String? id;
  final String title;
  final String content;
  final String user;
  final String category;
  final List<dynamic> comments;
  int likes;

  Post(this.id, {required this.title, required this.content, required this.user, required this.category, required this.comments, required this.likes});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'user': user,
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
      user:  map['user'] ?? '',
      comments: List<dynamic>.from(map['comments'] ?? []),
      likes: map['likes'] ?? 0,
    );
  }


  Post._internal({this.id, required this.title, required this.content, required this.user, required this.category, required this.comments, required this.likes});
}
