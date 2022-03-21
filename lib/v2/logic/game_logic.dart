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

    inputLogs[attempt][cursor++] =
        item.copyWith(status: InputStatus.statusInvalid);

    notifyListeners();
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

    inputLogs[attempt][--cursor] = InputItem.empty();

    notifyListeners();
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
    if (status == GameStatus.statusWon || status == GameStatus.statusLose) {
      gameEnd = DateTime.now();
    }

    gameStatus = status;
  }

  CheckStatus checkInput() {
    // 判断是否正在进行
    if (gameStatus != GameStatus.statusRunning) {
      return CheckStatus.statusNotRunning;
    }

    // 判断是否是某一行的末尾
    if (cursor != problem.length) {
      return CheckStatus.statusInvalidInput;
    }

    var answer = problem.chars;
    var input = inputLogs[attempt];
    var right = 0;

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

    if (right == problem.length) {
      setGameStatus(GameStatus.statusWon);
    } else {
      attempt += 1;
      cursor = 0;

      if (attempt >= maxAttempt) {
        setGameStatus(GameStatus.statusLose);
      }
    }

    notifyListeners();

    return CheckStatus.statusOk;
  }
}
