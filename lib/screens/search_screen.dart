import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:threadtalk191521/models/Post.dart';

import '../utils/menu_overlay.dart';
import '../utils/threadtalk_bar.dart';

class SearchPage extends StatefulWidget {
  final String toSearch;
  const SearchPage({Key? key, required this.toSearch}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool showPosts = true;
  bool isMenuOpen = false;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchPosts() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredPosts = [];

    for (var doc in querySnapshot.docs) {
      if (doc.data()['title'].toString().contains(widget.toSearch)) {
        filteredPosts.add(doc);

      }
    }

    return filteredPosts;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredUsers = [];

    for (var doc in querySnapshot.docs) {
      if (doc.data()['displayName'].toString().contains(widget.toSearch)) {
        filteredUsers.add(doc);

      }
    }

    return filteredUsers;
  }

  Widget buildPosts(List<QueryDocumentSnapshot<Map<String, dynamic>>> posts) {
    if(posts.isEmpty)
      return Text('no results found');
    return Expanded(child: ListView.builder(
      padding: const EdgeInsets.only(left: 6, top: 2, bottom: 2, right: 6),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        String postId = posts[index].id;
        Map<String, dynamic> postData = posts[index].data();
        return GestureDetector(
          onTap: () async {
            String userId = postData['user'];

            DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

            String displayName = userSnapshot['displayName'];

            Post post = Post.fromMap(postId, postData);
            Map<String, dynamic> nameAndPost = {
              'post': post,
              'displayName': displayName,
            };

            Navigator.pushNamed(context, "/post_view", arguments: nameAndPost);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 5.0),
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 6, top: 2, bottom: 2, right: 6),
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Text(postData['title'], style: GoogleFonts.lexend(), maxLines: 2,overflow: TextOverflow.ellipsis,),
          ),
        );
      },
    ));
  }

  Widget buildUsers(List<QueryDocumentSnapshot<Map<String, dynamic>>> users) {
    if(users.isEmpty)
      return Text('no results found');
    return Expanded(child: ListView.builder(
      padding: const EdgeInsets.only(left: 6, top: 2, bottom: 2, right: 6),
      itemCount: users.length,
      itemBuilder: (context, index) {
        String userId = users[index].id;
        Map<String, dynamic> userData = users[index].data();
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile_view/$userId');
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 5.0),
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 6, top: 2, bottom: 2, right: 6),
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Text(userData['displayName'], style: GoogleFonts.lexend(), maxLines: 2,overflow: TextOverflow.ellipsis,),
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: ThreadTalkBar(toggleMenu: () {
        setState(() {
          isMenuOpen = !isMenuOpen;
        });
      }
      ),
      body: Stack(
        children: [
          Positioned(
            left: 20.0,
            right: 20.0,
            top: 15.0,
            bottom: 15.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: Colors.black),
                color: const Color(0xFFFFF1F1),
                borderRadius:
                BorderRadius.circular(10.0),
              ),
              child: Column(
                  children: [
                    SizedBox(height: 3),
                    Text("Search results for '${widget.toSearch}'"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              showPosts = true;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 6, top: 2, bottom: 2, right: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2.0),
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Text('Posts', style: GoogleFonts.lexend(
                              color: showPosts==true?Color(0xFF0DF099):Colors.black
                            ),),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              showPosts = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 6, top: 2, bottom: 2, right: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2.0),
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Text('Users', style: GoogleFonts.lexend(
                                color: showPosts==false?Color(0xFF0DF099):Colors.black
                            )),
                          ),
                        )
                      ],
                    ),
                    if(showPosts)
                      FutureBuilder(
                        future: fetchPosts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<QueryDocumentSnapshot<Map<String, dynamic>>>? posts = snapshot.data;
                            return buildPosts(posts!);
                          }
                        },
                      ),
                    if(!showPosts)
                      FutureBuilder(
                        future: fetchUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<QueryDocumentSnapshot<Map<String, dynamic>>>? users = snapshot.data;
                            return buildUsers(users!);
                          }
                        },
                      ),
                ]
              ),
            ),
          ),

          if(isMenuOpen)
            MenuOverlay(
              toggleMenu: () {
                setState(() {
                  isMenuOpen = !isMenuOpen;
                });
              },
            )
        ],
      ),
    );
  }
}