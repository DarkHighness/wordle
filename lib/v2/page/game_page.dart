import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:wordle/v2/config/config.dart';
import 'package:wordle/v2/database/problem_db.dart';
import 'package:wordle/v2/dialog/result_dialog.dart';
import 'package:wordle/v2/dialog/speedrun_result_dialog.dart';
import 'package:wordle/v2/logic/game_logic.dart';
import 'package:wordle/v2/model/game_model.dart';
import 'package:wordle/v2/model/problem_model.dart';
import 'package:wordle/v2/screen/wordle_screen.dart';
import 'package:wordle/v2/util/event_bus.dart';

class GamePage extends StatefulWidget {
  final ProblemType problemType;
  final ProblemDifficulty problemDifficulty;
  final GameMode gameMode;

  const GamePage({
    Key? key,
    required this.gameMode,
    required this.problemType,
    required this.problemDifficulty,
  }) : super(key: key);

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin, ChangeNotifier {
  GameModel? _gameModel;
  EventBus? _eventBus;

  DateTime? _gameStart;
  Timer? _gameTimer;
  List<Tuple2<ProblemModel, int>>? _speedRunProblems;

  @override
  void initState() {
    _eventBus = EventBus();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _gameTimer?.cancel();
  }

  void initGameModel(ProblemDb problemDb) {
    var gameModel = problemDb.randomGame(
        widget.gameMode, widget.problemType, widget.problemDifficulty);

    gameModel.addListener(() {
      if (gameModel.gameStatus == GameStatus.statusWon ||
          gameModel.gameStatus == GameStatus.statusLose) {
        if (widget.gameMode == GameMode.modeNormal) {
          showResultDialog();
        } else if (widget.gameMode == GameMode.modeSpeedRun) {
          if (gameModel.gameStatus == GameStatus.statusWon) {
            _speedRunProblems!
                .add(Tuple2(gameModel.problem, gameModel.attempt));
          }

          resetGameModel();
        }
      }
    });

    var _thisGameModel = _gameModel;

    if (_thisGameModel != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _thisGameModel.dispose();
      });
    }

    if (widget.gameMode == GameMode.modeSpeedRun && _gameStart == null) {
      initSpeedRunGame(gameModel);
    }

    setState(() {
      _gameModel = gameModel;
    });
  }

  void initSpeedRunGame(GameModel gameModel) {
    _gameStart = DateTime.now();
    _speedRunProblems = [];

    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (timeLeft.inSeconds == 0 || timeLeft.isNegative) {
          timer.cancel();

          gameModel.setGameStatus(GameStatus.statusLose);

          showSpeedRunResultDialogInternal(
              context, modeSpeedRunDuration, _speedRunProblems!);
        } else {
          notifyListeners();
        }
      },
    );
  }

  void resetGameModel() {
    final problemDb = context.read<ProblemDb>();

    initGameModel(problemDb);
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

  Duration get timeLeft {
    if (widget.gameMode != GameMode.modeSpeedRun) {
      return Duration.zero;
    }

    var now = DateTime.now();

    return modeSpeedRunDuration - now.difference(_gameStart!);
  }

  @override
  Widget build(BuildContext context) {
    final problemDb = context.watch<ProblemDb?>();

    if (problemDb != null && _gameModel == null) {
      initGameModel(problemDb);
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: this),
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
