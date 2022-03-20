import 'package:flutter/material.dart';
import 'package:wordle/v1/components/wordle_letter.dart';
import 'package:wordle/v1/components/wordle_problem.dart';
import 'package:wordle/v1/constants/audios.dart';

class WordleInput extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onTap;

  const WordleInput({Key? key, required this.items, required this.onTap})
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

  TextStyle textStyleForStatus(bool word, ItemStatus status) {
    switch (status) {
      case ItemStatus.invalid:
        return TextStyle(
          fontSize: word ? 16 : 10,
          color: Colors.black,
        );
      case ItemStatus.missing:
      case ItemStatus.exists:
      case ItemStatus.ok:
        return TextStyle(
          fontSize: word ? 16 : 10,
          color: Colors.white,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 6,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        shrinkWrap: true,
        children: items
            .map(
              (e) => OutlinedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      backgroundColorOfStatus(e.status)),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () {
                  internalAudioPlayer.play("keypress-standard.mp3");

                  onTap(e);
                },
                child: WordleLetter(
                  character: e.character!,
                  pinyinStyle: textStyleForStatus(false, e.status),
                  wordStyle: textStyleForStatus(true, e.status),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}