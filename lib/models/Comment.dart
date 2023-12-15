import 'package:firebase_auth/firebase_auth.dart';

class Comment {
  final String body;
  final String user;

  Comment({required this.body, required this.user});

  Map<String, dynamic> toMap() {
    return {
      'body': body,
      'user': user,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment._internal(
      body: map['body'] ?? '',
      userId: map['user'] ?? '',
    );
  }

  Comment._internal({
    required String body,
    required String userId,
  })  : body = body,
        user = userId;
}