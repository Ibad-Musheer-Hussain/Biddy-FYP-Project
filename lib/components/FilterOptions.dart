import 'package:flutter/material.dart';

class FilterOptions extends StatefulWidget {
  final TextEditingController priceMin;
  final TextEditingController priceMax;
  final TextEditingController yearMin;
  final TextEditingController yearMax;
  final TextEditingController kmMin;
  final TextEditingController kmMax;
  final Function(bool) onExpansionChanged;

  FilterOptions({
    required this.priceMin,
    required this.priceMax,
    required this.yearMin,
    required this.yearMax,
    required this.kmMin,
    required this.kmMax,
    required this.onExpansionChanged,
  });

  @override
  _FilterOptionsState createState() => _FilterOptionsState();
}

class _FilterOptionsState extends State<FilterOptions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106, // Adjust the height as needed
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(
            width: 200, // Adjust the width as needed
            child: ExpansionTile(
              enableFeedback: false,
              onExpansionChanged: widget.onExpansionChanged,
              title: Text("Price Range"),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Min  "),
                    Container(
                        width: 60,
                        child: TextField(
                          controller: widget.priceMin,
                        )),
                    Text("Max  "),
                    Container(
                        width: 60,
                        child: TextField(
                          controller: widget.priceMax,
                        )),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 200, // Adjust the width as needed
            child: ExpansionTile(
              onExpansionChanged: widget.onExpansionChanged,
              title: Text("Year Range"),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Min  "),
                    Container(
                        width: 60,
                        child: TextField(
                          controller: widget.yearMin,
                        )),
                    Text("Max  "),
                    Container(
                        width: 60,
                        child: TextField(
                          controller: widget.yearMax,
                        )),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 200, // Adjust the width as needed
            child: ExpansionTile(
              onExpansionChanged: widget.onExpansionChanged,
              title: Text("KMs Driven "),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Min  "),
                    Container(
                        width: 60,
                        child: TextField(
                          controller: widget.kmMin,
                        )),
                    Text("Max  "),
                    Container(
                        width: 60,
                        child: TextField(
                          controller: widget.kmMax,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
