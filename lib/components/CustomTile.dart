import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget child;

  CustomExpansionTile({required this.title, required this.child});

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: widget.title,
          trailing: IconButton(
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        _isExpanded
            ? Container(
                child: widget.child,
              )
            : Container(),
      ],
    );
  }
}
