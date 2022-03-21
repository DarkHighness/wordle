import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/component/wordle_character.dart';
import 'package:wordle/v2/config/color.dart';
import 'package:wordle/v2/util.dart';

import '../model/game_model.dart';

class WordleDisplayRow extends StatelessWidget {
  final int rowIndex;

  const WordleDisplayRow({Key? key, required this.rowIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, int>(
      selector: (context, model) {
        return model.guessLogs[rowIndex].length;
      },
      builder: (context, len, child) {
        return Row(
          children: len
              .rangeUntil(from: 0)
              .map(
                (e) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: WordleDisplayRowItem(
                      rowIndex: rowIndex,
                      colIndex: e,
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

class WordleDisplayRowItem extends StatelessWidget {
  final int rowIndex;
  final int colIndex;

  const WordleDisplayRowItem({
    Key? key,
    required this.rowIndex,
    required this.colIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, InputItem>(
      selector: (context, model) =>
          model.guessLogs[rowIndex][colIndex].copyWith(),
      builder: (context, item, child) {
        return Container(
          decoration: containerStyle(item),
          child: WordleCharacter(
            character: item.character,
            characterStyle: characterStyle(item),
            pinyinStyle: pinyinStyle(item),
          ),
        );
      },
    );
  }

  TextStyle characterStyle(InputItem item) {
    switch (item.status) {
      case InputStatus.statusOk:
      case InputStatus.statusPartialPosition:
      case InputStatus.statusPartialCharacter:
      case InputStatus.statusMissing:
        return const TextStyle(
          fontSize: 22,
          color: Colors.white,
        );
      case InputStatus.statusInvalid:
        return const TextStyle(
          fontSize: 22,
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

  BoxDecoration containerStyle(InputItem item) {
    switch (item.status) {
      case InputStatus.statusOk:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: statusOkBgColor,
        );
      case InputStatus.statusPartialPosition:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: statusPartialPositionBgColor,
        );
      case InputStatus.statusPartialCharacter:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: statusPartialCharacterBgColor,
        );
      case InputStatus.statusMissing:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: statusMissingBgColor,
        );
      case InputStatus.statusInvalid:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: const Color(0xffE4E7ED),
          ),
          color: Colors.white,
        );
    }
  }
}
