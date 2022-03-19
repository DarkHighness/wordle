import 'dart:math';

import 'package:wordle/util.dart';
import 'package:wordle/wordle/config.dart';

import 'model.dart';

class IdiomDb {
  late Map<String, Idiom> idiomMap;

  late List<String> idiomHashes;
  late Map<String, Set<String>> idiomChMap;
  late Set<String> idiomSet;

  late Set<String> poemSet;
  late Map<String, Set<String>> poemChMap;
  late List<String> poemHashes;

  IdiomDb(List<Idiom> idiomList) {
    idiomMap = {};

    idiomChMap = {};
    idiomSet = {};
    idiomHashes = [];

    poemSet = {};
    poemChMap = {};
    poemHashes = [];

    for (var idiom in idiomList) {
      idiomMap[idiom.hash] = idiom;

      if (idiom.type == "idiom") {
        idiomHashes.add(idiom.hash);
        idiomSet.add(idiom.word);

        for (var ch in idiom.word.split("")) {
          idiomChMap.putIfAbsent(ch, () => {});

          idiomChMap[ch]!.add(idiom.hash);
        }
      } else {
        poemHashes.add(idiom.hash);
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

  Problem? pickProblem(String hash) {
    if (!idiomMap.containsKey(hash)) {
      return null;
    }

    return composeProblem(hash, null);
  }

  Problem randomProblem(String type, int? seed) {
    var rand = Random();
    var hash;

    assert(type == "idiom" || type == "poem");

    if (type == "idiom") {
      var idx = rand.nextInt(idiomHashes.length);

      hash = idiomHashes[idx];
    } else {
      var idx = rand.nextInt(poemHashes.length);

      hash = poemHashes[idx];
    }

    return composeProblem(hash, seed);
  }

  Problem composeProblem(String hash, int? seed) {
    var idiom = idiomMap[hash]!;

    seed ??= hash.codeUnits.reduce((v, e) => v * e).toInt();

    var seedRand = Random(seed);

    Set<String> pool = {};
    Set<int> usedIndex = {};

    pool.add(idiom.hash);

    var tries = 0;

    while (pool.length < minRandomPoolSize && tries < maxRandomPoolRetries) {
      if (usedIndex.length >= pool.length) {
        break;
      }

      var idx = 0;

      do {
        idx = seedRand.nextInt(pool.length);
      } while (usedIndex.contains(idx));

      usedIndex.add(idx);

      var hash = pool.elementAt(idx);
      var idiom = idiomMap[hash];

      for (var ch in idiom!.word.split('')) {
        if (idiom.type == "idiom") {
          pool.addAll(idiomChMap[ch]!);
        } else {
          pool.addAll(poemChMap[ch]!);
        }
      }

      tries++;
    }

    var poolList = pool.toList();

    poolList.shuffle(seedRand);

    Set<Character> potentialItems = {};

    var chs = idiom.word.split('');
    var pinyin = idiom.pinyin.split(' ');

    for (var i = 0; i < chs.length; i++) {
      potentialItems.add(Character(chs[i], getOrDefault(pinyin, i, " ")));
    }

    var poolIdx = 0;

    while (poolIdx < confusionPoolSize && poolIdx < poolList.length) {
      var hash = poolList[poolIdx];
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
