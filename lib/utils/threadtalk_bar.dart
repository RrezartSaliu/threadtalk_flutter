import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThreadTalkBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback toggleMenu;
  const ThreadTalkBar({Key? key, required this.toggleMenu}) : super(key: key);


  @override
  State<ThreadTalkBar> createState() => _ThreadTalkBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ThreadTalkBarState extends State<ThreadTalkBar>{


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      AppBar(
        title: null,
        centerTitle: true,
        backgroundColor: const Color(0xFF0DF099),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 30.0),
            color: Colors.black,
            onPressed: () {
              widget.toggleMenu();
            },
          ),
        ],
        flexibleSpace: Center(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0.0),
            width: 140.0,
            height: 40.0,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFBE9),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'THREADTALK',
                style: GoogleFonts.koulen(
                  fontSize: 26,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        elevation: 7.0,
    );
  }
}