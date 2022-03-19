import 'dart:math';

import 'package:wordle/util.dart';

import 'model.dart';

class IdiomDb {
  late List<String> idiomHashes;
  late Map<String, Idiom> idiomMap;
  late Map<String, Set<String>> idiomChMap;
  late Set<String> idiomSet;

  late Set<String> poemSet;
  late Map<String, Set<String>> poemChMap;

  IdiomDb(List<Idiom> idiomList) {
    idiomMap = {};
    idiomChMap = {};
    idiomSet = {};
    idiomHashes = [];
    poemSet = {};
    poemChMap = {};

    for (var idiom in idiomList) {
      idiomHashes.add(idiom.hash);
      idiomMap[idiom.hash] = idiom;

      if (idiom.type == "idiom") {
        idiomSet.add(idiom.word);

        for (var ch in idiom.word.split("")) {
          idiomChMap.putIfAbsent(ch, () => {});

          idiomChMap[ch]!.add(idiom.hash);
        }
      } else {
        poemSet.add(idiom.word);

        for (var ch in idiom.word.split("")) {
          poemChMap.putIfAbsent(ch, () => {});

          poemChMap[ch]!.add(idiom.hash);
        }
      }
    }
  }

  bool isValid(String word) {
    return idiomSet.contains(word);
  }

  Problem pickProblem(String hash) {
    return composeProblem(hash, null);
  }

  Problem randomProblem(int? seed) {
    var rand = Random();
    var idx = rand.nextInt(idiomHashes.length);

    var hash = idiomHashes[idx];
    return composeProblem(hash, seed);
  }

  Problem composeProblem(String hash, int? seed) {
    var idiom = idiomMap[hash]!;

    seed ??= hash.codeUnits.reduce((v, e) => v * e).toInt();

    var seedRand = Random(seed);

    List<String> pool = [];

    for (var ch in idiom.word.split('')) {
      if (idiom.type == "idiom") {
        pool.addAll(idiomChMap[ch]!);
      } else {
        pool.addAll(poemChMap[ch]!);
      }
    }

    pool.shuffle(seedRand);

    Set<Character> potentialItems = {};

    var chs = idiom.word.split('');
    var pinyin = idiom.pinyin.split(' ');

    for (var i = 0; i < chs.length; i++) {
      potentialItems.add(Character(chs[i], getOrDefault(pinyin, i, " ")));
    }

    var poolIdx = 0;

    while (poolIdx < 6 && poolIdx < pool.length) {
      var hash = pool[poolIdx];
      var idiom = idiomMap[hash]!;

      var chs = idiom.word.split('');
      var pinyin = idiom.pinyin.split(' ');

      for (var i = 0; i < chs.length; i++) {
        potentialItems.add(Character(chs[i], getOrDefault(pinyin, i, " ")));
      }

      poolIdx += 1;
    }

    var potentialItemList = potentialItems.toList();

    potentialItemList.shuffle(seedRand);

    return Problem(idiom, potentialItemList);
  }
}
