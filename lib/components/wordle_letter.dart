import 'package:flutter/material.dart';
import 'package:wordle/wordle/model.dart';

class WordleLetter extends StatelessWidget {
  final Character character;
  final TextStyle pinyinStyle;
  final TextStyle wordStyle;

  const WordleLetter({
    Key? key,
    required this.character,
    required this.pinyinStyle,
    required this.wordStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var children;

    if (character.pinyin != "") {
      children = [
        Text(
          character.pinyin,
          style: pinyinStyle,
        ),
        SizedBox.fromSize(
          size: const Size.fromHeight(4),
        ),
        Text(
          character.word,
          style: wordStyle,
        )
      ];
    } else {
      children = [
        Text(
          character.word,
          style: wordStyle,
        )
      ];
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
