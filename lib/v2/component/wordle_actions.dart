import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/logic/game_logic.dart';
import 'package:wordle/v2/model/game_model.dart';

import '../../v1/constants/audios.dart';

class WordleActions extends StatelessWidget {
  const WordleActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () {
            internalAudioPlayer.play("keypress-standard.mp3");
          },
          child: const Text("确认"),
        ),
        OutlinedButton(
          onPressed: () {
            internalAudioPlayer.play("keypress-return.mp3");
          },
          child: const Text("设置"),
        ),
        OutlinedButton(
          onPressed: () {
            internalAudioPlayer.play("keypress-delete.mp3");

            Provider.of<GameModel>(context, listen: false).backspaceItem();
          },
          child: const Text("删除"),
        )
      ],
    );
  }
}
