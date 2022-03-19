import 'package:flutter/material.dart';
import 'package:wordle/components/wordle_guess.dart';
import 'package:wordle/components/wordle_input.dart';
import 'package:wordle/wordle/model.dart';

class WordleProblem extends StatefulWidget {
  final Problem problem;

  const WordleProblem({Key? key, required this.problem}) : super(key: key);

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

  @override
  void initState() {
    inputItems = widget.problem.potentialItems.map((e) => Item(e)).toList();
    guessItems = List.generate(24, (i) => Item.empty());
    answer = [];
    answerWords = {};

    var chs = widget.problem.idiom.word.split('');
    var pinyin = widget.problem.idiom.pinyin.split(' ');

    for (var i = 0; i < 4; i++) {
      answer.add(Character(chs[i], pinyin[i]));
      answerWords.add(chs[i]);
    }

    length = 4;
    idx = 0;
    tries = 0;

    super.initState();
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
      for (var i = tries * length; i < (tries + 1) * length; i++) {
        if (guessItems[i].character == answer[i % length]) {
          guessItems[i].status = ItemStatus.ok;

          for (var item in inputItems) {
            if (item.character == guessItems[i].character) {
              item.status = ItemStatus.ok;
              break;
            }
          }
        } else if (answerWords.contains(guessItems[i].character!.word)) {
          guessItems[i].status = ItemStatus.exists;

          for (var item in inputItems) {
            if (item.character == guessItems[i].character) {
              item.status = ItemStatus.exists;
              break;
            }
          }
        } else {
          guessItems[i].status = ItemStatus.missing;

          for (var item in inputItems) {
            if (item.character == guessItems[i].character) {
              item.status = ItemStatus.missing;
              break;
            }
          }
        }
      }

      tries++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WordleGuess(guess: guessItems, length: length),
          SizedBox.fromSize(
            size: const Size.fromHeight(8),
          ),
          WordleInput(
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
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    checkGuess();
                  },
                  child: Text("确认"),
                ),
                OutlinedButton(
                  onPressed: () {
                    removeGuess();
                  },
                  child: Text("删除"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
