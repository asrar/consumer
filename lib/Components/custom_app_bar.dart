import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String? title;

  CustomAppBar({this.title});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AppBar(
      toolbarHeight: 75,
      leading: IconButton(
        icon: Icon(Icons.keyboard_arrow_left),
        color: theme.backgroundColor,
        iconSize: 40,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title ?? '',
        style: TextStyle(color: theme.backgroundColor, fontSize: 26),
      ),
    );
  }
}
