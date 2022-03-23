import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final String? initialProblemId;

  const GamePage({
    Key? key,
    required this.gameMode,
    required this.problemType,
    required this.problemDifficulty,
    this.initialProblemId,
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
  List<Tuple3<ProblemModel, GameStatus, int>>? _speedRunProblems;

  @override
  void initState() {
    _eventBus = EventBus();

    super.initState();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();

    super.dispose();
  }

  void initGameModel(ProblemDb problemDb) {
    GameModel gameModel;

    if (widget.initialProblemId != null && _gameModel == null) {
      if (problemDb.isValidProblem(widget.initialProblemId!)) {
        gameModel =
            problemDb.selectGame(widget.initialProblemId!, widget.gameMode);
      } else {
        Fluttertoast.showToast(msg: "无效的题目 ID", toastLength: Toast.LENGTH_LONG);

        Navigator.pop(context);

        return;
      }
    } else {
      gameModel = problemDb.randomGame(
          widget.gameMode, widget.problemType, widget.problemDifficulty);
    }

    gameModel.addListener(() {
      if (gameModel.gameStatus == GameStatus.statusWon ||
          gameModel.gameStatus == GameStatus.statusLose ||
          gameModel.gameStatus == GameStatus.statusSkipped) {
        if (widget.gameMode == GameMode.modeNormal) {
          showResultDialog();
        } else if (widget.gameMode == GameMode.modeSpeedRun) {
          _speedRunProblems!.add(
            Tuple3(
                gameModel.problem, gameModel.gameStatus, gameModel.attempt + 1),
          );

          resetGameModel();
        }
      }
    });

    gameModel.renderHint();

    var _thisGameModel = _gameModel;

    if (_thisGameModel != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _thisGameModel.dispose();
      });
    }

    if (widget.gameMode == GameMode.modeSpeedRun && _gameStart == null) {
      initSpeedRunGame();
    }

    setState(() {
      _gameModel = gameModel;
    });
  }

  void initSpeedRunGame() {
    _gameStart = DateTime.now();
    _speedRunProblems = [];

    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (timeLeft.inSeconds == 0 || timeLeft.isNegative) {
          timer.cancel();

          _gameModel!.setGameStatus(GameStatus.statusLose);

          showSpeedRunResultDialogInternal(
              context, modeSpeedRunDuration, _speedRunProblems!);
        } else {
          // 竞速模式下, 跳过前3条提示
          if (_gameModel!.hintsIndex == 0) {
            _gameModel!.skipHint(skip: modeSpeedRunHintSkip);
          }

          if (timeLeft.inSeconds % modeSpeedRunHintSecs == 0) {
            nextHint();
          }

          notifyListeners();
        }
      },
    );
  }

  void resetGameModel() {
    final problemDb = context.read<ProblemDb>();

    initGameModel(problemDb);
  }

  void nextHint() {
    if (_gameModel!.nextHint()) {
      _gameModel!.renderHint();
    } else if (_gameModel!.gameMode != GameMode.modeSpeedRun) {
      Fluttertoast.showToast(msg: "没有更多提示了...", toastLength: Toast.LENGTH_LONG);
    }
  }

  void setGameStatus(GameStatus status) {
    _gameModel!.setGameStatus(status);
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
