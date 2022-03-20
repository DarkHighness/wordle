import 'package:wordle/v2/model/game_model.dart';

import '../model/problem_model.dart';

extension GameLogic on GameModel {
  void enterItem(InputItem item) {
    // 判断是否正在进行
    if (gameStatus != GameStatus.statusRunning) {
      return;
    }

    // 判断是否是某一行的末尾
    if (cursor == (attempt + 1) * problem.length) {
      return;
    }

    guessLogs[attempt][cursor++] = item.copyWith();

    notifyListeners();
  }

  void backspaceItem() {
    // 判断是否正在进行
    if (gameStatus != GameStatus.statusRunning) {
      return;
    }

    // 判断是否是某一行的开头
    if (cursor == attempt * problem.length) {
      return;
    }

    guessLogs[attempt][--cursor] = InputItem.empty();

    notifyListeners();
  }

  void setInputCharacterStatus(Character character, InputStatus status) {
    for (var item in inputChoices) {
      if (item.character == character) {
        item.status = status;

        return;
      }
    }
  }

  void checkInput() {
    // 判断是否正在进行
    if (gameStatus != GameStatus.statusRunning) {
      return;
    }

    // 判断是否是某一行的末尾
    if (cursor == (attempt + 1) * problem.length) {
      return;
    }

    var answer = problem.chars;
    var input = guessLogs[attempt];

    for (var i = 0; i < answer.length; i++) {
      if (answer[i] == input[i].character!) {
        input[i].status = InputStatus.statusOk;

        setInputCharacterStatus(answer[i], InputStatus.statusOk);
      } else if (answer[i].char == input[i].character!.char) {
        input[i].status = InputStatus.statusPartialCharacter;

        setInputCharacterStatus(answer[i], InputStatus.statusPartialCharacter);
      } else if (input.indexWhere((e) => e.character! == answer[i]) > 0) {
        input[i].status = InputStatus.statusPartialPosition;

        setInputCharacterStatus(answer[i], InputStatus.statusPartialPosition);
      } else {
        input[i].status = InputStatus.statusMissing;

        setInputCharacterStatus(answer[i], InputStatus.statusMissing);
      }
    }
  }
}
