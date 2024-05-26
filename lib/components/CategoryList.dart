import 'package:flutter/material.dart';

class Type {
  final String text;

  Type({required this.text});
}

List<Type> Types = [
  Type(text: "Sedans"),
  Type(text: "SUVs"),
  Type(text: "Coupes"),
  Type(text: "Hatchbacks"),
  Type(text: "Hybrid"),
  Type(text: "Motorbikes")
];

class CategoryList extends StatefulWidget {
  final List<Type> types;
  final int selectedIndex;
  final Function(int) onCategoryTap;

  CategoryList({
    required this.types,
    required this.selectedIndex,
    required this.onCategoryTap,
  });

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 149, 163),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      height: 40.0,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: widget.types.length,
        itemBuilder: (BuildContext context, int index) {
          Type type = widget.types[index];
          return GestureDetector(
            onTap: () {
              widget.onCategoryTap(index);
            },
            child: Container(
              margin: EdgeInsets.only(right: 8.0, left: 4),
              height: 20,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    type.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: index == widget.selectedIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: index == widget.selectedIndex
                          ? Colors.white
                          : Colors.black,
                      decorationColor: index == widget.selectedIndex
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
