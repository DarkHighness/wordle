import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/database/problem_db.dart';
import 'package:wordle/v2/dialog/result_dialog.dart';
import 'package:wordle/v2/model/game_model.dart';
import 'package:wordle/v2/model/problem_model.dart';
import 'package:wordle/v2/screen/wordle_screen.dart';
import 'package:wordle/v2/util/event_bus.dart';

import '../audio/audio.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  GameModel? _gameModel;
  EventBus? _eventBus;

  @override
  void initState() {
    internalAudioPlayer.loadAll([
      "keypress-standard.mp3",
      "keypress-delete.mp3",
      "keypress-return.mp3"
    ]);

    _eventBus = EventBus();

    super.initState();
  }

  void initGameModel(ProblemDb problemDb) {
    var gameModel = problemDb.randomGame(
        ProblemType.typeIdiom, ProblemDifficulty.difficultyEasy);

    gameModel.addListener(() {
      if (gameModel.gameStatus == GameStatus.statusWon ||
          gameModel.gameStatus == GameStatus.statusLose) {
        showResultDialog();
      }
    });

    var _thisGameModel = _gameModel;

    if (_thisGameModel != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _thisGameModel.dispose();
      });
    }

    setState(() {
      _gameModel = gameModel;
    });
  }

  void resetGameModel() {
    final problemDb = context.read<ProblemDb>();

    var gameModel = problemDb.randomGame(
        ProblemType.typeIdiom, ProblemDifficulty.difficultyEasy);

    gameModel.addListener(() {
      if (gameModel.gameStatus == GameStatus.statusWon ||
          gameModel.gameStatus == GameStatus.statusLose) {
        showResultDialog();
      }
    });

    var _thisGameModel = _gameModel;

    if (_thisGameModel != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _thisGameModel.dispose();
      });
    }

    setState(() {
      _gameModel = gameModel;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showResultDialog() {
    var selfContext = context;
    var gameModel = _gameModel!;

    var status = gameModel.gameStatus;
    var problem = gameModel.problem;
    var attempt = gameModel.attempt;
    var duration = gameModel.duration;

    Future.microtask(() => showResultDialogInternal(
        selfContext, status, attempt, duration, problem, resetGameModel));
  }

  @override
  Widget build(BuildContext context) {
    final problemDb = context.watch<ProblemDb?>();

    if (problemDb != null && _gameModel == null) {
      initGameModel(problemDb);
    }

    return MultiProvider(
      providers: [
        Provider.value(value: this),
        ChangeNotifierProvider.value(value: _gameModel),
        Provider.value(value: _eventBus),
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
