import 'package:flutter/material.dart';
import 'package:wordle/components/wordle_problem.dart';

class WordleGuess extends StatelessWidget {
  final List<Item> guess;
  final int length;

  const WordleGuess({Key? key, required this.guess, required this.length})
      : super(key: key);

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
    assert(guess.length / length == 6 && guess.length % length == 0);

    return GridView.count(
      crossAxisCount: length,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      shrinkWrap: true,
      children: guess
          .map(
            (e) => Container(
              decoration: BoxDecoration(
                color: backgroundColorOfStatus(e.status),
                border: Border.all(color: const Color(0xffe6e6e6)),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              child: e.character != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          e.character!.pinyin,
                          style: textStyleOfStatus(e.status),
                        ),
                        SizedBox.fromSize(
                          size: const Size.fromHeight(4),
                        ),
                        Text(
                          e.character!.word,
                          style: textStyleOfStatus(e.status),
                        )
                      ],
                    )
                  : Container(),
            ),
          )
          .toList(),
    );
  }
}
