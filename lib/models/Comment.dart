import 'package:firebase_auth/firebase_auth.dart';

class Comment {
  final String body;
  final User user;

  Comment({required this.body, required this.user});

  // Convert Post object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'body': body,
      'user': user.uid,
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
        user = FirebaseAuth.instance.currentUser!;
}