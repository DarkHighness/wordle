import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/component/wordle_character.dart';
import 'package:wordle/v2/component/wordle_display.dart';

import '../config/color.dart';
import '../model/game_model.dart';
import '../model/problem_model.dart';

class WordleDisplayRowItem extends StatefulWidget {
  final int rowIndex;
  final int colIndex;
  final bool shaking;

  const WordleDisplayRowItem({
    Key? key,
    required this.rowIndex,
    required this.colIndex,
    required this.shaking,
  }) : super(key: key);

  @override
  State<WordleDisplayRowItem> createState() => _WordleDisplayRowItemState();
}

class _WordleDisplayRowItemState extends State<WordleDisplayRowItem>
    with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late AnimationController _flipAnimationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _flipAnimation;

  Character? _prevCharacter;
  InputStatus _prevInputStatus = InputStatus.statusInvalid;

  @override
  void initState() {
    super.initState();

    _scaleAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _flipAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _scaleAnimation = Tween(begin: 2.0, end: 1.0).animate(CurvedAnimation(
        parent: _scaleAnimationController, curve: Curves.easeOutQuad));

    _flipAnimation = Tween(begin: 2 * pi, end: 0.0).animate(CurvedAnimation(
        parent: _flipAnimationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _flipAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, InputItem>(
      selector: (context, model) =>
          model.inputLogs[widget.rowIndex][widget.colIndex].copyWith(),
      builder: (context, item, child) {
        if (_prevCharacter == null && item.character != null) {
          _prevCharacter = item.character;

          _scaleAnimationController.reset();
          _scaleAnimationController.forward();
        } else if (item.character == null) {
          _prevCharacter = null;
        }

        if (_prevInputStatus == InputStatus.statusInvalid &&
            item.status != InputStatus.statusInvalid) {
          _prevInputStatus = item.status;

          Future.delayed(Duration(milliseconds: 200 * widget.colIndex), () {
            _flipAnimationController.reset();
            _flipAnimationController.forward();
          });
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
          child: Selector<DisplayModel, DisplayStatus>(
            selector: (context, model) => model.displayStatus,
            builder: (context, status, child) {
              if (status == DisplayStatus.statusFull) {
                return child!;
              } else {
                return Container(
                  decoration: containerStyle(item),
                );
              }
            },
            child: AnimatedContainer(
              decoration: containerStyle(item),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInCubic,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: WordleCharacter(
                  character: item.character,
                  characterStyle: characterStyle(item),
                  pinyinStyle: pinyinStyle(item),
                ),
              ),
            ),
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
      case InputStatus.statusHint:
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
      case InputStatus.statusHint:
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
      case InputStatus.statusHint:
      case InputStatus.statusInvalid:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: widget.shaking
                ? const Color(0xffee3f4d)
                : const Color(0xffE4E7ED),
          ),
          color: Colors.white,
        );
    }
  }
}
