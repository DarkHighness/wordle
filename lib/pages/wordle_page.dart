import 'package:flutter/material.dart';
import 'package:wordle/components/wordle_problem.dart';
import 'package:wordle/wordle/db.dart';
import 'package:wordle/wordle/model.dart';
import 'package:wordle/wordle/util.dart';

class WordlePage extends StatefulWidget {
  const WordlePage({Key? key}) : super(key: key);

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  IdiomDb? db;

  Future<Problem> initProblem() async {
    db ??= await readAssetsIdiom();

    return db!.randomProblem();
  }

  late Future<Problem> _problemFuture;

  @override
  void initState() {
    _problemFuture = initProblem();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _problemFuture,
          builder: (BuildContext context, AsyncSnapshot<Problem> snapshot) {
            if (snapshot.hasData) {
              return WordleProblem(problem: snapshot.data!);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
