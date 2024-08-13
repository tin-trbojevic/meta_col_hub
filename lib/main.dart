import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta_col_hub/firebase_options.dart';
import 'package:meta_col_hub/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MetaColHub',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 237, 248, 255),
        primarySwatch: Colors.lightBlue,

        // AppBar theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightBlue[100],
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.black),
        ),

        // ElevatedButton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[500],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),

        // Text theme
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), 
          bodyMedium: TextStyle(color: Colors.black), 
          titleLarge: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),

        // ListTile theme
        listTileTheme: ListTileThemeData(
          tileColor: Colors.white,
          selectedColor: Colors.black,
          iconColor: Colors.grey,
          textColor: Colors.black,
        ),

        // Icon theme
        iconTheme: IconThemeData(
          color: Colors.blueGrey[500], 
        ),

        // InputDecoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.lightBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.lightBlue, width: 2),
          ),
          labelStyle: TextStyle(color: Color.fromARGB(255, 139, 139, 139)),
          hintStyle: TextStyle(color: Colors.black),
        ),
      ),
      home: WidgetTree(),
    );
  }
}
