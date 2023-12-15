import 'package:flutter/material.dart';

class CollapsibleMenuItem extends StatefulWidget {
  final String text;
  final List<String> subItems;

  CollapsibleMenuItem({required this.text, required this.subItems});

  @override
  _CollapsibleMenuItemState createState() => _CollapsibleMenuItemState();
}

class _CollapsibleMenuItemState extends State<CollapsibleMenuItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            //TODO: categories screen
            Navigator.pushNamed(context, "/categories");
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(onPressed: (){setState(() {
                  isExpanded = !isExpanded;
                });}, icon: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 24,
                ),)

              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.subItems
                  .map((subItem) => GestureDetector(
                onTap: () {
                },
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    subItem,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}