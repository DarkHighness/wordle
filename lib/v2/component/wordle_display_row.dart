import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/component/wordle_character.dart';

import '../model/game_model.dart';

class WordleDisplayRow extends StatelessWidget {
  final int rowIndex;

  const WordleDisplayRow({Key? key, required this.rowIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, List<InputItem>>(
      selector: (context, model) {
        return List.from(model.guessLogs[rowIndex]);
      },
      builder: (context, items, child) {
        return Row(
          children: items
              .map(
                (e) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: WordleCharacter(character: e.character),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
