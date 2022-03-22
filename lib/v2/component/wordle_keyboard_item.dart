import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/audio/audio.dart';
import 'package:wordle/v2/component/wordle_character.dart';
import 'package:wordle/v2/logic/game_logic.dart';

import '../config/color.dart';
import '../model/game_model.dart';

class WordleKeyboardItem extends StatefulWidget {
  final int choiceIndex;

  const WordleKeyboardItem({Key? key, required this.choiceIndex})
      : super(key: key);

  @override
  _WordleKeyboardItemState createState() => _WordleKeyboardItemState();
}

class _WordleKeyboardItemState extends State<WordleKeyboardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  InputStatus _prevInputStatus = InputStatus.statusInvalid;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _flipAnimation = Tween(begin: 2 * pi, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

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
      case InputStatus.statusHint:
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
      case InputStatus.statusHint:
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
      case InputStatus.statusHint:
      case InputStatus.statusInvalid:
        return const ButtonStyle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, InputItem>(
      selector: (context, model) =>
          model.inputChoices[widget.choiceIndex].copyWith(),
      builder: (context, item, child) {
        if (_prevInputStatus == InputStatus.statusInvalid &&
            item.status != InputStatus.statusInvalid) {
          _prevInputStatus = item.status;

          _controller.reset();
          _controller.forward();
        } else {
          _prevInputStatus = InputStatus.statusInvalid;
        }

        return AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            var matrix4 = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_flipAnimation.value);

            return Transform(
              transform: matrix4,
              child: child,
              alignment: Alignment.center,
            );
          },
          child: OutlinedButton(
            onPressed: () {
              internalAudioPlayer.play("keypress-standard.mp3");

              Provider.of<GameModel>(context, listen: false).enterItem(item);
            },
            style: containerStyle(item),
            child: WordleCharacter(
              character: item.character,
              characterStyle: characterStyle(item),
              pinyinStyle: pinyinStyle(item),
            ),
          ),
        );
      },
    );
  }
}
