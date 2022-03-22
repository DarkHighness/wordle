import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/component/wordle_keyboard_item.dart';
import 'package:wordle/v2/model/game_model.dart';
import 'package:wordle/v2/util/util.dart';

class WordleKeyBoard extends StatelessWidget {
  const WordleKeyBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, int>(
      selector: (context, model) => model.inputChoices.length,
      builder: (context, len, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: GridView.count(
            crossAxisCount: 6,
            mainAxisSpacing: 2.0,
            crossAxisSpacing: 2.0,
            children: len
                .rangeUntil(from: 0)
                .map(
                  (e) => WordleKeyboardItem(choiceIndex: e),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
