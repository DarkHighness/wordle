import 'dart:math';

import 'package:flutter/material.dart';

import '../audio/audio.dart';
import '../component/wordle_character.dart';
import '../measure/text.dart';
import '../model/game_model.dart';
import '../model/problem_model.dart';

Future<void> showResultDialogInternal(
    BuildContext context,
    GameStatus status,
    int attempt,
    Duration duration,
    ProblemModel problem,
    VoidCallback newGameCallback) async {
  await showDialog(
    context: context,
    builder: (context) {
      var statusText = "";
      if (status == GameStatus.statusWon) {
        statusText = "🎉🎉🎉";
      } else if (status == GameStatus.statusLose ||
          status == GameStatus.statusSkipped) {
        statusText = "😭😭😭";
      } else {
        throw Exception(
            "invalid GameStatus when showing result dialog: $status");
      }

      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Text(
                statusText,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: problem.chars.map(
                  (ch) {
                    TextStyle pinyinStyle = const TextStyle(fontSize: 12);

                    TextBox pinyinBox = measureTextBox(
                      context,
                      ch.pinyin!,
                      pinyinStyle,
                      1,
                      TextOverflow.ellipsis,
                      const BoxConstraints.expand(width: 72, height: 72),
                    );

                    return SizedBox(
                      width: max(36, pinyinBox.toRect().width),
                      child: WordleCharacter(
                        character: ch,
                        pinyinStyle: pinyinStyle,
                        characterStyle: const TextStyle(fontSize: 22),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("释义: "),
                  Expanded(
                    child: Text(problem.explanation),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("出处: "),
                  Expanded(
                    child: Text(problem.derivation),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("题目 ID: "),
                      Expanded(
                        child: Text(problem.hash),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text("用时: ${duration.inSeconds} 秒, 尝试: $attempt 次"),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
              onPressed: () {
                internalAudioPlayer.play("keypress-standard.mp3");

                newGameCallback();

                Navigator.of(context).pop();
              },
              child: const Text("新的一轮")),
        ],
      );
    },
  );
}
