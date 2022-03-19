import 'package:flutter/material.dart';
import 'package:wordle/components/wordle_guess.dart';
import 'package:wordle/components/wordle_input.dart';
import 'package:wordle/constants/audios.dart';
import 'package:wordle/util.dart';
import 'package:wordle/wordle/db.dart';
import 'package:wordle/wordle/model.dart';

class WordleProblem extends StatefulWidget {
  final IdiomDb db;
  final Problem problem;
  final Function(bool) callback;

  const WordleProblem(
      {Key? key,
      required this.db,
      required this.problem,
      required this.callback})
      : super(key: key);

  @override
  State<WordleProblem> createState() => _WordleProblemState();
}

enum ItemStatus { invalid, missing, exists, ok }

class Item {
  Character? character;
  ItemStatus status;

  Item(this.character) : status = ItemStatus.invalid;

  Item.empty()
      : character = null,
        status = ItemStatus.invalid;
}

class _WordleProblemState extends State<WordleProblem> {
  late List<Item> inputItems;
  late List<Item> guessItems;
  late List<Character> answer;
  late Set<String> answerWords;
  late int idx;
  late int length;
  late int tries;
  late GlobalKey guessKey;
  late GlobalKey inputKey;

  @override
  void initState() {
    guessKey = GlobalKey();
    inputKey = GlobalKey();

    init();

    super.initState();
  }

  void init() {
    inputItems = widget.problem.potentialItems.map((e) => Item(e)).toList();
    guessItems = List.generate(
        6 * widget.problem.idiom.word.length, (i) => Item.empty());
    answer = [];
    answerWords = {};

    var chs = widget.problem.idiom.word.split('');
    var pinyin = widget.problem.idiom.pinyin.split(' ');

    for (var i = 0; i < chs.length; i++) {
      answer.add(Character(chs[i], getOrDefault(pinyin, i, " ")));
      answerWords.add(chs[i]);
    }

    length = answer.length;
    idx = 0;
    tries = 0;
  }

  void removeGuess() {
    if (idx == tries * length) {
      return;
    }

    setState(() {
      guessItems[idx - 1] = Item.empty();

      idx--;
    });
  }

  void checkGuess() {
    if (idx != (tries + 1) * length) {
      return;
    }

    setState(() {
      var right = 0;
      var word = "";

      for (var i = tries * length; i < (tries + 1) * length; i++) {
        word += guessItems[i].character!.word;
      }

      if (widget.problem.idiom.type == "idiom" && !widget.db.isValid(word)) {
        (guessKey.currentState as dynamic).shake(tries);

        return;
      }

      for (var i = tries * length; i < (tries + 1) * length; i++) {
        if (guessItems[i].character == answer[i % length]) {
          guessItems[i].status = ItemStatus.ok;

          for (var item in inputItems) {
            if (item.status == ItemStatus.invalid &&
                item.character == guessItems[i].character) {
              item.status = ItemStatus.ok;
              break;
            }
          }

          right++;

          if (right == length) {
            (guessKey.currentState as dynamic).flip(tries);

            widget.callback(true);

            return;
          }

          continue;
        }

        if (answerWords.contains(guessItems[i].character!.word)) {
          guessItems[i].status = ItemStatus.exists;

          for (var item in inputItems) {
            if (item.status == ItemStatus.invalid &&
                item.character == guessItems[i].character) {
              item.status = ItemStatus.exists;
              break;
            }
          }

          continue;
        }

        guessItems[i].status = ItemStatus.missing;

        for (var item in inputItems) {
          if (item.status == ItemStatus.invalid &&
              item.character == guessItems[i].character) {
            item.status = ItemStatus.missing;
            break;
          }
        }
      }

      (guessKey.currentState as dynamic).flip(tries);

      tries++;

      if (tries >= 6) {
        widget.callback(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 24,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WordleGuess(
                key: guessKey, guess: guessItems, idx: idx, length: length),
            SizedBox.fromSize(
              size: const Size.fromHeight(8),
            ),
            WordleInput(
              key: inputKey,
              items: inputItems,
              onTap: (Item item) {
                setState(() {
                  if ((tries + 1) * length <= idx) {
                    return;
                  }

                  guessItems[idx] = Item(item.character);

                  idx++;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      internalAudioPlayer.play("keypress-standard.mp3");

                      checkGuess();
                    },
                    child: const Text("确认"),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      internalAudioPlayer.play("keypress-delete.mp3");

                      widget.callback(false);
                    },
                    child: const Text("放弃"),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      internalAudioPlayer.play("keypress-delete.mp3");

                      removeGuess();
                    },
                    child: const Text("删除"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant WordleProblem oldWidget) {
    if (oldWidget.problem != widget.problem) {
      init();
    }

    super.didUpdateWidget(oldWidget);
  }
}
