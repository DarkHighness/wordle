import 'package:flutter/material.dart';
import 'package:wordle/v2/model/problem_model.dart';

class WordleCharacter extends StatelessWidget {
  final Character? character;
  final TextStyle characterStyle;
  final TextStyle pinyinStyle;
  final double spacing;

  const WordleCharacter({
    Key? key,
    required this.character,
    this.characterStyle = const TextStyle(fontSize: 16),
    this.pinyinStyle = const TextStyle(fontSize: 12),
    this.spacing = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (character != null) {
      if (character!.pinyin != null) {
        children = [
          Text(
            character!.pinyin!,
            style: pinyinStyle,
          ),
          SizedBox.fromSize(
            size: Size.fromHeight(spacing),
          ),
          Text(
            character!.char,
            style: characterStyle,
          ),
        ];
      } else {
        children = [
          Text(
            character!.char,
            style: characterStyle,
          ),
        ];
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
