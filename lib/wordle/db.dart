import 'dart:math';

import 'model.dart';

class IdiomDb {
  late List<String> idiomHashes;
  late Map<String, Idiom> idiomMap;
  late Map<String, List<String>> idiomChMap;
  late Set<String> idiomSet;

  IdiomDb(List<Idiom> idiomList) {
    idiomMap = {};
    idiomChMap = {};
    idiomSet = {};
    idiomHashes = [];

    for (var idiom in idiomList) {
      idiomHashes.add(idiom.hash);
      idiomMap[idiom.hash] = idiom;
      idiomSet.add(idiom.word);

      for (var ch in idiom.word.split("")) {
        idiomChMap.putIfAbsent(ch, () => []);

        idiomChMap[ch]!.add(idiom.hash);
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
      pool.addAll(idiomChMap[ch]!);
    }

    pool.shuffle(seedRand);

    Set<Character> potentialItems = {};

    var chs = idiom.word.split('');
    var pinyin = idiom.pinyin.split(' ');

    for (var i = 0; i < 4; i++) {
      potentialItems.add(Character(chs[i], pinyin[i]));
    }

    var poolIdx = 0;

    while (poolIdx < 6 && poolIdx < pool.length) {
      var hash = pool[poolIdx];
      var idiom = idiomMap[hash]!;

      var chs = idiom.word.split('');
      var pinyin = idiom.pinyin.split(' ');

      for (var i = 0; i < 4; i++) {
        potentialItems.add(Character(chs[i], pinyin[i]));
      }

      poolIdx += 1;
    }

    var potentialItemList = potentialItems.toList();

    potentialItemList.shuffle(seedRand);

    return Problem(idiom, potentialItemList);
  }
}
