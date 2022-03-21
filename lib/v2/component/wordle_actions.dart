import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:wordle/v2/component/scale_animated_text.dart';
import 'package:wordle/v2/config/config.dart';
import 'package:wordle/v2/logic/game_logic.dart';
import 'package:wordle/v2/model/game_model.dart';
import 'package:wordle/v2/page/game_page.dart';

import '../audio/audio.dart';
import '../util/event_bus.dart';

class WordleActions extends StatelessWidget {
  const WordleActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameModel, GameStatus>(
      selector: (context, model) => (model.gameStatus),
      builder: (context, status, child) {
        return Selector<GamePageState, Tuple2<GameMode, Duration>>(
          selector: (context, state) =>
              Tuple2(state.widget.gameMode, state.timeLeft),
          builder: (context, item, child) {
            List<Widget> children = [];

            if (status == GameStatus.statusRunning ||
                status == GameStatus.statusPausing) {
              var submitButton = OutlinedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 32)),
                ),
                onLongPress: () {
                  if (item.item1 != GameMode.modeSpeedRun) {
                    return;
                  }

                  internalAudioPlayer.play("keypress-standard.mp3");

                  var gamePageState = context.read<GamePageState>();

                  gamePageState.resetGameModel();
                },
                onPressed: () {
                  internalAudioPlayer.play("keypress-standard.mp3");

                  var model = context.read<GameModel>();
                  var checkStatus = model.checkInput();

                  if (checkStatus == CheckStatus.statusInvalidInput) {
                    context.read<EventBus>().emit("row-shaking", model.attempt);
                  }
                },
                child: item.item1 == GameMode.modeSpeedRun
                    ? const Text("确认/长按跳过")
                    : const Text("确认"),
              );

              var backspaceButton = OutlinedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 32)),
                ),
                onPressed: () {
                  internalAudioPlayer.play("keypress-delete.mp3");

                  context.read<GameModel>().backspaceItem();
                },
                child: const Text("删除"),
              );

              if (item.item1 == GameMode.modeSpeedRun) {
                var secs = item.item2.inSeconds;
                var minString = (secs ~/ 60).toString().padLeft(2, '0');
                var secString = (secs % 60).toString().padLeft(2, '0');

                TextStyle textStyle;

                if (secs < modeSpeedRunEmergingSecs) {
                  textStyle = const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffc04851),
                  );
                } else {
                  textStyle = const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold);
                }

                var timerText = Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Opacity(
                    opacity: 0.6,
                    child: ScaleAnimatedText(
                      text: "$minString:$secString",
                      scalingFactor: 0.5,
                      textStyle: textStyle,
                      duration: const Duration(seconds: 1),
                    ),
                  ),
                );

                // var timerText = Padding(padding: const EdgeInsets.only(top: 8), child: Text("$minString:$secString", style: textStyle,),);

                children = [submitButton, timerText, backspaceButton];
              } else {
                children = [submitButton, backspaceButton];
              }
            } else {
              children = [
                OutlinedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 32)),
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
                        const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 32)),
                  ),
                  onPressed: () {
                    internalAudioPlayer.play("keypress-standard.mp3");

                    var bus = context.read<EventBus>();

                    bus.emit("screenshot");
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
      },
    );
  }
}
