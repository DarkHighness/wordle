import 'package:wordle/v2/model/problem_model.dart';

enum InputStatus {
  statusOk,
  statusPartialPosition,
  statusPartialCharacter,
  statusMissing,
  statusInvalid
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

enum GameStatus { statusWon, statusLose, statusRunning, statusPausing }

class GameModel {
  ProblemModel problem;
  List<InputItem> inputChoices;
  List<List<InputItem>> guessLogs;
  int maxAttempt;
  GameStatus gameStatus;

  GameModel({
    required this.problem,
    required this.inputChoices,
    required this.maxAttempt,
  })  : guessLogs = List.generate(maxAttempt,
            (_) => List.generate(problem.length, (_) => InputItem.empty())),
        gameStatus = GameStatus.statusRunning;
}
