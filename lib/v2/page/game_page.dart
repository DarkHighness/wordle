import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/database/problem_db.dart';
import 'package:wordle/v2/model/game_model.dart';
import 'package:wordle/v2/model/problem_model.dart';
import 'package:wordle/v2/screen/wordle_screen.dart';

import '../audio/audio.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  GameModel? _gameModel;

  @override
  void initState() {
    internalAudioPlayer.loadAll([
      "keypress-standard.mp3",
      "keypress-delete.mp3",
      "keypress-return.mp3"
    ]);

    super.initState();
  }

  void initGameModel(ProblemDb problemDb) {
    var gameModel = problemDb.randomGame(
        ProblemType.typeIdiom, ProblemDifficulty.difficultyEasy);

    setState(() {
      _gameModel = gameModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final problemDb = context.watch<ProblemDb?>();

    if (problemDb != null && _gameModel == null) {
      initGameModel(problemDb);
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _gameModel),
        Provider.value(value: this),
      ],
      child: Scaffold(
        body: SafeArea(
          child: _gameModel == null
              ? const Center(child: CircularProgressIndicator())
              : const WordleScreen(),
        ),
      ),
    );
  }
}
