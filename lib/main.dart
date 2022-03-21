import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/database/problem_db.dart';
import 'package:wordle/v2/page/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(
          create: (context) => loadProblemDbFromAssets(),
          initialData: null,
          lazy: false,
        )
      ],
      child: MaterialApp(
        title: 'Wordle, 但是成语',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.grey,
          fontFamily: "LXGWWenKaiScreen",
        ),
        initialRoute: "main",
        home: const MainPage(),
      ),
    );
  }
}
