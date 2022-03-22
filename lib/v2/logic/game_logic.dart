import 'dart:math';

import 'package:wordle/v2/database/problem_db.dart';
import 'package:wordle/v2/model/game_model.dart';

import '../model/problem_model.dart';

enum CheckStatus { statusOk, statusNotRunning, statusInvalidInput }

extension GameLogic on GameModel {
  void enterItem(InputItem item) {
    // 判断是否正在进行
    if (gameStatus != GameStatus.statusRunning) {
      return;
    }

    // 判断是否是某一行的末尾
    if (cursor == problem.length) {
      return;
    }

    var input = inputLogs[attempt];

    while (cursor < problem.length &&
        input[cursor].status == InputStatus.statusHint) {
      cursor++;
    }

    if (cursor != problem.length) {
      input[cursor] = item.copyWith(status: InputStatus.statusInvalid);

      cursor++;

      notifyListeners();
    }
  }

  void backspaceItem() {
    // 判断是否正在进行
    if (gameStatus != GameStatus.statusRunning) {
      return;
    }

    // 判断是否是某一行的开头
    if (cursor == 0) {
      return;
    }

    var input = inputLogs[attempt];

    while (
        cursor >= 0 && input[--cursor].status != InputStatus.statusInvalid) {}

    if (cursor >= 0 && input[cursor].status == InputStatus.statusInvalid) {
      inputLogs[attempt][cursor] = InputItem.empty();

      notifyListeners();
    } else {
      cursor = max(0, cursor);
    }
  }

  void setInputCharacterStatus(Character character, InputStatus status) {
    for (var item in inputChoices) {
      if (item.character == character) {
        // 无效状态直接设置
        if (item.status == InputStatus.statusInvalid) {
          item.status = status;
        }
        // 覆盖半正确的状态
        else if ((item.status == InputStatus.statusPartialCharacter ||
                item.status == InputStatus.statusPartialPosition) &&
            status == InputStatus.statusOk) {
          item.status = status;
        }

        return;
      }
    }
  }

  void setGameStatus(GameStatus status) {
    if (status == GameStatus.statusWon ||
        status == GameStatus.statusLose ||
        status == GameStatus.statusSkipped) {
      gameEnd = DateTime.now();
    }

    gameStatus = status;

    notifyListeners();
  }

  CheckStatus checkInput(ProblemDb db) {
    // 判断是否正在进行
    if (gameStatus != GameStatus.statusRunning) {
      return CheckStatus.statusNotRunning;
    }

    var input = inputLogs[attempt];
    var inputCnt = input
        .map((e) => e.character == null ? 0 : 1)
        .reduce((acc, v) => acc + v);

    // 判断是否是某一行的末尾
    if (inputCnt != problem.length) {
      return CheckStatus.statusInvalidInput;
    }

    var answer = problem.chars;
    var right = 0;

    var inputWord = input.map((e) => e.character!.char).join();

    if (problem.typeEnum == ProblemType.typeIdiom &&
        !db.isValidInput(inputWord)) {
      return CheckStatus.statusInvalidInput;
    }

    for (var i = 0; i < input.length; i++) {
      if (answer[i] == input[i].character!) {
        input[i].status = InputStatus.statusOk;

        setInputCharacterStatus(input[i].character!, InputStatus.statusOk);

        right++;
      } else if (answer.indexWhere((e) => e.char == input[i].character!.char) >=
          0) {
        input[i].status = InputStatus.statusPartialCharacter;

        setInputCharacterStatus(
            input[i].character!, InputStatus.statusPartialCharacter);
      } else if (answer.indexWhere((e) => e == input[i].character!) >= 0) {
        input[i].status = InputStatus.statusPartialPosition;

        setInputCharacterStatus(
            input[i].character!, InputStatus.statusPartialPosition);
      } else {
        input[i].status = InputStatus.statusMissing;

        setInputCharacterStatus(input[i].character!, InputStatus.statusMissing);
      }
    }

    var notified = false;

    if (right == problem.length) {
      setGameStatus(GameStatus.statusWon);

      notified = true;
    } else {
      attempt += 1;
      cursor = 0;

      if (attempt >= maxAttempt) {
        setGameStatus(GameStatus.statusLose);
        notified = true;
      } else {
        renderHint();
      }
    }

    if (!notified) {
      notifyListeners();
    }

    return CheckStatus.statusOk;
  }

  void renderHint() {
    var idx = hintsIndex +
        (problem.typeEnum == ProblemType.typePoem ? problem.hintLength : 0);

    var input = inputLogs[attempt];

    for (var i = 0; i < idx; i++) {
      var hint = hints[i];

      switch (hint.hintType) {
        case ProblemHintType.hintTypeMissing:
          // 注意的是, 输入框中不采用 hint 作为标识
          setInputCharacterStatus(
              hint.hintCharacter, InputStatus.statusMissing);
          break;
        case ProblemHintType.hintTypeOccurs:
          // 注意的是, 输入框中不采用 hint 作为标识
          setInputCharacterStatus(
              hint.hintCharacter, InputStatus.statusPartialPosition);
          break;
        case ProblemHintType.hintTypeAnswer:
          var item = input[hint.hintPosition!];

          item.character = hint.hintCharacter;
          item.status = InputStatus.statusHint;
          // 注意的是, 输入框中不采用 hint 作为标识
          setInputCharacterStatus(hint.hintCharacter, InputStatus.statusOk);
          break;
      }
    }

    notifyListeners();
  }

  bool skipHint({required int skip}) {
    var idx = hintsIndex +
        (problem.typeEnum == ProblemType.typePoem ? problem.hintLength : 0) +
        skip;

    if (idx > hints.length) {
      return false;
    } else {
      hintsIndex = idx -
          (problem.typeEnum == ProblemType.typePoem ? problem.hintLength : 0);
      return true;
    }
  }

  bool nextHint() {
    var idx = hintsIndex +
        (problem.typeEnum == ProblemType.typePoem ? problem.hintLength : 0);

    if (idx > hints.length) {
      return false;
    } else {
      hintsIndex++;

      return true;
    }
  }
}
