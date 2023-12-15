import 'package:flutter/material.dart';
import 'package:threadtalk191521/firebase_auth_services.dart';
import 'package:threadtalk191521/screens/search_screen.dart';
import 'collapible_menu_item.dart';


class MenuOverlay extends StatefulWidget {
  final VoidCallback toggleMenu;
  const MenuOverlay({Key? key, required this.toggleMenu}) : super(key: key);


  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> {


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Stack(
            children: [

                GestureDetector(

                  child: Container(
                    color: Colors.black.withOpacity(0.95),
                  ),
                )
              ,
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView(
                      children: [
                        const SizedBox(height: 30),
                        SearchBar(),
                        const SizedBox(height: 20),
                        MenuItem(text: 'Profile', onPressed: (){
                          widget.toggleMenu();
                          Navigator.pushNamed(context, '/profile');
                        },),
                        const SizedBox(height: 20),
                        MenuItem(text: 'My Posts', onPressed: () {
                          widget.toggleMenu();
                          Navigator.pushNamed(context, "/my_posts");
                        },),
                        const SizedBox(height: 20),
                        CollapsibleMenuItem(text: 'Categories',
                            subItems: ['Science', 'Sport', 'Technology', 'Fashion', 'Movies']),
                        const SizedBox(height: 20),
                        MenuItem(text: 'Logout', onPressed: () async {
                          await FirebaseAuthService().signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        }),
                      ],
                    ),
                  ),
                ),
            ]
        )
    );
  }


}

class MenuItem extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  MenuItem({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
        onSubmitted: (String value) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                SearchPage(toSearch: value)
            )
          );
        },
      ),
    );
  }
}