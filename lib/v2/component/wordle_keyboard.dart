import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/audio/audio.dart';
import 'package:wordle/v2/component/wordle_character.dart';
import 'package:wordle/v2/logic/game_logic.dart';
import 'package:wordle/v2/model/game_model.dart';

import '../config/color.dart';

class WordleKeyBoard extends StatelessWidget {
  const WordleKeyBoard({Key? key}) : super(key: key);

  TextStyle characterStyle(InputItem item) {
    switch (item.status) {
      case InputStatus.statusOk:
      case InputStatus.statusPartialPosition:
      case InputStatus.statusPartialCharacter:
      case InputStatus.statusMissing:
        return const TextStyle(
          fontSize: 16,
          color: Colors.white,
        );
      case InputStatus.statusInvalid:
        return const TextStyle(
          fontSize: 16,
          color: Colors.black,
        );
    }
  }

  TextStyle pinyinStyle(InputItem item) {
    switch (item.status) {
      case InputStatus.statusOk:
      case InputStatus.statusPartialPosition:
      case InputStatus.statusPartialCharacter:
      case InputStatus.statusMissing:
        return const TextStyle(
          fontSize: 9,
          color: Colors.white,
        );
      case InputStatus.statusInvalid:
        return const TextStyle(
          fontSize: 9,
          color: Colors.black,
        );
    }
  }

  ButtonStyle containerStyle(InputItem item) {
    switch (item.status) {
      case InputStatus.statusOk:
        return ButtonStyle(
          backgroundColor: MaterialStateProperty.all(statusOkBgColor),
        );
      case InputStatus.statusPartialPosition:
        return ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(statusPartialPositionBgColor),
        );
      case InputStatus.statusPartialCharacter:
        return ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(statusPartialCharacterBgColor),
        );
      case InputStatus.statusMissing:
        return ButtonStyle(
          backgroundColor: MaterialStateProperty.all(statusMissingBgColor),
        );
      case InputStatus.statusInvalid:
        return const ButtonStyle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, List<InputItem>>(
      selector: (context, model) => List.generate(
          model.inputChoices.length, (i) => model.inputChoices[i].copyWith()),
      builder: (context, choices, child) {
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

                      Provider.of<GameModel>(context, listen: false)
                          .enterItem(e);
                    },
                    style: containerStyle(e),
                    child: WordleCharacter(
                      character: e.character,
                      characterStyle: characterStyle(e),
                      pinyinStyle: pinyinStyle(e),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
