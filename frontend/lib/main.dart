import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const BookListApp());
}

class BookListApp extends StatelessWidget {
  const BookListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book List',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home:  HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
