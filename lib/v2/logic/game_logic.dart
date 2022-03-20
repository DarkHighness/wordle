import 'package:wordle/v2/model/game_model.dart';

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
}
