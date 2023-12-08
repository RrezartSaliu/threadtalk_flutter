import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final String body;
  final User user;

  Post({required this.body, required this.user});

  // Convert Post object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'body': body,
      'user': user.uid,
    };
  }
}