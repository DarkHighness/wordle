import 'package:flutter/material.dart';
import 'package:wordle/pages/wordle_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle, 但是成语',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: "LXGWWenKaiScreen",
      ),
      home: const WordlePage(),
    );
  }
}
