import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/v2/logic/game_logic.dart';
import 'package:wordle/v2/model/game_model.dart';
import 'package:wordle/v2/page/game_page.dart';

import '../audio/audio.dart';

class WordleActions extends StatelessWidget {
  const WordleActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, GameStatus>(
      selector: (context, model) => model.gameStatus,
      builder: (context, status, child) {
        List<Widget> children = [];

        if (status == GameStatus.statusRunning ||
            status == GameStatus.statusPausing) {
          children = [
            OutlinedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 32)),
              ),
              onPressed: () {
                internalAudioPlayer.play("keypress-standard.mp3");

                context.read<GameModel>().checkInput();
              },
              child: const Text("确认"),
            ),
            OutlinedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 32)),
              ),
              onPressed: () {
                internalAudioPlayer.play("keypress-delete.mp3");

                context.read<GameModel>().backspaceItem();
              },
              child: const Text("删除"),
            )
          ];
        } else {
          children = [
            OutlinedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 32)),
              ),
              onPressed: () {
                internalAudioPlayer.play("keypress-standard.mp3");

                context.read<GamePageState>().showResultDialog();
              },
              child: const Text("信息"),
            ),
            OutlinedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 32)),
              ),
              onPressed: () {
                internalAudioPlayer.play("keypress-standard.mp3");
              },
              child: const Text("截图"),
            ),
          ];
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        );
      },
    );
  }
}
