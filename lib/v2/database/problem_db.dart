import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import 'package:wordle/v2/config/config.dart';
import 'package:wordle/v2/model/game_model.dart';
import 'package:wordle/v2/model/problem_model.dart';

class ProblemDb {
  final List<ProblemModel> _problems;
  final Map<ProblemId, ProblemModel> _problemMap = {};
  final Map<ProblemType, Map<ProblemDifficulty, List<ProblemId>>>
      _problemCategoryMap = {};

  final Set<String> _validInput = {};

  ProblemDb.fromProblems(this._problems) {
    for (var problem in _problems) {
      var hash = problem.hash;
      var type = problem.typeEnum;
      var diff = problem.difficultyEnum;

      _problemCategoryMap[type] ??= {};
      _problemCategoryMap[type]![diff] ??= [];
      _problemCategoryMap[type]![diff]!.add(hash);

      _problemMap[hash] = problem;
      _validInput.add(problem.word);
    }
  }

  bool isValidProblem(String hash) {
    return _problemMap.containsKey(hash);
  }

  bool isValidInput(String input) {
    return _validInput.contains(input);
  }

  GameModel selectGame(String problemId, GameMode gameMode) {
    var problem = _problemMap[problemId]!;
    var difficulty = problem.difficultyEnum;
    var problemType = problem.typeEnum;
    var rand = Random(problemId.codeUnits.reduce((s, e) => s ^ e));

    Set<Character> choices = {};
    Set<String> pool = problem.similar.toSet();

    choices.addAll(_problemMap[problemId]!.chars);

    var choiceSize = difficulty == ProblemDifficulty.difficultyHard
        ? problemChoiceSizeHard
        : problemChoiceSizeEasy;

    var i = 0;
    var j = 0;

    while (choices.length < choiceSize) {
      if (i < pool.length) {
        var before = choices.length;

        var hash = pool.elementAt(i);
        var problem = _problemMap[hash]!;

        pool.addAll(problem.similar);
        choices.addAll(problem.chars);

        if (before == choices.length && j++ > problemChoiceMaxRetries) {
          break;
        }

        i++;
      } else {
        var idx =
            rand.nextInt(_problemCategoryMap[problemType]![difficulty]!.length);
        var hash = _problemCategoryMap[problemType]![difficulty]![idx];

        pool.add(hash);
      }
    }

    var choicesList = choices.toList();

    choicesList.shuffle(rand);

    List<HintItem> hintItems = [];

    // 生成提示
    if (problemType == ProblemType.typePoem) {
      var len = problem.hintLength;

      var hintAnswers = problem.chars
          .asMap()
          .entries
          .map((e) => Tuple2(e.key, e.value))
          .toList(growable: false);

      hintAnswers.shuffle(rand);

      var hintStage1 = hintAnswers
          .take(len + poemHintAnswerCount)
          .map((e) => HintItem(
              hintType: ProblemHintType.hintTypeAnswer,
              hintCharacter: e.item2,
              hintPosition: e.item1))
          .toList(growable: false);

      // 然后按照不出现, 出现, 正确的方式生成提示
      var hintStage2 = choicesList
          .where((v) => hintAnswers.indexWhere((e) => e.item2 == v) < 0)
          .take(poemHintMissingCount)
          .map((e) => HintItem(
              hintType: ProblemHintType.hintTypeMissing, hintCharacter: e));

      var hintStage3 = hintAnswers
          .where((v) =>
              hintStage1.indexWhere((e) => e.hintCharacter == v.item2) < len)
          .take(poemHintOccursCount)
          .map((e) => HintItem(
              hintType: ProblemHintType.hintTypeOccurs,
              hintCharacter: e.item2));

      var hintStage4 = hintStage1.reversed.take(poemHintAnswerCount);

      hintStage1 = hintStage1.take(len).toList();

      hintItems = [...hintStage1, ...hintStage2, ...hintStage3, ...hintStage4];
    } else if (problemType == ProblemType.typeIdiom) {
      var hintAnswers = problem.chars
          .asMap()
          .entries
          .map((e) => Tuple2(e.key, e.value))
          .toList(growable: false);

      hintAnswers.shuffle(rand);

      var hintStage3 = hintAnswers.take(idiomHintAnswerCount).map((e) =>
          HintItem(
              hintType: ProblemHintType.hintTypeAnswer,
              hintCharacter: e.item2,
              hintPosition: e.item1));

      // 然后按照不出现, 出现的方式生成提示
      var hintStage1 = choicesList
          .where((v) => hintAnswers.indexWhere((e) => e.item2 == v) < 0)
          .take(poemHintMissingCount)
          .map((e) => HintItem(
              hintType: ProblemHintType.hintTypeMissing, hintCharacter: e));

      hintAnswers.shuffle(rand);

      var hintStage2 = hintAnswers.take(idiomHintOccursCount).map((e) =>
          HintItem(
              hintType: ProblemHintType.hintTypeOccurs,
              hintCharacter: e.item2));

      hintItems = [...hintStage1, ...hintStage2, ...hintStage3];
    }

    choicesList.shuffle(rand);

    return GameModel(
        gameMode: gameMode,
        problem: problem,
        inputChoices: choicesList
            .map((e) => InputItem(character: e))
            .toList(growable: false),
        hints: hintItems,
        maxAttempt: gameMaxRetries);
  }

  GameModel randomGame(GameMode gameMode, ProblemType problemType,
      ProblemDifficulty difficulty) {
    var rand = Random();
    var idx =
        rand.nextInt(_problemCategoryMap[problemType]![difficulty]!.length);

    var problemId = _problemCategoryMap[problemType]![difficulty]![idx];

    return selectGame(problemId, gameMode);
  }
}

Future<ProblemDb> loadProblemDbFromAssets() async {
  final String json = await rootBundle.loadString("assets/problems.json");
  final List<ProblemModel> problems = List<ProblemModel>.from(
      jsonDecode(json).map((e) => ProblemModel.fromJson(e)));

  return ProblemDb.fromProblems(problems);
}
