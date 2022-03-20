import 'package:flutter/material.dart';
import 'package:wordle/v2/component/wordle_character.dart';

import '../model/game_model.dart';

class WordleDisplayRow extends StatelessWidget {
  final List<InputItem> items;

  const WordleDisplayRow({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  }
}
