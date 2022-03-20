import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/audio/audio.dart';
import 'package:wordle/v2/component/wordle_character.dart';
import 'package:wordle/v2/model/game_model.dart';

class WordleKeyBoard extends StatelessWidget {
  const WordleKeyBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel?, List<InputItem>>(
      builder: (_, choices, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: GridView.count(
            crossAxisCount: 6,
            mainAxisSpacing: 2.0,
            crossAxisSpacing: 2.0,
            children: choices
                .map(
                  (e) => OutlinedButton(
                    onPressed: () {
                      internalAudioPlayer.play("keypress-standard.mp3");
                    },
                    child: WordleCharacter(
                      character: e.character,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
      selector: (context, model) => model?.inputChoices ?? [],
    );
  }
}
