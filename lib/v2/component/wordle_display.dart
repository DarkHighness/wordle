import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/component/wordle_display_row.dart';
import 'package:wordle/v2/model/game_model.dart';

class WordleDisplay extends StatelessWidget {
  const WordleDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, int>(
      selector: (context, model) => model.guessLogs.length,
      builder: (context, len, child) {
        List<Widget> children = [];

        for (var i = 0; i < len; i++) {
          children.add(
            Expanded(
              child: WordleDisplayRow(
                rowIndex: i,
              ),
            ),
          );
        }

        return Column(children: children);
      },
    );
  }
}
