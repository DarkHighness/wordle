import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:wordle/v2/audio/audio.dart';

import '../model/problem_model.dart';

Future<void> showSpeedRunResultDialogInternal(BuildContext context,
    Duration duration, List<Tuple2<ProblemModel, int>> problems) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      List<Widget> children = [
        Text(problems.isEmpty ? "😭😭😭" : "🎉🎉🎉"),
      ];

      if (problems.isEmpty) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("一道也没答上来呢..."),
          ),
        );
      } else {
        var secs = duration.inSeconds;
        var minString = (secs ~/ 60).toString().padLeft(2, '0');
        var secString = (secs % 60).toString().padLeft(2, '0');

        var totalAttempt =
            problems.map((e) => e.item2).reduce((acc, e) => acc + e);
        var avgAttempt = totalAttempt / problems.length;

        children.addAll([
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child:
                Text("共计 ${problems.length} 题, 耗时 $minString 分 $secString 秒"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
                "共尝试 $totalAttempt 次, 平均尝试 ${avgAttempt.toStringAsFixed(2)} 次"),
          ),
        ]);

        children.addAll(
          problems.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(e.item1.word),
            ),
          ),
        );
      }

      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              internalAudioPlayer.play("keypress-return.mp3");

              Navigator.of(context).popUntil(ModalRoute.withName("game"));
              Navigator.of(context).pop();
            },
            child: const Text("退出"),
          )
        ],
      );
    },
  );
}
