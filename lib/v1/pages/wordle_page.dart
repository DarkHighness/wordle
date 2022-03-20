import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle/v1/components/wordle_problem.dart';
import 'package:wordle/v1/constants/audios.dart';
import 'package:wordle/v1/util.dart';
import 'package:wordle/v1/wordle/db.dart';
import 'package:wordle/v1/wordle/model.dart';
import 'package:wordle/v1/wordle/util.dart';

enum ProblemStatus { won, lose, running }

class WordlePage extends StatefulWidget {
  const WordlePage({Key? key}) : super(key: key);

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  UserDb? userDb;
  IdiomDb? idiomDb;
  Problem? problem;
  List<Character>? answer;
  ProblemStatus status = ProblemStatus.running;

  Future<Problem> randomProblem(String type, int? seed) async {
    idiomDb ??= await setupIdiomDb();

    var _problem = idiomDb!.randomProblem(type, seed);

    return _problem;
  }

  Future<Problem> pickProblem(String hash) async {
    idiomDb ??= await setupIdiomDb();

    var _problem = idiomDb!.pickProblem(hash);

    if (_problem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("题目 $hash 不存在"),
          duration: const Duration(seconds: 1),
        ),
      );

      throw Exception("invalid problem hash: $hash");
    }

    return _problem;
  }

  Future<void> initProblem(Problem newProblem) async {
    setState(() {
      problem = newProblem;

      List<Character> _answer = [];

      var chs = newProblem.idiom.word.split('');
      var pinyin = newProblem.idiom.pinyin.split(' ');

      for (var i = 0; i < chs.length; i++) {
        _answer.add(Character(chs[i], getOrDefault(pinyin, i, " ")));
      }

      answer = _answer;
      status = ProblemStatus.running;
    });
  }

  Future<void> setup() async {
    var f1 = randomProblem("idiom", null).then(initProblem);

    var f2 = setupUserDb().then((db) => userDb = db);

    await Future.wait([f1, f2]);
  }

  late Future<void> setupFuture;

  @override
  void initState() {
    internalAudioPlayer.loadAll([
      "keypress-standard.mp3",
      "keypress-delete.mp3",
      "keypress-return.mp3"
    ]);

    setupFuture = setup();

    super.initState();
  }

  Future<void> seedInputDialog() async {
    var controller = TextEditingController.fromValue(TextEditingValue.empty);

    var clipboard = await Clipboard.getData("text/plain");
    var hashValue = "";

    if (clipboard != null && clipboard.text != null) {
      var text = clipboard.text!;

      if (text.length == 8) {
        controller.text = text;
        hashValue = text;
      }
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('题目ID'),
            content: TextField(
              onChanged: (value) {
                hashValue = value;
              },
              controller: controller,
              decoration: const InputDecoration(hintText: "题目ID"),
            ),
            actions: [
              OutlinedButton(
                onPressed: () async {
                  internalAudioPlayer.play("keypress-standard.mp3");

                  try {
                    var problem = await pickProblem(hashValue);

                    initProblem(problem);
                  } on ArgumentError {
                    debugPrint("missing problem id $hashValue");
                  }

                  Navigator.pop(context);
                },
                child: const Text("确定"),
              ),
              OutlinedButton(
                onPressed: () {
                  internalAudioPlayer.play("keypress-delete.mp3");

                  Navigator.pop(context);
                },
                child: const Text("取消"),
              )
            ],
          );
        });
  }

  Future<void> settingsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("已解决: "),
                  Text("${userDb!.solvedCnt()} / ${idiomDb!.problemCnt()}")
                ],
              ),
              SizedBox.fromSize(size: const Size.fromHeight(4.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 9,
                    child: LinearProgressIndicator(
                      value: userDb!.solvedCnt() / idiomDb!.problemCnt(),
                      color: Colors.indigo,
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  Flexible(
                      flex: 2,
                      child: Text((userDb!.solvedCnt() / idiomDb!.problemCnt())
                          .toStringAsFixed(2)))
                ],
              ),
              SizedBox.fromSize(size: const Size.fromHeight(4.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("尝试次数: "),
                  Text(
                      "${userDb!.triesCnt()} (平均: ${userDb!.triesCnt() / userDb!.solvedCnt()})")
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> dictionaryDialog(bool right) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      right ? "🎉🎉🎉" : "/(ㄒoㄒ)/~~",
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: answer!
                        .map(
                          (e) => Column(
                            children: [
                              Text(
                                e.pinyin,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                e.word,
                                style: const TextStyle(fontSize: 22),
                              )
                            ],
                          ),
                        )
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Text("释义: "),
                        Flexible(
                          child: Text(
                            problem!.idiom.explanation,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Text("出自: "),
                        Flexible(
                          child: Text(
                            problem!.idiom.derivation,
                          ),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: problem!.idiom.hash),
                      ).then(
                        (_) => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("题目 ID 已被复制到剪贴板"),
                            duration: Duration(seconds: 1),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Text("题目ID: "),
                          Flexible(
                            child: Text(
                              problem!.idiom.hash,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    internalAudioPlayer.play("keypress-standard.mp3");

                    var date = DateTime.now();
                    var seed = date.year * 100000 + date.month * 100 + date.day;

                    randomProblem("idiom", seed).then(initProblem);

                    Navigator.of(context).pop();
                  },
                  child: const Text("每日题目")),
              OutlinedButton(
                  onPressed: () {
                    internalAudioPlayer.play("keypress-standard.mp3");

                    randomProblem("idiom", null).then(initProblem);

                    Navigator.of(context).pop();
                  },
                  child: const Text("随机成语")),
              OutlinedButton(
                  onPressed: () {
                    internalAudioPlayer.play("keypress-standard.mp3");

                    randomProblem("poem", null).then(initProblem);

                    Navigator.of(context).pop();
                  },
                  child: const Text("随机诗词")),
              OutlinedButton(
                  onPressed: () {
                    internalAudioPlayer.play("keypress-standard.mp3");

                    Navigator.of(context).pop();

                    seedInputDialog();
                  },
                  child: const Text("题目ID")),
              OutlinedButton(
                  onPressed: () {
                    internalAudioPlayer.play("keypress-standard.mp3");

                    Navigator.of(context).pop();

                    settingsDialog();
                  },
                  child: const Text("设置")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: setupFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                return WordleProblem(
                    db: idiomDb!,
                    problem: problem!,
                    submitCallback: (ProblemStatus status, int tries) {
                      if (status == ProblemStatus.won) {
                        userDb!.markSolved(problem!.idiom.hash);
                        userDb!.addTriesCnt(tries);
                        dictionaryDialog(true);

                        setState(() {
                          status = ProblemStatus.won;
                        });
                      } else if (status == ProblemStatus.lose) {
                        userDb!.addTriesCnt(tries);
                        dictionaryDialog(false);

                        setState(() {
                          status = ProblemStatus.lose;
                        });
                      } else {
                        dictionaryDialog(false);
                      }
                    });
            }
          },
        ),
      ),
    );
  }
}
