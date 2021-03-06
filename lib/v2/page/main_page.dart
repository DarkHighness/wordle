import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:wordle/v2/dialog/text_input_dialog.dart';
import 'package:wordle/v2/model/game_model.dart';
import 'package:wordle/v2/model/problem_model.dart';
import 'package:wordle/v2/page/game_page.dart';

import '../audio/audio.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();

    internalAudioPlayer.loadAll([
      "keypress-standard.mp3",
      "keypress-delete.mp3",
      "keypress-return.mp3"
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      primary: const Color(0xfffffef8),
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 8),
      textStyle: const TextStyle(fontSize: 22, letterSpacing: 8.0),
    );

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Svg("assets/images/welcome_background.svg"),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.translationValues(8.0, 0.0, 0.0)
                    ..rotateZ(-pi / 15),
                  child: const Text(
                    "Wordle",
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        backgroundColor: Colors.black),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-8, 15),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontFamily: "LXGWWenKaiScreen",
                          fontSize: 16,
                          backgroundColor: Colors.black),
                      children: [
                        TextSpan(
                          text: "???, ???",
                        ),
                        TextSpan(
                          text: "??????",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8),
                        ),
                        TextSpan(text: "??????"),
                        TextSpan(
                          text: "??????",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(32),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: ElevatedButton(
                style: style,
                onPressed: () {
                  internalAudioPlayer.play("keypress-standard.mp3");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: "game"),
                      builder: (context) {
                        return const GamePage(
                          gameMode: GameMode.modeNormal,
                          problemType: ProblemType.typeIdiom,
                          problemDifficulty: ProblemDifficulty.difficultyEasy,
                        );
                      },
                    ),
                  );
                },
                child: const Text("????????????"),
              ),
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(8),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: ElevatedButton(
                style: style,
                onPressed: () {
                  internalAudioPlayer.play("keypress-standard.mp3");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: "game"),
                      builder: (context) {
                        return const GamePage(
                          gameMode: GameMode.modeNormal,
                          problemType: ProblemType.typeIdiom,
                          problemDifficulty: ProblemDifficulty.difficultyHard,
                        );
                      },
                    ),
                  );
                },
                child: const Text("????????????(??????)"),
              ),
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(8),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: ElevatedButton(
                style: style,
                onPressed: () {
                  internalAudioPlayer.play("keypress-standard.mp3");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: "game"),
                      builder: (context) {
                        return const GamePage(
                          gameMode: GameMode.modeNormal,
                          problemType: ProblemType.typePoem,
                          problemDifficulty: ProblemDifficulty.difficultyEasy,
                        );
                      },
                    ),
                  );
                },
                child: const Text("????????????"),
              ),
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(8),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: ElevatedButton(
                style: style,
                onPressed: () {
                  internalAudioPlayer.play("keypress-standard.mp3");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: "game"),
                      builder: (context) {
                        return const GamePage(
                          gameMode: GameMode.modeNormal,
                          problemType: ProblemType.typePoem,
                          problemDifficulty: ProblemDifficulty.difficultyHard,
                        );
                      },
                    ),
                  );
                },
                child: const Text("????????????(??????)"),
              ),
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(8),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: ElevatedButton(
                style: style,
                onPressed: () {
                  internalAudioPlayer.play("keypress-standard.mp3");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: "game"),
                      builder: (context) {
                        return const GamePage(
                          gameMode: GameMode.modeSpeedRun,
                          problemType: ProblemType.typeIdiom,
                          problemDifficulty: ProblemDifficulty.difficultyEasy,
                        );
                      },
                    ),
                  );
                },
                child: const Text("????????????"),
              ),
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(8),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: ElevatedButton(
                style: style,
                onPressed: () {
                  internalAudioPlayer.play("keypress-standard.mp3");

                  showTextInputDialogInternal(context, title: "?????? ID",
                      predicate: (e) {
                    var regex =
                        RegExp("\\w+", multiLine: true, caseSensitive: false);

                    return regex.hasMatch(e);
                  }).then((hash) {
                    if (hash != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: "game"),
                          builder: (context) {
                            return GamePage(
                              initialProblemId: hash,
                              gameMode: GameMode.modeNormal,
                              problemType: ProblemType.typeIdiom,
                              problemDifficulty:
                                  ProblemDifficulty.difficultyEasy,
                            );
                          },
                        ),
                      );
                    }
                  });
                },
                child: const Text("????????????"),
              ),
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(8),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: ElevatedButton(
                style: style,
                onPressed: () {
                  internalAudioPlayer.play("keypress-standard.mp3");
                },
                child: const Text("????????????"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
