import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import 'package:wordle/v1/wordle/config.dart';
import 'package:wordle/v2/config/config.dart';
import 'package:wordle/v2/model/game_model.dart';
import 'package:wordle/v2/model/problem_model.dart';

class ProblemDb {
  final List<ProblemModel> _problems;
  final Map<ProblemId, ProblemModel> _problemMap = {};
  final Map<ProblemType, Map<ProblemDifficulty, List<ProblemId>>>
      _problemCategoryMap = {};

  final Set<String> _validInput = {};
  final Map<ProblemType, Map<String, Set<ProblemId>>> _relationMap = {};

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

      var words = problem.word.split("");

      for (var ch in words) {
        _relationMap[type] ??= {};
        _relationMap[type]![ch] ??= {};
        _relationMap[type]![ch]!.add(hash);
      }
    }
  }

  bool isValidInput(String input) {
    return _validInput.contains(input);
  }

  Set<ProblemId> _collectRelatedProblemIds(ProblemId problemId) {
    Set<ProblemId> ret = {};

    var problem = _problemMap[problemId]!;
    var type = problem.typeEnum;
    var words = problem.word.split("");

    for (var ch in words) {
      ret.addAll(_relationMap[type]![ch]!);
    }

    return ret;
  }

  GameModel randomGame(GameMode gameMode, ProblemType problemType,
      ProblemDifficulty difficulty) {
    var rand = Random();
    var idx =
        rand.nextInt(_problemCategoryMap[problemType]![difficulty]!.length);

    var hash = _problemCategoryMap[problemType]![difficulty]![idx];
    var problem = _problemMap[hash]!;

    rand = Random(hash.codeUnits.reduce((s, e) => s ^ e));

    var pool = _collectRelatedProblemIds(hash);
    var minPoolSize = difficulty == ProblemDifficulty.difficultyHard
        ? minRandomPoolSizeHard
        : minRandomPoolSizeEasy;

    for (var i = 0;
        i < pool.length &&
            pool.length < minPoolSize &&
            i < maxRandomPoolRetries;
        i++) {
      pool.addAll(_collectRelatedProblemIds(pool.elementAt(i)));
    }

    var poolList = pool.toList();
    var poolListCnt = difficulty == ProblemDifficulty.difficultyHard
        ? problemPoolSizeHard
        : problemPoolSizeEasy;

    poolList.shuffle(rand);
    poolList = poolList.take(poolListCnt).toList();
    poolList.add(hash);

    var choices = poolList
        .expand((e) => _problemMap[e]!.chars)
        .toSet()
        .map((e) => InputItem(character: e))
        .toList(growable: false);

    choices.shuffle(rand);

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
      var hintStage2 = choices
          .where(
              (v) => hintAnswers.indexWhere((e) => e.item2 == v.character) < 0)
          .take(poemHintMissingCount)
          .map((e) => HintItem(
              hintType: ProblemHintType.hintTypeMissing,
              hintCharacter: e.character!));

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
      var hintStage1 = choices
          .where(
              (v) => hintAnswers.indexWhere((e) => e.item2 == v.character) < 0)
          .take(poemHintMissingCount)
          .map((e) => HintItem(
              hintType: ProblemHintType.hintTypeMissing,
              hintCharacter: e.character!));

      hintAnswers.shuffle(rand);

      var hintStage2 = hintAnswers.take(idiomHintOccursCount).map((e) =>
          HintItem(
              hintType: ProblemHintType.hintTypeOccurs,
              hintCharacter: e.item2));

      hintItems = [...hintStage1, ...hintStage2, ...hintStage3];
    }

    choices.shuffle(rand);

    return GameModel(
        gameMode: gameMode,
        problem: problem,
        inputChoices: choices,
        hints: hintItems,
        maxAttempt: gameMaxRetries);
  }
}

Future<ProblemDb> loadProblemDbFromAssets() async {
  final String json = await rootBundle.loadString("assets/problems.json");
  final List<ProblemModel> problems = List<ProblemModel>.from(
      jsonDecode(json).map((e) => ProblemModel.fromJson(e)));

  return ProblemDb.fromProblems(problems);
}
