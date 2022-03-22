import 'package:flutter/foundation.dart';
import 'package:wordle/v2/model/problem_model.dart';

enum InputStatus {
  statusOk,
  statusPartialPosition,
  statusPartialCharacter,
  statusMissing,
  statusInvalid,
  statusHint
}

class InputItem {
  Character? character;
  InputStatus status;

  InputItem({
    required this.character,
    this.status = InputStatus.statusInvalid,
  });

  InputItem.empty() : status = InputStatus.statusInvalid;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputItem &&
          runtimeType == other.runtimeType &&
          character == other.character &&
          status == other.status;

  @override
  int get hashCode => character.hashCode ^ status.hashCode;

  InputItem copyWith({
    Character? character,
    InputStatus? status,
  }) {
    return InputItem(
      character: character ?? this.character,
      status: status ?? this.status,
    );
  }
}

enum GameStatus {
  statusWon,
  statusLose,
  statusSkipped,
  statusRunning,
  statusPausing
}

enum GameMode { modeNormal, modeSpeedRun }

enum ProblemHintType { hintTypeMissing, hintTypeOccurs, hintTypeAnswer }

class HintItem {
  final ProblemHintType hintType;
  final Character hintCharacter;
  final int? hintPosition;

  const HintItem({
    required this.hintType,
    required this.hintCharacter,
    this.hintPosition,
  }) : assert(hintType != ProblemHintType.hintTypeAnswer ||
            (hintType == ProblemHintType.hintTypeAnswer &&
                hintPosition != null));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HintItem &&
          runtimeType == other.runtimeType &&
          hintType == other.hintType &&
          hintCharacter == other.hintCharacter &&
          hintPosition == other.hintPosition;

  @override
  int get hashCode =>
      hintType.hashCode ^ hintCharacter.hashCode ^ hintPosition.hashCode;
}

class GameModel extends ChangeNotifier {
  ProblemModel problem;
  List<InputItem> inputChoices;
  List<List<InputItem>> inputLogs;
  List<HintItem> hints;

  // 成语是相对于 0 提示
  // 故事是相对于 hintLength 的提示
  int hintsIndex;

  int maxAttempt;
  int attempt;
  int cursor;
  GameStatus gameStatus;
  GameMode gameMode;
  DateTime gameStart;
  DateTime? gameEnd;

  GameModel({
    required this.gameMode,
    required this.problem,
    required this.inputChoices,
    required this.hints,
    required this.maxAttempt,
  })  : inputLogs = List.generate(
            maxAttempt,
            (_) => List.generate(problem.length, (_) => InputItem.empty(),
                growable: false),
            growable: false),
        gameStatus = GameStatus.statusRunning,
        hintsIndex = 0,
        attempt = 0,
        cursor = 0,
        gameStart = DateTime.now();

  Duration get duration {
    if (gameEnd == null) {
      return Duration.zero;
    }

    return gameEnd!.difference(gameStart);
  }
}
