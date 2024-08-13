import 'package:flutter/material.dart';
import 'package:meta_col_hub/auth.dart';
import 'package:meta_col_hub/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return HomePage(isLoggedIn: true);
        } else {
          return HomePage(isLoggedIn: false);
        }
      },
    );
  }
}
