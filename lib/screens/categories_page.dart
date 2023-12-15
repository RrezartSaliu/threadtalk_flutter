import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:threadtalk191521/utils/threadtalk_bar.dart';

import '../utils/menu_overlay.dart';

class CategoriesPage extends StatefulWidget{
const CategoriesPage({Key? key}) : super(key: key);


@override
State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>{
  bool isMenuOpen = false;

  Widget CategoryComponent(String category, IconData icon){
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, "/categoriesposts/$category");
      },
      child: Container(
        width: 300,
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2.0),
            borderRadius: BorderRadius.circular(23.0)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                  category,
                  style: GoogleFonts.lexend(
                      fontSize: 26
                  )
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  icon,
                  size: 28,
                  color: Colors.red
                ),
            )
          ],
        ),
      ),
    );
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
              decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: Colors.black),
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'CATEGORIES',
                    style: GoogleFonts.lexend(
                        fontSize: 32,
                        color: Colors.black
                    ),
                  ),
                  const SizedBox(height: 15),
                  CategoryComponent('Science', FontAwesomeIcons.flask),
                  const SizedBox(height: 20),
                  CategoryComponent('Sport', Icons.sports_basketball),
                  const SizedBox(height: 20),
                  CategoryComponent('Technology', FontAwesomeIcons.laptop),
                  const SizedBox(height: 20),
                  CategoryComponent('Fashion', FontAwesomeIcons.shirt),
                  const SizedBox(height: 20),
                  CategoryComponent('Movies', FontAwesomeIcons.film)
                ],
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