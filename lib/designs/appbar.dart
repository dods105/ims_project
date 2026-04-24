import 'package:flutter/material.dart';
import 'themes.dart';

class AppDrawer extends StatelessWidget {
  final String page;
  const AppDrawer({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //store profile

      //page
      title: Text(page, style: TextStyle()),
    );
  }
}
