import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wordle/components/wordle_letter.dart';
import 'package:wordle/components/wordle_problem.dart';
import 'package:wordle/wordle/model.dart';

class WordleGuess extends StatefulWidget {
  final List<Item> guess;
  final int length;
  final int idx;

  const WordleGuess(
      {Key? key, required this.idx, required this.guess, required this.length})
      : super(key: key);

  @override
  State<WordleGuess> createState() => _WordleGuessState();
}

class SineCurve extends Curve {
  const SineCurve({this.count = 3});

  final double count;

  // 2. override transformInternal() method
  @override
  double transformInternal(double t) {
    return sin(count * 2 * pi * t);
  }
}

class _WordleGuessState extends State<WordleGuess>
    with TickerProviderStateMixin {
  late List<AnimationController> shakeControllers;
  late List<Animation<double>> shakeAnimations;
  late List<AnimationController> scaleControllers;
  late List<Animation<double>> scaleAnimations;
  late List<AnimationController> flipControllers;
  late List<Animation<double>> flipAnimations;

  int shakeCount = 2;
  int shakeOffset = 10;

  int shakingRow = -1;

  @override
  void initState() {
    shakeControllers = List.generate(
        widget.guess.length ~/ widget.length,
        (_) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 500)));

    shakeAnimations =
        List.generate(widget.guess.length ~/ widget.length, (index) {
      var animation = Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: shakeControllers[index],
        curve: SineCurve(count: shakeCount.toDouble()),
      ));

      animation.addStatusListener((status) {
        if (animation.isCompleted) {
          shakeControllers[index].reset();
          shakeControllers[index].stop();

          setState(() {
            shakingRow = -1;
          });
        } else if (animation.isDismissed) {
          shakeControllers[index].forward();
        }
      });

      return animation;
    });

    scaleControllers = List.generate(
        widget.guess.length,
        (_) => AnimationController(
              vsync: this,
              duration: const Duration(seconds: 1),
            ));

    scaleAnimations = List.generate(
      widget.guess.length,
      (index) {
        var animation = Tween(begin: 2.0, end: 1.0).animate(CurvedAnimation(
            parent: scaleControllers[index], curve: Curves.easeOutQuad));

        return animation;
      },
    );

    flipControllers = List.generate(
        widget.guess.length,
        (_) => AnimationController(
              vsync: this,
              duration: const Duration(seconds: 1),
            ));

    flipAnimations = List.generate(
      widget.guess.length,
      (index) {
        var animation = Tween(begin: 2 * pi, end: 0.0).animate(CurvedAnimation(
            parent: flipControllers[index], curve: Curves.easeOutQuad));

        return animation;
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    for (var controller in scaleControllers) {
      controller.dispose();
    }

    for (var controller in shakeControllers) {
      controller.dispose();
    }

    for (var controller in flipControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void shake(int row) {
    setState(() {
      shakingRow = row;
    });

    shakeControllers[row].reset();
    shakeControllers[row].forward();
  }

  Future<void> flip(int row) async {
    for (var i = row * widget.length; i < (row + 1) * widget.length; i++) {
      flipControllers[i].reset();
      flipControllers[i].forward();

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Color backgroundColorOfStatus(ItemStatus status) {
    switch (status) {
      case ItemStatus.invalid:
        return Colors.white;
      case ItemStatus.missing:
        return const Color(0xff808080);
      case ItemStatus.exists:
        return const Color(0xffffa500);
      case ItemStatus.ok:
        return const Color(0xff008000);
    }
  }

  TextStyle textStyleOfStatus(ItemStatus status) {
    switch (status) {
      case ItemStatus.invalid:
        return const TextStyle(fontSize: 26, color: Colors.black);
      case ItemStatus.missing:
      case ItemStatus.exists:
      case ItemStatus.ok:
        return const TextStyle(fontSize: 26, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    // assert(widget.guess.length ~/ widget.length == 6 &&
    //     widget.guess.length % widget.length == 0);

    scaleControllers[widget.idx].reset();
    scaleControllers[widget.idx].forward();

    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        List<Widget> children = [];

        for (var i = index * widget.length;
            i < (index + 1) * widget.length;
            i++) {
          var e = widget.guess[i];

          children.add(
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: AnimatedBuilder(
                animation: flipAnimations[i],
                child: Container(
                  width: (MediaQuery.of(context).size.width -
                          (widget.length) * 8) /
                      widget.length,
                  height: (MediaQuery.of(context).size.width -
                          (widget.length) * 8) /
                      widget.length,
                  decoration: BoxDecoration(
                    color: backgroundColorOfStatus(e.status),
                    border: Border.all(
                        color: shakingRow == index
                            ? Colors.red
                            : const Color(0xffe2e2e2)),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: e.character != null
                      ? ScaleTransition(
                          scale: scaleAnimations[i],
                          child: WordleLetter(
                            character: e.character!,
                            pinyinStyle: textStyleOfStatus(e.status),
                            wordStyle: textStyleOfStatus(e.status),
                          ),
                        )
                      : WordleLetter(
                          character: Character("", ""),
                          pinyinStyle: textStyleOfStatus(e.status),
                          wordStyle: textStyleOfStatus(e.status)),
                ),
                builder: (context, child) {
                  var matrix4 = Matrix4.identity();

                  matrix4.setEntry(3, 2, 0.001);
                  matrix4.rotateX(flipAnimations[i].value);

                  return Transform(
                    transform: matrix4,
                    child: child,
                    alignment: Alignment.center,
                  );
                },
              ),
            ),
          );
        }

        return AnimatedBuilder(
          animation: shakeAnimations[index],
          child: Row(
            children: children,
          ),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(shakeAnimations[index].value * shakeOffset, 0),
              child: child,
            );
          },
        );
      },
      itemCount: widget.guess.length ~/ widget.length,
    );
  }
}
