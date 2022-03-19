import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle/components/wordle_problem.dart';
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

  Future<Problem> randomProblem(int? seed) async {
    db ??= await readAssetsIdiom();
    problem = db!.randomProblem(seed);

    setupAnswer();

    return problem!;
  }

  Future<Problem> pickProblem(String hash) async {
    db ??= await readAssetsIdiom();
    problem = db!.pickProblem(hash);

    setupAnswer();

    return problem!;
  }

  void setupAnswer() {
    answer = [];

    var chs = problem!.idiom.word.split('');
    var pinyin = problem!.idiom.pinyin.split(' ');

    for (var i = 0; i < 4; i++) {
      answer!.add(Character(chs[i], pinyin[i]));
    }
  }

  late Future<Problem> _problemFuture;

  @override
  void initState() {
    _problemFuture = randomProblem(null);

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
                onPressed: () {
                  pickProblem(hashValue);

                  Navigator.pop(context);
                },
                child: const Text("确定"),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("取消"),
              )
            ],
          );
        });
  }

  Future<void> answerDialog(bool right) async {
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
                    children: answer!
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    e.pinyin,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    e.word,
                                    style: const TextStyle(
                                      fontSize: 22,
                                    ),
                                  )
                                ],
                              ),
                            ))
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
                    var date = DateTime.now();
                    var seed = date.year * 100000 + date.month * 100 + date.day;

                    randomProblem(seed).then((value) => setState(() {
                          // Just for update
                          problem = value;
                        }));

                    Navigator.of(context).pop();
                  },
                  child: const Text("每日题目")),
              OutlinedButton(
                  onPressed: () {
                    randomProblem(null).then((value) => setState(() {
                          // Just for update
                          problem = value;
                        }));

                    Navigator.of(context).pop();
                  },
                  child: const Text("随机")),
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    seedInputDialog();
                  },
                  child: const Text("选择")),
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
          builder: (BuildContext context, AsyncSnapshot<Problem> snapshot) {
            if (snapshot.hasData) {
              return WordleProblem(
                db: db!,
                problem: problem!,
                callback: (bool right) {
                  answerDialog(right);
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
