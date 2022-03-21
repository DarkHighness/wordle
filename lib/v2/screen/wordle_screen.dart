import 'package:flutter/material.dart';
import 'package:wordle/v2/component/wordle_display.dart';
import 'package:wordle/v2/component/wordle_keyboard.dart';

import '../component/wordle_actions.dart';

class WordleScreen extends StatelessWidget {
  const WordleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Flexible(
            flex: 14,
            child: WordleDisplay(),
          ),
          SizedBox.fromSize(
            size: const Size.fromHeight(4.0),
          ),
          const Flexible(
            flex: 6,
            child: WordleKeyBoard(),
          ),
          SizedBox.fromSize(
            size: const Size.fromHeight(4.0),
          ),
          const Flexible(
            flex: 1,
            child: Center(
              child: WordleActions(),
            ),
          ),
          SizedBox.fromSize(
            size: const Size.fromHeight(8.0),
          ),
        ],
      ),
    );
  }
}
