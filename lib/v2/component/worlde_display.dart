import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/component/wordle_display_row.dart';
import 'package:wordle/v2/model/game_model.dart';

class WordleDisplay extends StatelessWidget {
  const WordleDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, List<List<InputItem>>>(
      builder: (_, logs, __) {
        return Column(
          children: logs
              .map(
                (e) => Expanded(
                  child: WordleDisplayRow(items: e),
                ),
              )
              .toList(),
        );
      },
      selector: (_, model) => model.guessLogs,
    );
  }
}
