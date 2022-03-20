import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle/components/wordle_problem.dart';
import 'package:wordle/constants/audios.dart';
import 'package:wordle/util.dart';
import 'package:wordle/wordle/db.dart';
import 'package:wordle/wordle/model.dart';
import 'package:wordle/wordle/util.dart';

class WordlePage extends StatefulWidget {
  const WordlePage({Key? key}) : super(key: key);

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  IdiomDb? db;
  Problem? problem;
  List<Character>? answer;

  Future<Problem> randomProblem(String type, int? seed) async {
    db ??= await setupIdiomDb();

    var _problem = db!.randomProblem(type, seed);

    return _problem;
  }

  Future<Problem> pickProblem(String hash) async {
    db ??= await setupIdiomDb();

    var _problem = db!.pickProblem(hash);

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
    });
  }

  late Future<void> _problemFuture;

  @override
  void initState() {
    internalAudioPlayer.loadAll([
      "keypress-standard.mp3",
      "keypress-delete.mp3",
      "keypress-return.mp3"
    ]);

    _problemFuture = randomProblem("idiom", null).then(initProblem);

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
        return Dialog();
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
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _problemFuture,
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
                  db: db!,
                  problem: problem!,
                  callback: (bool right) {
                    dictionaryDialog(right);
                  },
                );
            }
          },
        ),
      ),
    );
  }
}
